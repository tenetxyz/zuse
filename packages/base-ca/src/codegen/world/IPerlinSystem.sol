// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

interface IPerlinSystem {
  function noise2d(int256 _x, int256 _y, int256 denom, uint8 precision) external pure returns (int128);

  function noise(int256 _x, int256 _y, int256 _z, int256 denom, uint8 precision) external pure returns (int128);

  function dec(int128 x) external pure returns (int128);

  function floor(int128 x) external pure returns (int128);

  function fade(int128 t) external pure returns (int128);

  function lerp(int128 t, int128 a, int128 b) external pure returns (int128);

  function grad(int16 _hash, int128 x, int128 y, int128 z) external pure returns (int128);

  function grad2d(int16 _hash, int128 x, int128 y) external pure returns (int128);

  function p(int64 i) external pure returns (int64);

  function p2(int16 i) external pure returns (int16);

  function i0(int16 tuple) external pure returns (int16);

  function i1(int16 tuple) external pure returns (int16);

  function ptable(int256 i) external pure returns (int256);
}
