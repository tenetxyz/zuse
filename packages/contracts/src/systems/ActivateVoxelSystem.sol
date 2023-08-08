// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ActivateEvent } from "../prototypes/ActivateEvent.sol";
import { WorldConfig, Position, PositionTableId, VoxelType, VoxelTypeTableId, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "../Types.sol";
import { positionDataToVoxelCoord } from "../Utils.sol";

contract ActivateVoxelSystem is ActivateEvent {
  function activateVoxel(uint32 scale, bytes32 entity) public {
    require(
      hasKey(VoxelTypeTableId, VoxelType.encodeKeyTuple(scale, entity)),
      "ActivateVoxelSystem: entity does not exist"
    );
    bytes32 voxelTypeId = VoxelType.getVoxelTypeId(scale, entity);
    VoxelCoord memory coord = positionDataToVoxelCoord(Position.get(scale, entity));
    super.activateVoxel(voxelTypeId, coord);
  }

  function activateVoxelType(bytes32 voxelTypeId, VoxelCoord memory coord) public override {
    super.activateVoxelType(voxelTypeId, coord);
  }
}
