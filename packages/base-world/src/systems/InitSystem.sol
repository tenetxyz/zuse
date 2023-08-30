// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { InitWorld } from "../prototypes/InitWorld.sol";

contract InitSystem is InitWorld {
  function getRegistryAddress() internal pure override returns (address) {
    return address(0);
  }

  function initWorldVoxelTypes() public override {
    super.initWorldVoxelTypes();
  }

  function onNewCAVoxelType(address caAddress, bytes32 voxelTypeId) public override {
    super.onNewCAVoxelType(caAddress, voxelTypeId);
  }

  function isCAAllowed(address caAddress) public view override returns (bool) {
    return super.isCAAllowed(caAddress);
  }

  function isVoxelTypeAllowed(bytes32 voxelTypeId) public view override returns (bool) {
    return super.isVoxelTypeAllowed(voxelTypeId);
  }
}
