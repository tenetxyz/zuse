// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord } from "@tenet-utils/src/Types.sol";

interface IElectronVoxelSystem {
  function ca_ElectronVoxelSys_registerVoxel() external;

  function ca_ElectronVoxelSys_enterWorld(VoxelCoord memory coord, bytes32 entity) external;

  function ca_ElectronVoxelSys_exitWorld(VoxelCoord memory coord, bytes32 entity) external;

  function ca_ElectronVoxelSys_variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) external view returns (bytes32);

  function ca_ElectronVoxelSys_activate(bytes32 entity) external view returns (string memory);

  function ca_ElectronVoxelSys_eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) external returns (bytes32, bytes32[] memory);
}
