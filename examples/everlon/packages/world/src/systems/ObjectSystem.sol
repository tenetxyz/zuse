// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { ObjectSystem as ObjectProtoSystem } from "@tenet-base-world/src/systems/ObjectSystem.sol";

contract ObjectSystem is ObjectProtoSystem {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function enterWorld(
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override returns (ObjectProperties memory requestedProperties) {
    return super.enterWorld(objectTypeId, coord, objectEntityId);
  }

  function exitWorld(bytes32 objectTypeId, VoxelCoord memory coord, bytes32 objectEntityId) public override {
    return super.exitWorld(objectTypeId, coord, objectEntityId);
  }
}
