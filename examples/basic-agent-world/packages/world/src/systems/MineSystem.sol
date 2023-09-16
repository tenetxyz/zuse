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
}
