// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { CAEntityReverseMapping, CAEntityReverseMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, BodySimData } from "@tenet-utils/src/Types.sol";
import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeTableId } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { WORLD_ADDRESS, BASE_CA_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { getEntitySimData } from "@tenet-world/src/CallUtils.sol";
import { getEntityAtCoord, getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";
import { getNeighbourEntities } from "@tenet-simulator/src/Utils.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { console } from "forge-std/console.sol";
import { BuildingLeaderboard, BuildingLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-world/src/codegen/tables/OwnedBy.sol";
import { FarmDeliveryLeaderboard, FarmDeliveryLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { ClaimedShards } from "@tenet-derived/src/codegen/Tables.sol";

struct EntityLikes {
  int32 x;
  int32 y;
  int32 z;
  uint256 likes;
}

contract BuildingLikesSystem is System {
  function claimBuildingShard(VoxelEntity memory agentEntity) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);
    require(
      hasKey(worldStore, OwnedByTableId, OwnedBy.encodeKeyTuple(agentEntity.scale, agentEntity.entityId)) &&
        OwnedBy.get(worldStore, agentEntity.scale, agentEntity.entityId) == _msgSender(),
      "You do not own this entity"
    );
    VoxelCoord memory coord = getVoxelCoordStrict(worldStore, agentEntity);
    VoxelCoord memory shardCoord = coordToShardCoord(coord);
    require(
      !hasKey(BuildingLeaderboardTableId, BuildingLeaderboard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)),
      "BuildingLikesSystem: A builder already claimed this shard"
    );

    bytes32 agentCAEntity = CAEntityMapping.get(caStore, WORLD_ADDRESS, agentEntity.entityId);
    bytes32[][] memory buildingLikesEntities = getKeysInTable(BuildingLeaderboardTableId);
    address[] memory emptyArray = new address[](0);

    // Initial rank is the number of buildings + 1, ie last place
    BuildingLeaderboard.set(
      shardCoord.x,
      shardCoord.y,
      shardCoord.z,
      buildingLikesEntities.length + 1,
      0,
      agentCAEntity,
      emptyArray
    );

    bytes memory chaimedShardsBytes = ClaimedShards.get(agentCAEntity);
    VoxelCoord[] memory claimedShards = abi.decode(chaimedShardsBytes, (VoxelCoord[]));
    VoxelCoord[] memory newClaimedShards = new VoxelCoord[](claimedShards.length + 1);
    for (uint64 i = 0; i < claimedShards.length; i++) {
      newClaimedShards[i] = claimedShards[i];
    }
    newClaimedShards[claimedShards.length] = shardCoord;

    ClaimedShards.set(agentCAEntity, abi.encode(newClaimedShards));
  }

  function likeShard(address user, VoxelCoord memory coord) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);
    VoxelCoord memory shardCoord = coordToShardCoord(coord);

    address[] memory likedByArray = BuildingLeaderboard.getLikedBy(shardCoord.x, shardCoord.y, shardCoord.z);
    bool userFound = false;
    for (uint i = 0; i < likedByArray.length; i++) {
      if (likedByArray[i] == user) {
        userFound = true;
        break;
      }
    }
    require(!userFound, "User already liked this shard");

    //Create a new array with an additional slot and Copy old array to new array
    address[] memory newLikedByArray = new address[](likedByArray.length + 1);
    for (uint i = 0; i < likedByArray.length; i++) {
      newLikedByArray[i] = likedByArray[i];
    }

    // Add new user to the last slot of the new array
    newLikedByArray[likedByArray.length] = user;
    uint256 totalLikes = BuildingLeaderboard.getTotalLikes(shardCoord.x, shardCoord.y, shardCoord.z) + 1;

    BuildingLeaderboard.set(
      shardCoord.x,
      shardCoord.y,
      shardCoord.z,
      BuildingLeaderboard.getRank(shardCoord.x, shardCoord.y, shardCoord.z),
      totalLikes,
      BuildingLeaderboard.getAgentEntity(shardCoord.x, shardCoord.y, shardCoord.z),
      newLikedByArray
    );
  }

  function updateBuildingLeaderboard() public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);

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
      console.log("set rank");
      BuildingLeaderboard.set(
        allEntitiesLikes[i].x,
        allEntitiesLikes[i].y,
        allEntitiesLikes[i].z,
        rank,
        allEntitiesLikes[i].likes,
        BuildingLeaderboard.getAgentEntity(allEntitiesLikes[i].x, allEntitiesLikes[i].y, allEntitiesLikes[i].z),
        BuildingLeaderboard.getLikedBy(allEntitiesLikes[i].x, allEntitiesLikes[i].y, allEntitiesLikes[i].z)
      );
    }
  }
}
