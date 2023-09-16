// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { MineEvent } from "@tenet-base-world/src/prototypes/MineEvent.sol";
import { VoxelCoord, VoxelEntity, VoxelTypeData } from "@tenet-utils/src/Types.sol";
import { VoxelType, OfSpawn, Spawn, SpawnData } from "@tenet-world/src/codegen/Tables.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "../Constants.sol";
import { MineEventData } from "@tenet-base-world/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { MineWorldEventData } from "@tenet-world/src/Types.sol";

contract MineSystem is MineEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function callEventHandler(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent,
    bytes memory eventData
  ) internal override returns (VoxelEntity memory) {
    return IWorld(_world()).mineVoxelType(voxelTypeId, coord, runEventOnChildren, runEventOnParent, eventData);
  }

  // Called by users
  function mineWithAgent(bytes32 voxelTypeId, VoxelCoord memory coord, VoxelEntity memory agentEntity) public returns (VoxelEntity memory) {
    require(coord.y <= CHUNK_MAX_Y && coord.y >= CHUNK_MIN_Y, "out of chunk bounds");
    MineWorldEventData memory mineEventData = MineWorldEventData({
      agentEntity: agentEntity
    });
    super.mine(voxelTypeId, coord, abi.encode(MineEventData({ worldData: abi.encode(mineEventData) })));
  }

  function mineVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool mineChildren,
    bool mineParent,
    bytes memory eventData
  ) internal override returns (VoxelEntity memory) {
    return super.runEventHandler(voxelTypeId, coord, mineChildren, mineParent, eventData);
  }

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal override {
    if (voxelTypeId != AirVoxelID) {
      // TODO: Figure out how to add other airs
      // Can't own it since it became air, so we gift it
      IWorld(_world()).giftVoxel(voxelTypeId);
    }
    super.postRunCA(caAddress, voxelTypeId, coord, eventVoxelEntity, eventData);
  }

  function clearCoord(uint32 scale, VoxelCoord memory coord) public returns (VoxelEntity memory) {
    bytes32 entity = getEntityAtCoord(scale, coord);

    bytes32 voxelTypeId = VoxelType.getVoxelTypeId(scale, entity);
    if (voxelTypeId == AirVoxelID) {
      // if it's air, then it's already clear
      return VoxelEntity({
        scale: 0,
        entityId: 0
      });
    }

    return mine(voxelTypeId, coord);
  }
}
