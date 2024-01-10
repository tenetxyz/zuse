// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

import { MonumentsLeaderboard, MonumentsLeaderboardData, MonumentsLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";
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
  // Note: we only support claiming 2D areas for now, ie all y values are ignored
  function claimArea(
    bytes32 agentObjectEntityId,
    VoxelCoord memory lowerSouthwestCorner,
    VoxelCoord memory size
  ) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    require(
      OwnedBy.get(worldStore, agentObjectEntityId) == _msgSender(),
      "MonumentsLBSystem: You do not own this agent"
    );
    VoxelCoord memory coord = getVoxelCoord(worldStore, agentObjectEntityId);

    // Check coord is within the area
    require(
      coord.x >= lowerSouthwestCorner.x &&
        coord.y >= lowerSouthwestCorner.y &&
        coord.z >= lowerSouthwestCorner.z &&
        coord.x < lowerSouthwestCorner.x + size.x &&
        coord.y < lowerSouthwestCorner.y + size.y &&
        coord.z < lowerSouthwestCorner.z + size.z,
      "MonumentsLBSystem: Your agent is not within the selected area"
    );

    require(
      !hasKey(
        MonumentsLeaderboardTableId,
        MonumentsLeaderboard.encodeKeyTuple(lowerSouthwestCorner.x, lowerSouthwestCorner.y, lowerSouthwestCorner.z)
      ),
      "MonumentsLBSystem: This area is already claimed"
    );

    VoxelCoord memory topNortheastCorner = VoxelCoord(
      lowerSouthwestCorner.x + size.x,
      lowerSouthwestCorner.y + size.y,
      lowerSouthwestCorner.z + size.z
    );

    // Check if the area overlaps with another claimed area
    uint256 numClaimedAreas = requireNoOverlap(lowerSouthwestCorner, topNortheastCorner);

    // TODO: Add spam protection to make it so a user doesn't claim too many areas

    MonumentsLeaderboard.set(
      lowerSouthwestCorner.x,
      lowerSouthwestCorner.y,
      lowerSouthwestCorner.z,
      MonumentsLeaderboardData({
        length: size.x,
        width: size.z,
        height: size.y,
        rank: numClaimedAreas + 1, // Initial rank is the number of claimed areas + 1, ie last place
        totalLikes: 0,
        owner: _msgSender(),
        agentObjectEntityId: agentObjectEntityId,
        likedBy: new address[](0)
      })
    );
  }

  // TODO: Find a more gas efficient way to check for overlap, maybe use ZK proofs
  function requireNoOverlap(VoxelCoord memory lowerCorner, VoxelCoord memory upperCorner) internal returns (uint256) {
    bytes32[][] memory monumentsLBEntities = getKeysInTable(MonumentsLeaderboardTableId);
    for (uint i = 0; i < monumentsLBEntities.length; i++) {
      int32 x = int32(int256(uint256(monumentsLBEntities[i][0])));
      int32 y = int32(int256(uint256(monumentsLBEntities[i][1])));
      int32 z = int32(int256(uint256(monumentsLBEntities[i][2])));
      uint32 length = MonumentsLeaderboard.getLength(x, y, z);
      uint32 width = MonumentsLeaderboard.getWidth(x, y, z);
      VoxelCoord memory compareLowerCorner = VoxelCoord(x, y, z);
      VoxelCoord memory compareUpperCorner = VoxelCoord(x + length, y, z + width);
      // Check if the area overlaps with the claimed area
      if (
        !(upperCorner.x <= compareLowerCorner.x || // to the left of
          lowerCorner.x >= compareUpperCorner.x || // to the right of
          lowerCorner.z >= compareUpperCorner.z || // above
          upperCorner.z <= compareLowerCorner.z) // below
      ) {
        revert("MonumentsLBSystem: This area overlaps with another claimed area");
      }
    }
    return monumentsLBEntities.length;
  }

  // function likeShard(VoxelCoord memory coord) public {
  //   IStore worldStore = IStore(WORLD_ADDRESS);
  //   VoxelCoord memory shardCoord = coordToShardCoord(coord, SHARD_DIM);

  //   address[] memory likedByArray = MonumentsLeaderboard.getLikedBy(shardCoord.x, shardCoord.y, shardCoord.z);
  //   bool userFound = false;
  //   for (uint i = 0; i < likedByArray.length; i++) {
  //     if (likedByArray[i] == _msgSender()) {
  //       userFound = true;
  //       break;
  //     }
  //   }
  //   require(!userFound, "MonumentsLBSystem: User already liked this shard");

  //   // Create a new array with an additional slot and Copy old array to new array
  //   address[] memory newLikedByArray = new address[](likedByArray.length + 1);
  //   for (uint i = 0; i < likedByArray.length; i++) {
  //     newLikedByArray[i] = likedByArray[i];
  //   }

  //   // Add new user to the last slot of the new array
  //   newLikedByArray[likedByArray.length] = _msgSender();
  //   uint256 totalLikes = MonumentsLeaderboard.getTotalLikes(shardCoord.x, shardCoord.y, shardCoord.z) + 1;

  //   MonumentsLeaderboard.set(
  //     shardCoord.x,
  //     shardCoord.y,
  //     shardCoord.z,
  //     MonumentsLeaderboardData({
  //       rank: MonumentsLeaderboard.getRank(shardCoord.x, shardCoord.y, shardCoord.z),
  //       totalLikes: totalLikes,
  //       agentObjectEntityId: MonumentsLeaderboard.getAgentObjectEntityId(shardCoord.x, shardCoord.y, shardCoord.z),
  //       likedBy: newLikedByArray
  //     })
  //   );
  // }

  // function updateMonumentsLeaderboard() public {
  //   IStore worldStore = IStore(WORLD_ADDRESS);

  //   bytes32[][] memory buildingLikesEntities = getKeysInTable(MonumentsLeaderboardTableId);

  //   EntityLikes[] memory allEntitiesLikes = new EntityLikes[](buildingLikesEntities.length);

  //   for (uint i = 0; i < buildingLikesEntities.length; i++) {
  //     int32 x = int32(int256(uint256(buildingLikesEntities[i][0])));
  //     int32 y = int32(int256(uint256(buildingLikesEntities[i][1])));
  //     int32 z = int32(int256(uint256(buildingLikesEntities[i][2])));
  //     uint256 likes = MonumentsLeaderboard.getTotalLikes(x, y, z);

  //     allEntitiesLikes[i] = EntityLikes(x, y, z, likes);
  //   }

  //   // Sort the array based on likes using Bubble Sort
  //   bool swapped = false;
  //   // TODO: Fix sort algorithm, it's not working
  //   for (uint i = 0; i < allEntitiesLikes.length; i++) {
  //     swapped = false;
  //     for (uint j = 0; j < allEntitiesLikes.length - i - 1; j++) {
  //       if (allEntitiesLikes[j].likes < allEntitiesLikes[j + 1].likes) {
  //         // Swap
  //         EntityLikes memory temp = allEntitiesLikes[j];
  //         allEntitiesLikes[j] = allEntitiesLikes[j + 1];
  //         allEntitiesLikes[j + 1] = temp;
  //         swapped = true;
  //       }
  //     }
  //     if (!swapped) {
  //       break;
  //     }
  //   }

  //   for (uint i = 0; i < allEntitiesLikes.length; i++) {
  //     uint rank = i + 1;
  //     MonumentsLeaderboard.set(
  //       allEntitiesLikes[i].x,
  //       allEntitiesLikes[i].y,
  //       allEntitiesLikes[i].z,
  //       MonumentsLeaderboardData({
  //         rank: rank,
  //         totalLikes: allEntitiesLikes[i].likes,
  //         agentObjectEntityId: MonumentsLeaderboard.getAgentObjectEntityId(
  //           allEntitiesLikes[i].x,
  //           allEntitiesLikes[i].y,
  //           allEntitiesLikes[i].z
  //         ),
  //         likedBy: MonumentsLeaderboard.getLikedBy(allEntitiesLikes[i].x, allEntitiesLikes[i].y, allEntitiesLikes[i].z)
  //       })
  //     );
  //   }
  // }
}
