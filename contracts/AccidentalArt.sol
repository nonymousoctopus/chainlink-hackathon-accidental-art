// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";
import "@nonymousoctopus/chainlink-hackathon-accidental-art/contracts/SVGShapes.sol";

contract AccidentalArt is ChainlinkClient, VRFConsumerBase, ERC721URIStorage, SVGShapes {
    
    using Chainlink for Chainlink.Request;
    using Strings for string;
  
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    //this is for the random number
    bytes32 internal keyHash;
    uint256 public randomResult;
    uint256 public tokenCounter;

    //these will need to be reviewed for my own implementation
    uint256 public maxNumberOfShapes;//this used to be number of maxNumberOfPaths
    uint256 public size;

    mapping(bytes32 => address) public requestIdToSender;
    mapping(bytes32 => uint256) public requestIdToTokenId;
    mapping(uint256 => uint256) public tokenIdToRandomNumber;
    mapping(uint256 => string) public tokenIdToRandomWord;

    event requestedRandomSVG(bytes32 indexed requestId, uint256 indexed tokenId);
    event CreatedUnfinishedRandomSVG(uint256 indexed tokenId, uint256 randomNumber);
    event CreatedRandomSVG(uint256 indexed tokenId, string tokenURI);
    
    constructor(address _VFRCoordinator, address _LinkToken, address _oracle, bytes32 _keyHash, bytes32 _jobId, uint256 _fee)
    VRFConsumerBase(_VFRCoordinator, _LinkToken) 
    ERC721 ("AccidentalArt", "aART")
    {
        setChainlinkToken(_LinkToken);
        oracle = _oracle; // (Obtain from the Oracle.sol contract of your node)
        jobId = _jobId; // (Obtain from node aftter setting up the external adapter)
        fee = _fee; // (Varies by network and job)
        keyHash = _keyhash;
        tokenCounter = 0;
        maxNumberOfShapes = 10;
        size = 500;
    }
    
    function create() public returns (bytes32 requestId) {
        //reg a random number
        requestId = requestRandomness(keyHash, fee);
        requestIdToSender[requestId] = msg.sender;
        uint256 tokenId = tokenCounter;
        requestIdToTokenId[requestId] = tokenId;
        requestRandomWord();
        tokenCounter = tokenCounter + 1;
        emit requestedRandomSVG(requestId, tokenId);
    }
    
     function requestRandomWord() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        request.add("path", "data");
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    function fulfill(bytes32 _requestId, bytes32 _word) public recordChainlinkFulfillment(_requestId) {
        uint256 tokenId = tokenCounter - 1;
        tokenIdToRandomWord[tokenId] = (bytes32ToString(_word));
        //word = (bytes32ToString(_word));
    }

    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomNumber) internal override{
        address nftOwner = requestIdToSender[_requestId];
        uint256 tokenId = requestIdToTokenId[_requestId];
        _safeMint(nftOwner, tokenId);
        tokenIdToRandomNumber[tokenId] = _randomNumber;
        emit CreatedUnfinishedRandomSVG(tokenId, _randomNumber);
    }
    
    function finishMint (uint256 _tokenId) public {
        require(bytes(tokenURI(_tokenId)).length <= 0, "tokenURI is already all set!");
        require(tokenCounter > _tokenId, "TokenId has not been minted yet!");
        require(tokenIdToRandomNumber[_tokenId] > 0, "Need to wait for Chainlin VRF");
        require(tokenIdToRandomWord[_tokenId] > 0, "Need to wait for External Adapter");
        uint256 randomNumber = tokenIdToRandomNumber[_tokenId];
        string memory randomWord = tokenIdToRandomWord[_tokenId];
        string memory svg = generateSVG(randomNumber, maxNumberOfShapes, size);
        string memory imageURI = svgToImageURI(svg);
        string memory tokenURI = formatTokenURI(imageURI, randomWord);
        _setTokenURI(_tokenId, tokenURI);
        emit CreatedRandomSVG(_tokenId, svg);
    }

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
   
    function svgToImageURI(string memory _svg) public pure returns (string memory) {
        //start of every svg file
        string memory baseURL = "data:image/svg+xml;base64,";
        //encoding the svg passed to this function
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(_svg))));
        //concating the two above and making it one long string
        string memory imageURI = string(abi.encodePacked(baseURL, svgBase64Encoded));

        //reutrning theimage URI out of the function
        return imageURI;
    }
    
    function formatTokenURI(string memory _imageURI, string memory _randomWord) public view returns (string memory) {
        string memory baseURL = "data:application/json;base64,";
        return string(abi.encodePacked(
            baseURL,
            Base64.encode(
                bytes(abi.encodePacked(
                    '{"name": ', _randomWord, 
                    '"description": "A randomly generated SVG art NFT", ',
                    '"attributes": "", ', 
                    '"image": "',_imageURI, '"}'
                )
            ))
        ));
    }
}

//test