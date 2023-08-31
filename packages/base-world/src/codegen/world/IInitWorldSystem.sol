// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

interface IInitWorldSystem {
  function initWorldVoxelTypes() external;

  function onNewCAVoxelType(address caAddress, bytes32 voxelTypeId) external;

  function isCAAllowed(address caAddress) external view returns (bool);

  function isVoxelTypeAllowed(bytes32 voxelTypeId) external view returns (bool);
}
