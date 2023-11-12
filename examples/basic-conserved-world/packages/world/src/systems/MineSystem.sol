// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { MineEvent } from "@tenet-base-world/src/prototypes/MineEvent.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { VoxelCoord, VoxelEntity, VoxelTypeData, EntityEventData } from "@tenet-utils/src/Types.sol";
import { VoxelType, WorldConfig } from "@tenet-world/src/codegen/Tables.sol";
import { MineEventData } from "@tenet-base-world/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS, BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";
import { MineWorldEventData } from "@tenet-world/src/Types.sol";
import { onMine, postTx } from "@tenet-simulator/src/CallUtils.sol";
import { CAEntityReverseMapping } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";

contract MineSystem is MineEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function processCAEvents(EntityEventData[] memory entitiesEventData) internal override {
    IWorld(_world()).caEventsHandler(entitiesEventData);
  }

  // Called by users
  function mineWithAgent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory agentEntity
  ) public returns (VoxelEntity memory) {
    MineWorldEventData memory mineEventData = MineWorldEventData({ agentEntity: agentEntity });
    return super.mine(voxelTypeId, coord, abi.encode(MineEventData({ worldData: abi.encode(mineEventData) })));
  }

  function mineWithAgentCaEntity(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 caEntity
  ) public returns (VoxelEntity memory) {
    bytes32 entity = CAEntityReverseMapping.getEntity(IStore(BASE_CA_ADDRESS), caEntity);
    return mineWithAgent(voxelTypeId, coord, VoxelEntity({ scale: 1, entityId: entity }));
  }

  function postEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData,
    EntityEventData[] memory entitiesEventData
  ) internal override {
    super.postEvent(voxelTypeId, coord, eventVoxelEntity, eventData, entitiesEventData);
    MineEventData memory mineEventData = abi.decode(eventData, (MineEventData));
    MineWorldEventData memory mineWorldEventData = abi.decode(mineEventData.worldData, (MineWorldEventData));
    postTx(SIMULATOR_ADDRESS, mineWorldEventData.agentEntity, eventVoxelEntity, coord);
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal override returns (VoxelEntity memory) {
    eventVoxelEntity = super.preRunCA(caAddress, voxelTypeId, coord, eventVoxelEntity, eventData);
    // Call simulator mass change
    MineEventData memory mineEventData = abi.decode(eventData, (MineEventData));
    MineWorldEventData memory mineWorldEventData = abi.decode(mineEventData.worldData, (MineWorldEventData));
    onMine(SIMULATOR_ADDRESS, mineWorldEventData.agentEntity, eventVoxelEntity, coord);
    return eventVoxelEntity;
  }
}
