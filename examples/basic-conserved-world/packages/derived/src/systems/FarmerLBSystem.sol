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
import { Pokemon, PokemonData, PokemonTableId } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { Plant, PlantData, PlantStage } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { FarmLeaderboard, FarmLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { PlantDataWithEntity } from "@tenet-derived/src/Types.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-world/src/codegen/tables/OwnedBy.sol";

contract FarmerLBSystem is System {
  function claimFarmerShard(VoxelEntity memory farmerEntity) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);
    require(
      hasKey(worldStore, OwnedByTableId, OwnedBy.encodeKeyTuple(farmerEntity.scale, farmerEntity.entityId)) &&
        OwnedBy.get(worldStore, farmerEntity.scale, farmerEntity.entityId) == _msgSender(),
      "You do not own this entity"
    );
    VoxelCoord memory coord = getVoxelCoordStrict(worldStore, farmerEntity);
    VoxelCoord memory shardCoord = coordToShardCoord(coord);
    require(
      !hasKey(FarmLeaderboardTableId, FarmLeaderboard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)),
      "FarmerLBSystem: shard already claimed"
    );
    bytes32 farmerCAEntity = CAEntityMapping.getCaEntity(caStore, WORLD_ADDRESS, farmerEntity.entityId);
    bytes32[][] memory farmerLBEntities = getKeysInTable(FarmLeaderboardTableId);
    // Initial rank is the number of farmers + 1, ie last place
    FarmLeaderboard.set(shardCoord.x, shardCoord.y, shardCoord.z, farmerLBEntities.length + 1, 0, farmerCAEntity);
  }

  function updateFarmerLeaderboard() public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);

    // We reset the leaderboard
    bytes32[][] memory farmerLBEntities = getKeysInTable(FarmLeaderboardTableId);
    PlantDataWithEntity[] memory totalFarmerScore = new PlantDataWithEntity[](farmerLBEntities.length);
    // init shard coords
    for (uint i = 0; i < farmerLBEntities.length; i++) {
      totalFarmerScore[i] = PlantDataWithEntity({
        coord: VoxelCoord({
          x: int32(int256(uint256(farmerLBEntities[i][0]))),
          y: int32(int256(uint256(farmerLBEntities[i][1]))),
          z: int32(int256(uint256(farmerLBEntities[i][2])))
        }),
        totalProduced: 0
      });
    }

    // Get all pokemon entities
    bytes32[][] memory plantEntities = getKeysInTable(caStore, CAEntityReverseMappingTableId);

    for (uint i = 0; i < plantEntities.length; i++) {
      bytes32 plantEntity = plantEntities[i][0];
      if (Plant.getHasValue(caStore, WORLD_ADDRESS, plantEntity)) {
        VoxelCoord memory entityCoord = getCAEntityPositionStrict(caStore, plantEntity);
        VoxelCoord memory shardCoord = coordToShardCoord(entityCoord);
        // figure out the index of this shardCoord in farmerLBEntities
        for (uint j = 0; j < farmerLBEntities.length; j++) {
          if (
            shardCoord.x == int32(int256(uint256(farmerLBEntities[j][0]))) &&
            shardCoord.y == int32(int256(uint256(farmerLBEntities[j][1]))) &&
            shardCoord.z == int32(int256(uint256(farmerLBEntities[j][2])))
          ) {
            totalFarmerScore[j].totalProduced += Plant.getTotalProduced(caStore, WORLD_ADDRESS, plantEntity);
            break;
          }
        }
      }
    }

    bool swapped = false;
    // Sort the totalFarmerScore data array based on numWins
    for (uint i = 0; i < totalFarmerScore.length; i++) {
      swapped = false;
      for (uint j = i + 1; j < totalFarmerScore.length; j++) {
        if (totalFarmerScore[i].totalProduced < totalFarmerScore[j].totalProduced) {
          // Swap
          PlantDataWithEntity memory temp = totalFarmerScore[i];
          totalFarmerScore[i] = totalFarmerScore[j];
          totalFarmerScore[j] = temp;
          swapped = true;
        }
      }
      if (!swapped) {
        break;
      }
    }

    // Now, the rank of the shard coord is just its index + 1 in the sorted array
    for (uint i = 0; i < totalFarmerScore.length; i++) {
      uint rank = i + 1;
      FarmLeaderboard.set(
        totalFarmerScore[i].coord.x,
        totalFarmerScore[i].coord.y,
        totalFarmerScore[i].coord.z,
        rank,
        totalFarmerScore[i].totalProduced,
        FarmLeaderboard.getFarmerCAEntity(
          totalFarmerScore[i].coord.x,
          totalFarmerScore[i].coord.y,
          totalFarmerScore[i].coord.z
        )
      );
    }
  }
}
