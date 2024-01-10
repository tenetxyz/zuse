// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

import { BuildingLeaderboard, BuildingLeaderboardData, BuildingLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { ClaimedShard } from "@tenet-derived/src/codegen/Tables.sol";

import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { ObjectEntity, ObjectEntityTableId } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";

import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord } from "@tenet-base-world/src/Utils.sol";

import { WORLD_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { SHARD_DIM } from "@tenet-world/src/Constants.sol";

import { Creature, CreatureData } from "@tenet-creatures/src/codegen/tables/Creature.sol";
import { Plant, PlantData } from "@tenet-farming/src/codegen/tables/Plant.sol";
import { Farmer } from "@tenet-farming/src/codegen/tables/Farmer.sol";

struct EntityLikes {
  int32 x;
  int32 y;
  int32 z;
  uint256 likes;
}

contract MonumentsLBSystem is System {
  function claimBuildingShard(bytes32 agentObjectEntityId) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    require(
      hasKey(worldStore, OwnedByTableId, OwnedBy.encodeKeyTuple(agentObjectEntityId)) &&
        OwnedBy.get(worldStore, agentObjectEntityId) == _msgSender(),
      "MonumentsLBSystem: You do not own this entity"
    );
    VoxelCoord memory coord = getVoxelCoord(worldStore, agentObjectEntityId);
    VoxelCoord memory shardCoord = coordToShardCoord(coord, SHARD_DIM);
    require(
      !hasKey(BuildingLeaderboardTableId, BuildingLeaderboard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)),
      "MonumentsLBSystem: A builder already claimed this shard"
    );

    bytes32[][] memory buildingLikesEntities = getKeysInTable(BuildingLeaderboardTableId);

    // Initial rank is the number of buildings + 1, ie last place
    BuildingLeaderboard.set(
      shardCoord.x,
      shardCoord.y,
      shardCoord.z,
      BuildingLeaderboardData({
        rank: buildingLikesEntities.length + 1,
        totalLikes: 0,
        agentObjectEntityId: agentObjectEntityId,
        likedBy: new address[](0)
      })
    );

    ClaimedShard.set(agentObjectEntityId, abi.encode(shardCoord));
  }

  function likeShard(VoxelCoord memory coord) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    VoxelCoord memory shardCoord = coordToShardCoord(coord, SHARD_DIM);

    address[] memory likedByArray = BuildingLeaderboard.getLikedBy(shardCoord.x, shardCoord.y, shardCoord.z);
    bool userFound = false;
    for (uint i = 0; i < likedByArray.length; i++) {
      if (likedByArray[i] == _msgSender()) {
        userFound = true;
        break;
      }
    }
    require(!userFound, "MonumentsLBSystem: User already liked this shard");

    // Create a new array with an additional slot and Copy old array to new array
    address[] memory newLikedByArray = new address[](likedByArray.length + 1);
    for (uint i = 0; i < likedByArray.length; i++) {
      newLikedByArray[i] = likedByArray[i];
    }

    // Add new user to the last slot of the new array
    newLikedByArray[likedByArray.length] = _msgSender();
    uint256 totalLikes = BuildingLeaderboard.getTotalLikes(shardCoord.x, shardCoord.y, shardCoord.z) + 1;

    BuildingLeaderboard.set(
      shardCoord.x,
      shardCoord.y,
      shardCoord.z,
      BuildingLeaderboardData({
        rank: BuildingLeaderboard.getRank(shardCoord.x, shardCoord.y, shardCoord.z),
        totalLikes: totalLikes,
        agentObjectEntityId: BuildingLeaderboard.getAgentObjectEntityId(shardCoord.x, shardCoord.y, shardCoord.z),
        likedBy: newLikedByArray
      })
    );
  }

  function updateBuildingLeaderboard() public {
    IStore worldStore = IStore(WORLD_ADDRESS);

    bytes32[][] memory buildingLikesEntities = getKeysInTable(BuildingLeaderboardTableId);

    EntityLikes[] memory allEntitiesLikes = new EntityLikes[](buildingLikesEntities.length);

    for (uint i = 0; i < buildingLikesEntities.length; i++) {
      int32 x = int32(int256(uint256(buildingLikesEntities[i][0])));
      int32 y = int32(int256(uint256(buildingLikesEntities[i][1])));
      int32 z = int32(int256(uint256(buildingLikesEntities[i][2])));
      uint256 likes = BuildingLeaderboard.getTotalLikes(x, y, z);

      allEntitiesLikes[i] = EntityLikes(x, y, z, likes);
    }

    // Sort the array based on likes using Bubble Sort
    bool swapped = false;
    // TODO: Fix sort algorithm, it's not working
    for (uint i = 0; i < allEntitiesLikes.length; i++) {
      swapped = false;
      for (uint j = 0; j < allEntitiesLikes.length - i - 1; j++) {
        if (allEntitiesLikes[j].likes < allEntitiesLikes[j + 1].likes) {
          // Swap
          EntityLikes memory temp = allEntitiesLikes[j];
          allEntitiesLikes[j] = allEntitiesLikes[j + 1];
          allEntitiesLikes[j + 1] = temp;
          swapped = true;
        }
      }
      if (!swapped) {
        break;
      }
    }

    for (uint i = 0; i < allEntitiesLikes.length; i++) {
      uint rank = i + 1;
      BuildingLeaderboard.set(
        allEntitiesLikes[i].x,
        allEntitiesLikes[i].y,
        allEntitiesLikes[i].z,
        BuildingLeaderboardData({
          rank: rank,
          totalLikes: allEntitiesLikes[i].likes,
          agentObjectEntityId: BuildingLeaderboard.getAgentObjectEntityId(
            allEntitiesLikes[i].x,
            allEntitiesLikes[i].y,
            allEntitiesLikes[i].z
          ),
          likedBy: BuildingLeaderboard.getLikedBy(allEntitiesLikes[i].x, allEntitiesLikes[i].y, allEntitiesLikes[i].z)
        })
      );
    }
  }
}
