// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

// Try not to use openzeppelin since we'll need to import it when we codegen code that has this file as a dependency
// import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

function int32ToString(int32 _num) pure returns (string memory) {
  // return Strings.toString(int256(num));
    bytes4 num = bytes4(uint32(_num));
    bytes memory array = new bytes(8);
    bytes memory alphabet = "0123456789abcdef";

    for(uint i = 0; i < 4; i++) {
      array[i*2] = alphabet[uint(uint8(num[i])/16)];
      array[1+i*2] = alphabet[uint(uint8(num[i])%16)];
    }
    return string(array);
}

function bytes4ToString(bytes4 num) pure returns (string memory) {
  // return Strings.toString(uint256(uint32(num)));
    bytes memory array = new bytes(8);
    bytes memory alphabet = "0123456789abcdef";

    for(uint i=0; i<4; i++) {
      array[i*2] = alphabet[uint(uint8(num[i])/16)];
      array[1+i*2] = alphabet[uint(uint8(num[i])%16)];
    }
    return string(array);
}

function bytes32ToString(bytes32 _bytes) pure returns (string memory) {
    bytes memory byteArray = new bytes(64);
    for (uint i=0; i<32; i++) {
        bytes1 b = bytes1(uint8(uint(_bytes) / (2**(8*(31 - i)))));
        bytes1 hi = bytes1(uint8(b) / 16);
        bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
        byteArray[i*2] = char(hi);
        byteArray[i*2+1] = char(lo);            
    }
    return string(byteArray);
}

function char(bytes1 b) pure returns (bytes1 c) {
    if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
    else return bytes1(uint8(b) + 0x57);
}