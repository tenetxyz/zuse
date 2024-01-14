// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

import { MonumentsLeaderboard, MonumentsLeaderboardData, MonumentsLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { MonumentLikes, MonumentLikesTableId } from "@tenet-derived/src/codegen/Tables.sol";

import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { ObjectEntity, ObjectEntityTableId } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";

import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord } from "@tenet-base-world/src/Utils.sol";

import { WORLD_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int32ToUint32, uint32ToInt32 } from "@tenet-utils/src/TypeUtils.sol";
import { SHARD_DIM } from "@tenet-world/src/Constants.sol";

struct AreaLikes {
  int32 x;
  int32 y;
  int32 z;
  uint256 likes;
}

contract MonumentsLBSystem is System {
  // Note: we only support claiming 2D areas for now, ie all y values are ignored
  function claimMonumentsArea(
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
        coord.z >= lowerSouthwestCorner.z &&
        coord.x < lowerSouthwestCorner.x + size.x &&
        coord.z < lowerSouthwestCorner.z + size.z,
      "MonumentsLBSystem: Your agent is not within the selected area"
    );

    require(
      !hasKey(
        MonumentsLeaderboardTableId,
        MonumentsLeaderboard.encodeKeyTuple(lowerSouthwestCorner.x, 0, lowerSouthwestCorner.z)
      ),
      "MonumentsLBSystem: This area is already claimed"
    );

    VoxelCoord memory topNortheastCorner = VoxelCoord(
      lowerSouthwestCorner.x + size.x,
      0,
      lowerSouthwestCorner.z + size.z
    );

    // Check if the area overlaps with another claimed area
    uint256 numClaimedAreas = requireNoOverlap(lowerSouthwestCorner, topNortheastCorner);

    // TODO: Add spam protection to make it so a user doesn't claim too many areas

    MonumentsLeaderboard.set(
      lowerSouthwestCorner.x,
      0,
      lowerSouthwestCorner.z,
      MonumentsLeaderboardData({
        length: int32ToUint32(size.x),
        width: int32ToUint32(size.z),
        height: int32ToUint32(size.y),
        rank: numClaimedAreas + 1, // Initial rank is the number of claimed areas + 1, ie last place
        totalLikes: 0,
        owner: _msgSender(),
        agentObjectEntityId: agentObjectEntityId,
        likedBy: new address[](0)
      })
    );
  }

  // TODO: Find a more gas efficient way to check for overlap, maybe use ZK proofs
  function requireNoOverlap(
    VoxelCoord memory lowerCorner,
    VoxelCoord memory upperCorner
  ) internal view returns (uint256) {
    bytes32[][] memory monumentsLBEntities = getKeysInTable(MonumentsLeaderboardTableId);
    for (uint i = 0; i < monumentsLBEntities.length; i++) {
      int32 x = int32(int256(uint256(monumentsLBEntities[i][0])));
      int32 y = int32(int256(uint256(monumentsLBEntities[i][1])));
      int32 z = int32(int256(uint256(monumentsLBEntities[i][2])));
      uint32 length = MonumentsLeaderboard.getLength(x, y, z);
      uint32 width = MonumentsLeaderboard.getWidth(x, y, z);
      VoxelCoord memory compareLowerCorner = VoxelCoord(x, y, z);
      VoxelCoord memory compareUpperCorner = VoxelCoord(x + uint32ToInt32(length), y, z + uint32ToInt32(width));
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

  function likeMonumentsArea(VoxelCoord memory lowerSouthwestCorner, uint256 numLikes) public {
    require(
      hasKey(
        MonumentsLeaderboardTableId,
        MonumentsLeaderboard.encodeKeyTuple(lowerSouthwestCorner.x, lowerSouthwestCorner.y, lowerSouthwestCorner.z)
      ),
      "MonumentsLBSystem: This area is not claimed"
    );

    address areaOwner = MonumentsLeaderboard.getOwner(
      lowerSouthwestCorner.x,
      lowerSouthwestCorner.y,
      lowerSouthwestCorner.z
    );
    require(areaOwner != _msgSender(), "MonumentsLBSystem: You cannot like your own area");
    // TODO: require valid EOA

    if (numLikes == 0) {
      address[] memory likedByArray = MonumentsLeaderboard.getLikedBy(
        lowerSouthwestCorner.x,
        lowerSouthwestCorner.y,
        lowerSouthwestCorner.z
      );
      bool userFound = false;
      for (uint i = 0; i < likedByArray.length; i++) {
        if (likedByArray[i] == _msgSender()) {
          userFound = true;
          break;
        }
      }
      require(!userFound, "MonumentsLBSystem: User has already liked this area");

      // Create a new array with an additional slot and copy old array to new array
      address[] memory newLikedByArray = new address[](likedByArray.length + 1);
      for (uint i = 0; i < likedByArray.length; i++) {
        newLikedByArray[i] = likedByArray[i];
      }
      // Add new user to the last slot of the new array
      newLikedByArray[likedByArray.length] = _msgSender();
      MonumentsLeaderboard.setLikedBy(
        lowerSouthwestCorner.x,
        lowerSouthwestCorner.y,
        lowerSouthwestCorner.z,
        newLikedByArray
      );

      // Mint new like
      MonumentLikes.set(areaOwner, MonumentLikes.get(areaOwner) + 1);
    } else {
      require(MonumentLikes.get(_msgSender()) >= numLikes, "MonumentsLBSystem: You do not have enough likes");

      // transfer likes from sender to owner
      MonumentLikes.set(_msgSender(), MonumentLikes.get(_msgSender()) - numLikes);
      MonumentLikes.set(areaOwner, MonumentLikes.get(areaOwner) + numLikes);
    }

    uint256 totalLikes = MonumentsLeaderboard.getTotalLikes(
      lowerSouthwestCorner.x,
      lowerSouthwestCorner.y,
      lowerSouthwestCorner.z
    ) + (numLikes == 0 ? 1 : numLikes);
    MonumentsLeaderboard.setTotalLikes(
      lowerSouthwestCorner.x,
      lowerSouthwestCorner.y,
      lowerSouthwestCorner.z,
      totalLikes
    );
  }

  function updateMonumentsLeaderboard() public {
    bytes32[][] memory monumentsLBEntities = getKeysInTable(MonumentsLeaderboardTableId);
    if (monumentsLBEntities.length == 0) {
      return;
    }

    AreaLikes[] memory allAreaLikes = new AreaLikes[](monumentsLBEntities.length);

    for (uint256 i = 0; i < monumentsLBEntities.length; i++) {
      int32 x = int32(int256(uint256(monumentsLBEntities[i][0])));
      int32 y = int32(int256(uint256(monumentsLBEntities[i][1])));
      int32 z = int32(int256(uint256(monumentsLBEntities[i][2])));
      uint256 likes = MonumentsLeaderboard.getTotalLikes(x, y, z);

      allAreaLikes[i] = AreaLikes(x, y, z, likes);
    }

    // Sort the array based on likes using Bubble Sort
    bool swapped = false;
    for (uint256 i = 0; i < allAreaLikes.length - 1; i++) {
      swapped = false;
      for (uint256 j = 0; j < allAreaLikes.length - i - 1; j++) {
        if (allAreaLikes[j].likes < allAreaLikes[j + 1].likes) {
          // Swap
          AreaLikes memory temp = allAreaLikes[j];
          allAreaLikes[j] = allAreaLikes[j + 1];
          allAreaLikes[j + 1] = temp;
          swapped = true;
        }
      }
      if (!swapped) {
        break;
      }
    }

    for (uint256 i = 0; i < allAreaLikes.length; i++) {
      uint rank = i + 1;
      MonumentsLeaderboard.setRank(allAreaLikes[i].x, allAreaLikes[i].y, allAreaLikes[i].z, rank);
    }
  }
}
