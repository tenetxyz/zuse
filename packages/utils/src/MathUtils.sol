// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

// Helper function to get the minimum of two uints
function min(uint a, uint b) pure returns (uint) {
  return a < b ? a : b;
}

// Using Babylonian method
function sqrt(uint x) pure returns (uint y) {
  uint z = (x + 1) / 2;
  y = x;
  while (z < y) {
    y = z;
    z = (x / z + z) / 2;
  }
}

// Helper function to calculate the absolute value of an integer
function abs(int x) pure returns (int) {
  if (x < 0) {
    return -x;
  }
  return x;
}

function absInt32(int32 x) pure returns (int32) {
  if (x < 0) {
    return -x;
  }
  return x;
}

function floorDiv(int32 a, int32 b) pure returns (int32) {
  require(b != 0, "Division by zero");
  if (a >= 0) {
    return a / b;
  } else {
    int32 result = a / b;
    return (a % b != 0) ? result - 1 : result;
  }
}

function absoluteDifference(uint256 a, uint256 b) pure returns (uint256) {
  if (a > b) {
    return a - b;
  } else {
    return b - a;
  }
}
