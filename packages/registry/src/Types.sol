// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

struct CreationSpawns {
  address worldAddress;
  uint256 numSpawns;
}

struct CreationMetadata {
  address creator;
  string name;
  string description;
  CreationSpawns[] spawns;
}
