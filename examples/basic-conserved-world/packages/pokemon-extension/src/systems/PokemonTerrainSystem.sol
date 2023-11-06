// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { ABDKMath64x64 as Math } from "@tenet-utils/src/libraries/ABDKMath64x64.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { VoxelCoord, TerrainData, TerrainSectionData } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { AirVoxelID, GrassVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, DiffusiveSoilVoxelID, ConcentrativeSoilVoxelID, ProteinSoilVoxelID, ElixirSoilVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { SHARD_DIM } from "@tenet-utils/src/Constants.sol";
import { coordToShardCoord, voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
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

string constant CLAIM_SHARD_SIG = "claimShard((int32,int32,int32),address,bytes4,(int32,int32,int32))";
bytes32 constant StoneVoxelId = bytes32(keccak256("stone"));

contract PokemonTerrainSystem is System {
  function initPokemonTerrain(address worldAddress) public {
    VoxelCoord[4] memory spawnCoords = [
      VoxelCoord({ x: 300, y: 0, z: 0 }),
      VoxelCoord({ x: 200, y: 0, z: 0 }),
      VoxelCoord({ x: 300, y: 0, z: -100 }),
      VoxelCoord({ x: 200, y: 0, z: -100 })
    ];
    // First shard
    VoxelCoord memory firstFaucetAgentCoord = VoxelCoord({ x: 384, y: 9, z: 63 });
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
    VoxelCoord memory secondFaucetAgentCoord = VoxelCoord({ x: 247, y: 8, z: 86 });
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
    VoxelCoord memory thirdFaucetAgentCoord = VoxelCoord({ x: 386, y: 6, z: -44 });
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
    VoxelCoord memory fourthFaucetAgentCoord = VoxelCoord({ x: 257, y: 11, z: -88 });
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

  function getCustomSections() internal pure returns (TerrainSectionData[] memory) {
    TerrainSectionData[] memory customSections = new TerrainSectionData[](5);
    customSections[0] = TerrainSectionData({
      useExistingBlock: false,
      voxelTypeId: StoneVoxelId,
      energy: 10,
      xCorner: 290,
      yCorner: 0,
      zCorner: -10,
      xLength: 20,
      zLength: 20,
      yLength: SHARD_DIM,
      includeAir: false
    });
    customSections[1] = TerrainSectionData({
      useExistingBlock: true,
      voxelTypeId: AirVoxelID,
      energy: 500,
      xCorner: 200,
      yCorner: 9,
      zCorner: -100,
      xLength: 20,
      zLength: 20,
      yLength: 15,
      includeAir: true
    });
    customSections[2] = TerrainSectionData({
      useExistingBlock: true,
      voxelTypeId: AirVoxelID,
      energy: 500,
      xCorner: 380,
      yCorner: 9,
      zCorner: 80,
      xLength: 20,
      zLength: 20,
      yLength: 15,
      includeAir: true
    });
    customSections[3] = TerrainSectionData({
      useExistingBlock: true,
      voxelTypeId: AirVoxelID,
      energy: 500,
      xCorner: 200,
      yCorner: 8,
      zCorner: 80,
      xLength: 20,
      zLength: 20,
      yLength: 15,
      includeAir: true
    });
    customSections[4] = TerrainSectionData({
      useExistingBlock: true,
      voxelTypeId: AirVoxelID,
      energy: 500,
      xCorner: 380,
      yCorner: 15,
      zCorner: -100,
      xLength: 20,
      zLength: 20,
      yLength: 15,
      includeAir: true
    });
    return customSections;
  }

  function getPokemonVoxelType(VoxelCoord memory coord) public view returns (TerrainData memory) {
    VoxelCoord memory shardCoord = coordToShardCoord(coord);

    bool isTerrain = false;
    {
      // Adjust the scale for the Perlin noise based on your shard size and preference for terrain variation.
      int128 noiseScale = Math.div(85, 100); // Smaller for smoother/larger hills, larger for more frequent/smaller hills.
      int128 heightScaleFactor = 25; // The maximum height difference in your terrain.

      int128 shiftedX = coord.x + 20;
      int128 shiftedZ = coord.z + 15;

      // Generate the Perlin noise value for the current x, z coordinate within the shard.
      int128 noiseValue = IWorld(_world()).pokemon_PerlinSystem_noise(
        shiftedX * noiseScale,
        0, // You can optionally include y to add some vertical variation.
        shiftedZ * noiseScale,
        50, // Denominator can be adjusted if necessary to scale the noise frequency.
        64 // precision
      );

      // Calculate the height at the current x, z coordinate within the shard.
      int128 heightAtCoord = (shardCoord.y * SHARD_DIM) + (noiseValue * heightScaleFactor);

      // Determine if the current voxel is terrain (stone) or air.
      isTerrain = coord.y <= heightAtCoord;
    }

    if (isTerrain) {
      int128 distanceFromCenter;
      // Define the radius of the central soil area
      int128 soilRadius = 35;

      {
        // Calculate local coordinates within the shard
        int128 localX = coord.x - shardCoord.x * SHARD_DIM;
        int128 localZ = coord.z - shardCoord.z * SHARD_DIM;

        // Calculate the center point of the shard
        int128 centerX = SHARD_DIM / 2;
        int128 centerZ = SHARD_DIM / 2;

        // Calculate the distance of the voxel from the center of the shard
        distanceFromCenter = Math.sqrt(Math.pow(localX - centerX, 2) + Math.pow(localZ - centerZ, 2));
      }

      // Check if the voxel is within the central region (soil)
      bool isInCentralRegion = distanceFromCenter <= soilRadius;

      // Determine the voxel type based on the region
      if (!isInCentralRegion) {
        TerrainSectionData[] memory customSections = getCustomSections();
        for (uint256 i = 0; i < customSections.length; i++) {
          TerrainSectionData memory section = customSections[i];
          // Check if the current coordinates are within a custom section.
          bool isInCustomSection = coord.x >= section.xCorner &&
            coord.x < section.xCorner + section.xLength &&
            coord.z >= section.zCorner &&
            coord.z < section.zCorner + section.zLength &&
            coord.y >= section.yCorner &&
            coord.y < section.yCorner + section.yLength;

          // If it's within the custom section, return the corresponding bucket.
          if (isInCustomSection) {
            return
              TerrainData({
                voxelTypeId: section.useExistingBlock ? GrassVoxelID : section.voxelTypeId,
                energy: section.energy
              });
          }
        }

        return TerrainData({ voxelTypeId: GrassVoxelID, energy: 50 });
      } else {
        // Define a scale for the noise to determine the fuzziness of the border
        int128 borderFuzzinessScale = Math.div(1, 2);

        // Adjust the noise value to be between 0 and some maximum border variation width
        int128 maxBorderVariation = 10; // Max additional variation for the border width

        // Voxel is in the central region or the rest of the terrain region
        // Generate a noise value for the current position to add variation to the border
        int128 borderNoiseValue = IWorld(_world()).pokemon_PerlinSystem_noise(
          coord.x * borderFuzzinessScale,
          coord.y, // Y can be used or not, depending on whether you want vertical variation
          coord.z * borderFuzzinessScale,
          1,
          64 // precision
        );

        // Calculate the effective border width with noise variation
        int128 borderVariation = borderNoiseValue * maxBorderVariation;
        int128 effectiveRadius = soilRadius - borderVariation; // Use subtraction to make border fuzzy

        // Determine if the current position is within the fuzzy border
        bool isInFuzzyBorder = distanceFromCenter > effectiveRadius;
        if (isInFuzzyBorder) {
          return TerrainData({ voxelTypeId: GrassVoxelID, energy: 50 });
        } else {
          // Voxel is in the central region
          if (voxelCoordsAreEqual(shardCoord, VoxelCoord({ x: 3, y: 0, z: 0 }))) {
            return TerrainData({ voxelTypeId: ProteinSoilVoxelID, energy: 200 });
          } else if (voxelCoordsAreEqual(shardCoord, VoxelCoord({ x: 2, y: 0, z: 0 }))) {
            return TerrainData({ voxelTypeId: ElixirSoilVoxelID, energy: 200 });
          } else if (voxelCoordsAreEqual(shardCoord, VoxelCoord({ x: 3, y: 0, z: -1 }))) {
            return TerrainData({ voxelTypeId: ConcentrativeSoilVoxelID, energy: 200 });
          } else if (voxelCoordsAreEqual(shardCoord, VoxelCoord({ x: 2, y: 0, z: -1 }))) {
            return TerrainData({ voxelTypeId: DiffusiveSoilVoxelID, energy: 200 });
          }
        }
      }
    }

    TerrainSectionData[] memory customSections = getCustomSections();
    for (uint256 i = 0; i < customSections.length; i++) {
      TerrainSectionData memory section = customSections[i];
      if (!section.includeAir) {
        continue;
      }
      // Check if the current coordinates are within a custom section.
      bool isInCustomSection = coord.x >= section.xCorner &&
        coord.x < section.xCorner + section.xLength &&
        coord.z >= section.zCorner &&
        coord.z < section.zCorner + section.zLength &&
        coord.y >= section.yCorner &&
        coord.y < section.yCorner + section.yLength;

      // If it's within the custom section, return the corresponding bucket.
      if (isInCustomSection) {
        return
          TerrainData({
            voxelTypeId: section.useExistingBlock ? AirVoxelID : section.voxelTypeId,
            energy: section.energy
          });
      }
    }

    return TerrainData({ voxelTypeId: AirVoxelID, energy: 0 });
  }
}
