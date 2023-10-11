// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { ABDKMath64x64 as Math } from "@tenet-utils/src/libraries/ABDKMath64x64.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { VoxelCoord, BucketData } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { AirVoxelID, GrassVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, SoilVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { SHARD_DIM } from "@tenet-utils/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { console } from "forge-std/console.sol";

int32 constant Y_AIR_THRESHOLD = 10;
int32 constant Y_GROUND_THRESHOLD = 5;

uint256 constant AIR_BUCKET_INDEX = 0;
uint256 constant SOIL_BUCKET_INDEX = 1;
uint256 constant GRASS_BUCKET_INDEX = 2;

string constant CLAIM_SHARD_SIG = "claimShard((int32,int32,int32),address,bytes4,bytes4,(uint256,uint256,uint256,uint256,uint256,uint256)[],(int32,int32,int32))";

contract PokemonTerrainSystem is System {
  function initPokemonTerrain(address worldAddress) public {
    VoxelCoord[4] memory spawnCoords = [
      VoxelCoord({ x: 3, y: 0, z: 0 }),
      VoxelCoord({ x: 2, y: 0, z: 0 }),
      VoxelCoord({ x: 3, y: 0, z: -1 }),
      VoxelCoord({ x: 2, y: 0, z: -1 })
    ];
    uint256[] memory bucketCounts = new uint256[](spawnCoords.length);

    BucketData[] memory pokemonBuckets = new BucketData[](3);
    pokemonBuckets[AIR_BUCKET_INDEX] = BucketData({
      id: 0,
      minMass: 0,
      maxMass: 0,
      energy: 0,
      count: 0,
      actualCount: 0
    });
    pokemonBuckets[SOIL_BUCKET_INDEX] = BucketData({
      id: 1,
      minMass: 1,
      maxMass: 50,
      energy: 100,
      count: 0,
      actualCount: 0
    });
    pokemonBuckets[GRASS_BUCKET_INDEX] = BucketData({
      id: 2,
      minMass: 1,
      maxMass: 50,
      energy: 100,
      count: 0,
      actualCount: 0
    });

    // First shard
    pokemonBuckets[AIR_BUCKET_INDEX].count = 933251;
    pokemonBuckets[SOIL_BUCKET_INDEX].count = 59172;
    pokemonBuckets[GRASS_BUCKET_INDEX].count = 7577;
    VoxelCoord memory firstFaucetAgentCoord = VoxelCoord({ x: 354, y: 5, z: 64 });
    safeCall(
      worldAddress,
      abi.encodeWithSignature(
        CLAIM_SHARD_SIG,
        spawnCoords[0],
        _world(),
        IWorld(_world()).pokemon_PokemonTerrainSy_getPokemonVoxelType.selector,
        IWorld(_world()).pokemon_PokemonTerrainSy_getPokemonBucketIndex.selector,
        pokemonBuckets,
        firstFaucetAgentCoord
      ),
      "claimShard Pokemon 1"
    );

    // Second shard
    pokemonBuckets[AIR_BUCKET_INDEX].count = 928814;
    pokemonBuckets[SOIL_BUCKET_INDEX].count = 60229;
    pokemonBuckets[GRASS_BUCKET_INDEX].count = 10957;
    VoxelCoord memory secondFaucetAgentCoord = VoxelCoord({ x: 261, y: 10, z: 65 });
    safeCall(
      worldAddress,
      abi.encodeWithSignature(
        CLAIM_SHARD_SIG,
        spawnCoords[1],
        _world(),
        IWorld(_world()).pokemon_PokemonTerrainSy_getPokemonVoxelType.selector,
        IWorld(_world()).pokemon_PokemonTerrainSy_getPokemonBucketIndex.selector,
        pokemonBuckets,
        secondFaucetAgentCoord
      ),
      "claimShard Pokemon 2"
    );

    // Third shard
    pokemonBuckets[AIR_BUCKET_INDEX].count = 933251;
    pokemonBuckets[SOIL_BUCKET_INDEX].count = 59172;
    pokemonBuckets[GRASS_BUCKET_INDEX].count = 7577;
    VoxelCoord memory thirdFaucetAgentCoord = VoxelCoord({ x: 374, y: 10, z: -60 });
    safeCall(
      worldAddress,
      abi.encodeWithSignature(
        CLAIM_SHARD_SIG,
        spawnCoords[2],
        _world(),
        IWorld(_world()).pokemon_PokemonTerrainSy_getPokemonVoxelType.selector,
        IWorld(_world()).pokemon_PokemonTerrainSy_getPokemonBucketIndex.selector,
        pokemonBuckets,
        thirdFaucetAgentCoord
      ),
      "claimShard Pokemon 3"
    );

    // Fourth shard
    pokemonBuckets[AIR_BUCKET_INDEX].count = 928814;
    pokemonBuckets[SOIL_BUCKET_INDEX].count = 60229;
    pokemonBuckets[GRASS_BUCKET_INDEX].count = 10957;
    VoxelCoord memory fourthFaucetAgentCoord = VoxelCoord({ x: 240, y: 5, z: 59 });
    safeCall(
      worldAddress,
      abi.encodeWithSignature(
        CLAIM_SHARD_SIG,
        spawnCoords[3],
        _world(),
        IWorld(_world()).pokemon_PokemonTerrainSy_getPokemonVoxelType.selector,
        IWorld(_world()).pokemon_PokemonTerrainSy_getPokemonBucketIndex.selector,
        pokemonBuckets,
        fourthFaucetAgentCoord
      ),
      "claimShard Pokemon 4"
    );
  }

  function getPokemonBucketIndex(VoxelCoord memory coord) public view returns (uint256) {
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

    if (isGround) {
      return SOIL_BUCKET_INDEX;
    }

    if (isTerrain) {
      int128 massNoise = IWorld(_world()).pokemon_PerlinSystem_noise(
        coord.x,
        coord.y,
        coord.z,
        soilGrassDenom,
        precision
      );
      if (massNoise > Math.div(1, 2)) {
        return GRASS_BUCKET_INDEX;
      } else {
        return SOIL_BUCKET_INDEX;
      }
    }

    return AIR_BUCKET_INDEX;
  }

  function getPokemonVoxelType(BucketData memory bucketData, VoxelCoord memory coord) public view returns (bytes32) {
    VoxelCoord memory shardCoord = coordToShardCoord(coord);

    if (bucketData.id == SOIL_BUCKET_INDEX) {
      return SoilVoxelID;
    } else if (bucketData.id == GRASS_BUCKET_INDEX) {
      return GrassVoxelID;
    }

    return AirVoxelID;
  }
}
