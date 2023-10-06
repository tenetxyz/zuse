// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { MineEvent } from "@tenet-base-world/src/prototypes/MineEvent.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { VoxelCoord, VoxelEntity, VoxelTypeData, EntityEventData, SimEventData, SimTable } from "@tenet-utils/src/Types.sol";
import { VoxelType, OfSpawn, Spawn, SpawnData, WorldConfig, VoxelTypeProperties } from "@tenet-world/src/codegen/Tables.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "../Constants.sol";
import { MineEventData } from "@tenet-base-world/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { MineWorldEventData } from "@tenet-world/src/Types.sol";
import { setSimValue } from "@tenet-simulator/src/CallUtils.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";

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
    require(coord.y <= CHUNK_MAX_Y && coord.y >= CHUNK_MIN_Y, "out of chunk bounds");
    MineWorldEventData memory mineEventData = MineWorldEventData({ agentEntity: agentEntity });
    return super.mine(voxelTypeId, coord, abi.encode(MineEventData({ worldData: abi.encode(mineEventData) })));
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal override {
    super.preRunCA(caAddress, voxelTypeId, coord, eventVoxelEntity, eventData);
    // Call simulator mass change
    uint256 currentMass = Mass.get(
      IStore(SIMULATOR_ADDRESS),
      _world(),
      eventVoxelEntity.scale,
      eventVoxelEntity.entityId
    );
    if (currentMass > 0) {
      setSimValue(SIMULATOR_ADDRESS, SimTable.Mass, eventVoxelEntity, coord, currentMass, eventVoxelEntity, coord, 0);
    }
  }
}
