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

  function getCustomSections() internal returns (TerrainSectionData[] memory) {
    TerrainSectionData[5] memory CUSTOM_SECTIONS = [
      TerrainSectionData({
        voxelTypeId: StoneVoxelId, // The bucket ID we want to use for this section
        energy: 10, // The energy cost of this section
        xCorner: 290, // Starting x-coordinate of the corner
        yCorner: 0, // Starting y-coordinate of the corner (not used in this condition)
        zCorner: -10, // Starting z-coordinate of the corner
        xLength: 20, // Length of the section along the x-axis
        zLength: 20, // Length of the section along the z-axis
        yLength: SHARD_DIM, // Height of the section, spans the entire shard height
        includeAir: false
      }),
      TerrainSectionData({
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
      }),
      TerrainSectionData({
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
      }),
      TerrainSectionData({
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
      }),
      TerrainSectionData({
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
      })
    ];
  }

  function getPokemonVoxelType(VoxelCoord memory coord) public view returns (TerrainData) {
    VoxelCoord memory shardCoord = coordToShardCoord(coord);

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
      50 // Denominator can be adjusted if necessary to scale the noise frequency.
    );

    // Calculate the height at the current x, z coordinate within the shard.
    int128 heightAtCoord = (shardCoord.y * SHARD_DIM) + (noiseValue * heightScaleFactor);

    // Determine if the current voxel is terrain (stone) or air.
    bool isTerrain = coord.y <= heightAtCoord;
    if (isTerrain) {
      // Calculate local coordinates within the shard
      int128 localX = coord.x - shardCoord.x * CHAIN_SHARD_DIM;
      int128 localZ = coord.z - shardCoord.z * CHAIN_SHARD_DIM;

      // Calculate the center point of the shard
      int128 centerX = CHAIN_SHARD_DIM / 2;
      int128 centerZ = CHAIN_SHARD_DIM / 2;

      // Calculate the distance of the voxel from the center of the shard
      int128 distanceFromCenter = Math.sqrt(Math.pow(localX - centerX, 2) + Math.pow(localZ - centerZ, 2));

      // Define the radius of the central soil area
      int128 soilRadius = 35;

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
                voxelTypeId: section.useExistingBlock ? GrassVoxelId : section.voxelTypeId,
                energy: section.energy
              });
          }
        }

        return TerrainData({ voxelTypeId: GrassVoxelId, energy: 50 });
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
          1
        );

        // Calculate the effective border width with noise variation
        int128 borderVariation = borderNoiseValue * maxBorderVariation;
        int128 effectiveRadius = soilRadius - borderVariation; // Use subtraction to make border fuzzy

        // Determine if the current position is within the fuzzy border
        bool isInFuzzyBorder = distanceFromCenter > effectiveRadius;
        if (isInFuzzyBorder) {
          return TerrainData({ voxelTypeId: GrassVoxelId, energy: 50 });
        } else {
          // Voxel is in the central region
          if (voxelCoordsAreEqual(shardCoord, VoxelCoord({ x: 3, y: 0, z: 0 }))) {
            return TerrainData({ voxelTypeId: ProteinSoilVoxelID, energy: 200 });
          } else if (voxelCoordsAreEqual(shardCoord, VoxelCoord({ x: 2, y: 0, z: 0 }))) {
            return TerrainData({ voxelTypeId: ElixirSoilVoxelId, energy: 200 });
          } else if (voxelCoordsAreEqual(shardCoord, VoxelCoord({ x: 3, y: 0, z: -1 }))) {
            return TerrainData({ voxelTypeId: ConcentrativeSoilVoxelId, energy: 200 });
          } else if (voxelCoordsAreEqual(shardCoord, VoxelCoord({ x: 2, y: 0, z: -1 }))) {
            return TerrainData({ voxelTypeId: DiffusiveSoilVoxelId, energy: 200 });
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
