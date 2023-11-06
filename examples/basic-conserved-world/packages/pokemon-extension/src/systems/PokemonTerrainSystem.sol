// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { ABDKMath64x64 as Math } from "@tenet-utils/src/libraries/ABDKMath64x64.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { VoxelCoord, TerrainData } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { AirVoxelID, GrassVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, DiffusiveSoilVoxelID, ConcentrativeSoilVoxelID, ProteinSoilVoxelID, ElixirSoilVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { SHARD_DIM } from "@tenet-utils/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { callOrRevert, staticCallOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { console } from "forge-std/console.sol";

int32 constant Y_AIR_THRESHOLD = 10;
int32 constant Y_GROUND_THRESHOLD = 5;

uint256 constant AIR_BUCKET_INDEX = 0;
uint256 constant SOIL_1_BUCKET_INDEX = 1;
uint256 constant SOIL_2_BUCKET_INDEX = 2;
uint256 constant SOIL_3_BUCKET_INDEX = 3;
uint256 constant SOIL_4_BUCKET_INDEX = 4;
uint256 constant GRASS_BUCKET_INDEX = 5;

string constant CLAIM_SHARD_SIG = "claimShard((int32,int32,int32),address,bytes4,bytes4,(uint256,uint256,uint256,uint256,uint256,uint256)[],(int32,int32,int32))";

contract PokemonTerrainSystem is System {
  function initPokemonTerrain(address worldAddress) public {
    VoxelCoord[4] memory spawnCoords = [
      VoxelCoord({ x: 300, y: 0, z: 0 }),
      VoxelCoord({ x: 200, y: 0, z: 0 }),
      VoxelCoord({ x: 300, y: 0, z: -100 }),
      VoxelCoord({ x: 200, y: 0, z: -100 })
    ];
    // First shard
    VoxelCoord memory firstFaucetAgentCoord = VoxelCoord({ x: 354, y: 5, z: 64 });
    callOrRevert(
      worldAddress,
      abi.encodeWithSignature(
        CLAIM_SHARD_SIG,
        spawnCoords[0],
        _world(),
        IWorld(_world()).pokemon_PokemonTerrainSy_getPokemonVoxelType.selector,
        firstFaucetAgentCoord
      ),
      "claimShard Pokemon 1"
    );

    // Second shard
    VoxelCoord memory secondFaucetAgentCoord = VoxelCoord({ x: 261, y: 10, z: 65 });
    callOrRevert(
      worldAddress,
      abi.encodeWithSignature(
        CLAIM_SHARD_SIG,
        spawnCoords[1],
        _world(),
        IWorld(_world()).pokemon_PokemonTerrainSy_getPokemonVoxelType.selector,
        secondFaucetAgentCoord
      ),
      "claimShard Pokemon 2"
    );

    // Third shard
    VoxelCoord memory thirdFaucetAgentCoord = VoxelCoord({ x: 374, y: 10, z: -60 });
    callOrRevert(
      worldAddress,
      abi.encodeWithSignature(
        CLAIM_SHARD_SIG,
        spawnCoords[2],
        _world(),
        IWorld(_world()).pokemon_PokemonTerrainSy_getPokemonVoxelType.selector,
        thirdFaucetAgentCoord
      ),
      "claimShard Pokemon 3"
    );

    // Fourth shard
    VoxelCoord memory fourthFaucetAgentCoord = VoxelCoord({ x: 240, y: 5, z: -59 });
    callOrRevert(
      worldAddress,
      abi.encodeWithSignature(
        CLAIM_SHARD_SIG,
        spawnCoords[3],
        _world(),
        IWorld(_world()).pokemon_PokemonTerrainSy_getPokemonVoxelType.selector,
        fourthFaucetAgentCoord
      ),
      "claimShard Pokemon 4"
    );
  }

  function getPokemonBucketIndexShard1(VoxelCoord memory coord) public view returns (uint256) {
    VoxelCoord memory shardCoord = coordToShardCoord(coord);

    int256 airGroundDenom = 75;
    int256 soilGrassDenom = 20;

    uint8 precision = 64;

    bool isAir = coord.y >= shardCoord.y * SHARD_DIM + Y_AIR_THRESHOLD;
    bool isGround = coord.y < shardCoord.y * SHARD_DIM + Y_GROUND_THRESHOLD;
    int128 airGroundNoise = !isAir && !isGround
      ? IWorld(_world()).pokemon_PerlinSystem_noise(coord.x, coord.y, coord.z, airGroundDenom, precision)
      : int128(0);
    bool isTerrain = !isAir && !isGround && airGroundNoise > Math.div(1, 2);

    if (isTerrain || isGround) {
      int128 massNoise = IWorld(_world()).pokemon_PerlinSystem_noise(
        coord.x,
        coord.y,
        coord.z,
        soilGrassDenom,
        precision
      );

      if (massNoise <= Math.div(1, 5)) {
        return SOIL_1_BUCKET_INDEX;
      } else if (massNoise > Math.div(1, 5) && massNoise <= Math.div(2, 5)) {
        if (massNoise > Math.div(1, 5) && massNoise <= Math.div(27, 100)) {
          return SOIL_1_BUCKET_INDEX;
        } else if (massNoise > Math.div(27, 100) && massNoise <= Math.div(34, 100)) {
          return SOIL_3_BUCKET_INDEX;
        } else {
          return SOIL_2_BUCKET_INDEX;
        }
      } else if (massNoise > Math.div(2, 5) && massNoise <= Math.div(3, 5)) {
        if (massNoise > Math.div(2, 5) && massNoise <= Math.div(47, 100)) {
          return SOIL_1_BUCKET_INDEX;
        } else if (massNoise > Math.div(47, 100) && massNoise <= Math.div(54, 100)) {
          return GRASS_BUCKET_INDEX;
        } else {
          return SOIL_3_BUCKET_INDEX;
        }
      } else if (massNoise > Math.div(3, 5) && massNoise <= Math.div(4, 5)) {
        return SOIL_4_BUCKET_INDEX;
      } else {
        return GRASS_BUCKET_INDEX;
      }
    }

    return AIR_BUCKET_INDEX;
  }

  function getPokemonVoxelType(BucketData memory bucketData, VoxelCoord memory coord) public view returns (bytes32) {
    VoxelCoord memory shardCoord = coordToShardCoord(coord);

    if (bucketData.id == SOIL_1_BUCKET_INDEX) {
      return ProteinSoilVoxelID;
    } else if (bucketData.id == SOIL_2_BUCKET_INDEX) {
      return ElixirSoilVoxelID;
    } else if (bucketData.id == SOIL_3_BUCKET_INDEX) {
      return ConcentrativeSoilVoxelID;
    } else if (bucketData.id == SOIL_4_BUCKET_INDEX) {
      return DiffusiveSoilVoxelID;
    } else if (bucketData.id == GRASS_BUCKET_INDEX) {
      return GrassVoxelID;
    }

    return AirVoxelID;
  }
}
