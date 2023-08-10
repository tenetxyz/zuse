// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

struct CreationSpawns {
  address world;
  uint256 numSpawns;
}

struct CreationMetadata {
  string name;
  string description;
  CreationSpawns[] spawns;
}
