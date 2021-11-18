// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Strings.sol";

contract SVGShapes {

    using Strings for string;

function expand(uint256 randomValue, uint256 n) public pure returns (uint256[] memory expandedValues) {
        expandedValues = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
        }
        return expandedValues;
    }

    function generateSVG(uint256 _randomNumber, uint256 _maxNumberOfShapes, uint256 _size) public view returns (string memory finalSVG) {
        uint256 numberOfShapes = (_randomNumber % maxNumberOfShapes) +1;
        //this is the first line of the svg - always need it - just adjust the numbers for size if need to
        finalSVG = string(abi.encodePacked("<svg xmlns='http://www.w3.org/2000/svg' height='", string(Strings.toString(_size)), "' width='", string(Strings.toString(_size)), "'>"));
        //loop through for paths
        for(uint i=0; i < numberOfShapes; i++){
            uint256 newRNG = uint256(keccak256(abi.encode(_randomNumber, i)));
            string memory pathSvg = generateShape(newRNG, _size); //this is what needs to be replaced first with a shape choosing function
            finalSVG = string(abi.encodePacked(finalSVG, pathSvg));
        }
        //this is the closing line of the svg
        finalSVG = string(abi.encodePacked(finalSVG, "</svg>"));
    }
    
    function generateShape(uint256 _randomNumber, uint256 _size) public view returns(string memory pathSvg) {
        //need to work out a shape
        pathSvg = "";
        if (_randomNumber % 2 == 0) {
            //draw a circle
            uint256[] memory circleVars = expand(_randomNumber, 6);
            pathSvg = string(abi.encodePacked(pathSvg, "<circle cx='", string(Strings.toString(circleVars[0] % _size)), "' cy='", string(Strings.toString(circleVars[1] % _size)), "' r='", string(Strings.toString(circleVars[2] % (_size / 2))), "' stroke='#", hexColor(circleVars[3]), "' stroke-width='", string(Strings.toString(circleVars[4] % (_size / 5))), "' fill='#", hexColor(circleVars[5]), "' />"));
            } else {
            //draw a square
            uint256[] memory rectVars = expand((_randomNumber + 1), 7);
            pathSvg = string(abi.encodePacked(pathSvg, "<rect x='", uint2str((rectVars[0] % size)), "' y='", uint2str((rectVars[1] % size)), "' width='", uint2str((rectVars[2] % (size / 2))),"' height='", uint2str((rectVars[3] % (size / 2))), "' stroke='#", hexColor(rectVars[4]), "' stroke-width='", uint2str((rectVars[5] % (size / 5))), "' fill='#", hexColor(rectVars[6]), "' />"));
        }
        
    }
    
    function hexColor(uint256 number) internal pure returns(string memory hexC) {
        hexC = getSlice(3, 8, string(Strings.toHexString(number % 16777216)));
    }

    function getSlice(uint256 begin, uint256 end, string memory text) internal pure returns (string memory) {
        bytes memory slice = new bytes(end-begin+1);
        for(uint i=0;i<=end-begin;i++){
            slice[i] = bytes(text)[i+begin-1];
        }
        return string(slice);    
    }
}