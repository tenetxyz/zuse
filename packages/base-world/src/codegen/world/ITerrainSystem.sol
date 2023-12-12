// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

interface ITerrainSystem {
  function getTerrainObjectTypeId(VoxelCoord memory coord) external view returns (bytes32);

  function getTerrainObjectProperties(
    VoxelCoord memory coord,
    ObjectProperties memory requestedProperties
  ) external returns (ObjectProperties memory);
}
