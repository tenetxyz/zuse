// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord } from "@tenet-utils/src/Types.sol";

interface IAirVoxelSystem {
  function ca_AirVoxelSystem_registerVoxel() external;

  function ca_AirVoxelSystem_enterWorld(VoxelCoord memory coord, bytes32 entity) external;

  function ca_AirVoxelSystem_exitWorld(VoxelCoord memory coord, bytes32 entity) external;

  function ca_AirVoxelSystem_variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) external view returns (bytes32);

  function ca_AirVoxelSystem_activate(bytes32 entity) external view returns (string memory);

  function ca_AirVoxelSystem_eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) external returns (bytes32, bytes32[] memory);
}
