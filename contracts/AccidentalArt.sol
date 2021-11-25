// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "base64-sol/base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

library SVGShapes {
    using Strings for string;

    // this loops through to generate multiple random numbers from a verifiably random number supplied by the VRF at no additional cost
    function expand(uint256 randomValue, uint256 n) public pure returns (uint256[] memory expandedValues) {
        expandedValues = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
        }
        return expandedValues;
    }

    // this generates the svg code
    function generateSVG(uint256 _randomNumber) internal pure returns (string memory finalSVG) {
        uint256 numberOfShapes = (_randomNumber % 10) +1;
        // opening line of svg imave
        finalSVG = string(abi.encodePacked("<svg xmlns='http://www.w3.org/2000/svg' height='", string(Strings.toString(500)), "' width='", string(Strings.toString(500)), "'>"));
        // loop through for shapes
        for(uint i=0; i < numberOfShapes; i++){
            uint256 newRNG = uint256(keccak256(abi.encode(_randomNumber, i)));
            string memory pathSvg = generateShape(newRNG); 
            finalSVG = string(abi.encodePacked(finalSVG, pathSvg));
        }
        // closing line of svg image
        finalSVG = string(abi.encodePacked(finalSVG, "</svg>"));
    }
    
    // this generates the shapes of the svg image
    function generateShape(uint256 _randomNumber) internal pure returns(string memory pathSvg) {
        // clear bath for start of shape
        pathSvg = "";
        if (_randomNumber % 2 == 0) {
            // draw a circle
            uint256[] memory circleVars = expand(_randomNumber, 7);
            // string of a circle with random position, radius, stroke colour and width, with transparent fill
            pathSvg = string(abi.encodePacked(pathSvg, "<circle cx='", string(Strings.toString(circleVars[0] % 500)), "' cy='", string(Strings.toString(circleVars[1] % 500)), "' r='", string(Strings.toString(circleVars[2] % 250)), "' stroke='rgb(", string(Strings.toString(circleVars[3] % 255)), ",", string(Strings.toString(circleVars[4] % 255)), ",", string(Strings.toString(circleVars[5] % 255)), ")' stroke-width='", string(Strings.toString(circleVars[6] % 100)), "' fill='transparent' />"));
            } else {
            // draw a rectandle
            uint256[] memory rectVars = expand((_randomNumber + 1), 7);
            // string of a rectangle with random position, size, and fill colour
            pathSvg = string(abi.encodePacked(pathSvg, "<rect x='", string(Strings.toString(rectVars[0] % 500)), "' y='", string(Strings.toString(rectVars[1] % 500)), "' width='", string(Strings.toString(rectVars[2] % 250)),"' height='", string(Strings.toString(rectVars[3] % 250)), "' fill='rgb(", string(Strings.toString(rectVars[4] % 255)),",", string(Strings.toString(rectVars[5] % 255)),",", string(Strings.toString(rectVars[6] % 255)), ")' />"));
        }
    }
}


contract RandomSVG is ChainlinkClient, ERC721URIStorage, VRFConsumerBase {

    using Strings for string;
    using SVGShapes for string;
    using Chainlink for Chainlink.Request;

    bytes32 public keyHash;
    uint256 public fee;
    uint256 public tokenCounter;
    address private oracle;
    bytes32 private jobId;

    mapping(bytes32 => address) public requestIdToSender; 
    mapping(bytes32 => uint256) public requestIdToTokenId;
    mapping(uint256 => uint256) public tokenIdToRandomNumber;
    mapping(uint256 => string) public tokenIdToRandomWord;

    event requestedRandomSVG(bytes32 indexed requestId, uint256 indexed tokenId);
    event CreatedUnfinishedRandomSVG(uint256 indexed tokenId, uint256 randomNumber);
    event CreatedRandomSVG(uint256 indexed tokenId, string tokenURI);

    constructor(address _VFRCoordinator, address _LinkToken, bytes32 _keyHash, uint256 _fee, address _oracle, bytes16 _jobId)
    VRFConsumerBase(_VFRCoordinator, _LinkToken) 
    ERC721 ("AccidentalART", "aART") {
        setChainlinkToken(_LinkToken); // necesarry for non eth chains
        fee = _fee;
        keyHash = _keyHash;
        tokenCounter = 0;
        oracle = _oracle;
        jobId = _jobId;
    }

    // this is the frst of the two functions that need to be called by the dapp
    function create() public returns (bytes32 requestId) {
        requestId = requestRandomness(keyHash, fee);
        requestIdToSender[requestId] = msg.sender;
        uint256 tokenId = tokenCounter;
        requestIdToTokenId[requestId] = tokenId;
        requestRandomWord();
        tokenCounter = tokenCounter + 1;
        emit requestedRandomSVG(requestId, tokenId);
    }
    
    // this function requests a random word from an external adapter ran by a node - a mumbai testnet deployment has been provided for the duration of the hackathon judjing period
    function requestRandomWord() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Insufficient LINK");
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        request.add("path", "data");
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    // this completes the random word request and retrieves the andom word
    function fulfill(bytes32 _requestId, bytes32 _word) public recordChainlinkFulfillment(_requestId) {
        tokenIdToRandomWord[tokenCounter - 1] = (bytes32ToString(_word));
    }
    
    // this function calls chainlink VRF for a random number
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Insufficient LINK");
        return requestRandomness(keyHash, fee);
    }

    // this completes the random number aquisition from the VRF
    function fulfillRandomness(bytes32 _requestId, uint256 _randomNumber) internal override{
        address nftOwner = requestIdToSender[_requestId];
        uint256 tokenId = requestIdToTokenId[_requestId];
        _safeMint(nftOwner, tokenId);
        tokenIdToRandomNumber[tokenId] = _randomNumber;
        emit CreatedUnfinishedRandomSVG(tokenId, _randomNumber);
    }
    
    // this is the second of the two functions that need to be called by the dapp - must be called after random number and word have been generated by a chainlink node
    function finishMint (uint256 _tokenId) public {
        require(bytes(tokenURI(_tokenId)).length <= 0, "tokenURI already used");
        require(tokenCounter > _tokenId, "Awaiting TokenId");
        require(tokenIdToRandomNumber[_tokenId] > 0, "Awaiting VRF");
        uint256 randomNumber = tokenIdToRandomNumber[_tokenId];
        string memory svg = SVGShapes.generateSVG(randomNumber);
        string memory imageURI = svgToImageURI(svg);
        string memory tokenURI = formatTokenURI(imageURI, tokenIdToRandomWord[_tokenId]);
        _setTokenURI(_tokenId, tokenURI);
        emit CreatedRandomSVG(_tokenId, svg);
    }

    // this converts the random word external adapter response from bytes32 to a string for insertion into the NFT
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
   
   // this formats the svg code an image URI
    function svgToImageURI(string memory _svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(_svg))));
        string memory imageURI = string(abi.encodePacked(baseURL, svgBase64Encoded));
        return imageURI;
    }
    
    //this formats the final token URI for the blockchain uising the svg code generated from the random number, and the random word as the name of the NFT
    function formatTokenURI(string memory _imageURI, string memory _randomWord) public pure returns (string memory) {
        string memory baseURL = "data:application/json;base64,";
        return string(abi.encodePacked(
            baseURL,
            Base64.encode(
                bytes(abi.encodePacked(
                    '{"name": "', _randomWord, '", ',
                    '"description": "A randomly generated SVG art NFT", ',
                    '"attributes": "", ', 
                    '"image": "',_imageURI, '"}'
                )
            ))
        ));
    }
    
}