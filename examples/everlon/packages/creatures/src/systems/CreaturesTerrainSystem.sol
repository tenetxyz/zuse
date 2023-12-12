// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-creatures/src/codegen/world/IWorld.sol";
import { ABDKMath64x64 as Math } from "@tenet-utils/src/libraries/ABDKMath64x64.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { VoxelCoord, ObjectProperties, TerrainData, TerrainSectionData } from "@tenet-utils/src/Types.sol";
import { SHARD_DIM, AIR_MASS, DIRT_MASS, GRASS_MASS, BEDROCK_MASS, STONE_MASS, AirObjectID, DirtObjectID, GrassObjectID, BedrockObjectID, StoneObjectID } from "@tenet-world/src/Constants.sol";
import { coordToShardCoord, voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { WORLD_ADDRESS, SOIL_MASS, ConcentrativeSoilObjectID, DiffusiveSoilObjectID, ProteinSoilObjectID, ElixirSoilObjectID } from "@tenet-farming/src/Constants.sol";

import { claimShard } from "@tenet-world/src/CallUtils.sol";

contract CreaturesTerrainSystem is System {
  function initCreaturesTerrain() public {
    VoxelCoord[4] memory creatureTerrainCoords = [
      VoxelCoord({ x: 300, y: 0, z: 200 }),
      VoxelCoord({ x: 200, y: 0, z: 200 }),
      VoxelCoord({ x: 300, y: 0, z: 300 }),
      VoxelCoord({ x: 200, y: 0, z: 300 })
    ];

    // First shard
    VoxelCoord memory firstFaucetAgentCoord = VoxelCoord({ x: 372, y: 54, z: 226 });
    claimShard(
      WORLD_ADDRESS,
      creatureTerrainCoords[0],
      _world(),
      IWorld(_world()).creatures_CreaturesTerrain_getCreaturesTerrainObjectTypeId.selector,
      IWorld(_world()).creatures_CreaturesTerrain_getCreaturesTerrainObjectProperties.selector,
      firstFaucetAgentCoord
    );

    // Second shard
    VoxelCoord memory secondFaucetAgentCoord = VoxelCoord({ x: 242, y: 48, z: 241 });
    claimShard(
      WORLD_ADDRESS,
      creatureTerrainCoords[1],
      _world(),
      IWorld(_world()).creatures_CreaturesTerrain_getCreaturesTerrainObjectTypeId.selector,
      IWorld(_world()).creatures_CreaturesTerrain_getCreaturesTerrainObjectProperties.selector,
      secondFaucetAgentCoord
    );

    // Third shard
    VoxelCoord memory thirdFaucetAgentCoord = VoxelCoord({ x: 337, y: 46, z: 349 });
    claimShard(
      WORLD_ADDRESS,
      creatureTerrainCoords[2],
      _world(),
      IWorld(_world()).creatures_CreaturesTerrain_getCreaturesTerrainObjectTypeId.selector,
      IWorld(_world()).creatures_CreaturesTerrain_getCreaturesTerrainObjectProperties.selector,
      thirdFaucetAgentCoord
    );

    // Fourth shard
    VoxelCoord memory fourthFaucetAgentCoord = VoxelCoord({ x: 250, y: 56, z: 371 });
    claimShard(
      WORLD_ADDRESS,
      creatureTerrainCoords[3],
      _world(),
      IWorld(_world()).creatures_CreaturesTerrain_getCreaturesTerrainObjectTypeId.selector,
      IWorld(_world()).creatures_CreaturesTerrain_getCreaturesTerrainObjectProperties.selector,
      fourthFaucetAgentCoord
    );
  }

  function getCreaturesTerrainObjectTypeId(VoxelCoord memory coord) public view returns (bytes32) {
    return getCreaturesTerrainObjectData(coord).objectTypeId;
  }

  function getCreaturesTerrainObjectProperties(
    VoxelCoord memory coord,
    ObjectProperties memory requestedProperties
  ) public view returns (ObjectProperties memory) {
    return getCreaturesTerrainObjectData(coord).properties;
  }

  function getCustomSections() internal pure returns (TerrainSectionData[] memory) {
    TerrainSectionData[] memory customSections = new TerrainSectionData[](7);
    customSections[0] = TerrainSectionData({
      useExistingObjectTypeId: false,
      objectTypeId: AirObjectID,
      mass: AIR_MASS,
      energy: 300,
      xCorner: 210,
      yCorner: 56,
      zCorner: 379,
      xLength: 43,
      zLength: 21,
      yLength: 15,
      includeAir: true
    });
    customSections[1] = TerrainSectionData({
      useExistingObjectTypeId: false,
      objectTypeId: AirObjectID,
      mass: AIR_MASS,
      energy: 300,
      xCorner: 315,
      yCorner: 44,
      zCorner: 367,
      xLength: 27,
      zLength: 32,
      yLength: 15,
      includeAir: true
    });
    customSections[2] = TerrainSectionData({
      useExistingObjectTypeId: false,
      objectTypeId: AirObjectID,
      mass: AIR_MASS,
      energy: 300,
      xCorner: 292,
      yCorner: 44,
      zCorner: 375,
      xLength: 11,
      zLength: 14,
      yLength: 10,
      includeAir: true
    });
    customSections[3] = TerrainSectionData({
      useExistingObjectTypeId: false,
      objectTypeId: AirObjectID,
      mass: AIR_MASS,
      energy: 300,
      xCorner: 387,
      yCorner: 58,
      zCorner: 249,
      xLength: 12,
      zLength: 27,
      yLength: 15,
      includeAir: true
    });
    customSections[4] = TerrainSectionData({
      useExistingObjectTypeId: false,
      objectTypeId: AirObjectID,
      mass: AIR_MASS,
      energy: 300,
      xCorner: 347,
      yCorner: 50,
      zCorner: 209,
      xLength: 11,
      zLength: 12,
      yLength: 10,
      includeAir: true
    });
    customSections[5] = TerrainSectionData({
      useExistingObjectTypeId: false,
      objectTypeId: AirObjectID,
      mass: AIR_MASS,
      energy: 300,
      xCorner: 260,
      yCorner: 44,
      zCorner: 237,
      xLength: 24,
      zLength: 14,
      yLength: 10,
      includeAir: true
    });
    customSections[6] = TerrainSectionData({
      useExistingObjectTypeId: false,
      objectTypeId: AirObjectID,
      mass: AIR_MASS,
      energy: 300,
      xCorner: 202,
      yCorner: 52,
      zCorner: 212,
      xLength: 16,
      zLength: 24,
      yLength: 15,
      includeAir: true
    });
    return customSections;
  }

  function getCreaturesTerrainObjectData(VoxelCoord memory coord) internal view returns (TerrainData memory) {
    ObjectProperties memory properties;
    VoxelCoord memory shardCoord = coordToShardCoord(coord, SHARD_DIM);

    {
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
        if (isInCustomSection) {
          properties.mass = section.mass;
          properties.energy = section.energy;

          return TerrainData({ objectTypeId: section.objectTypeId, properties: properties });
        }
      }
    }

    bool isTerrain = false;
    int128 noiseScale = Math.div(3, 5); // Smaller for smoother/larger hills, larger for more frequent/smaller hills.
    int128 heightScaleFactor = Math.fromInt(80); // The maximum height difference in your terrain.
    {
      // Adjust the scale for the Perlin noise based on your shard size and preference for terrain variation.
      int128 shiftedX = Math.fromInt(coord.x - 20);
      int128 shiftedZ = Math.fromInt(coord.z - 15);
      // Generate the Perlin noise value for the current x, z coordinate within the shard.
      int128 noiseValue = IWorld(_world()).creatures_PerlinSystem_noise(
        int256(Math.toInt(Math.mul(shiftedX, noiseScale))),
        int256(0),
        int256(Math.toInt(Math.mul(shiftedZ, noiseScale))),
        int256(50), // Denominator can be adjusted if necessary to scale the noise frequency.
        uint8(64) // precision
      );
      // Calculate the height at the current x, z coordinate within the shard.
      int128 heightAtCoord = (shardCoord.y * SHARD_DIM) + Math.toInt(Math.mul(noiseValue, heightScaleFactor));
      // Determine if the current voxel is terrain (stone) or air.
      isTerrain = coord.y <= heightAtCoord;
    }
    if (isTerrain) {
      int128 soilHeight;
      {
        // Generate a noise value specifically for soil layering
        int128 soilNoise = IWorld(_world()).creatures_PerlinSystem_noise(
          int256(Math.toInt(Math.mul(Math.fromInt(coord.x), noiseScale))),
          int256(coord.y),
          int256(Math.toInt(Math.mul(Math.fromInt(coord.z), noiseScale))),
          int256(75),
          uint8(64) // precision
        );
        // int128 maxSoilHeight = Math.toInt(Math.mul(Math.fromInt(SHARD_DIM), Math.div(3, 25))); // Adjust this value as needed
        int128 maxSoilHeight = 35;
        int128 factor = Math.toInt(Math.mul(soilNoise, heightScaleFactor));
        soilHeight = factor < maxSoilHeight ? factor : maxSoilHeight;
      }
      // Determine if the current voxel is within the bottommost range of the terrain
      bool isSoilLayer = coord.y <= soilHeight;
      int128 grassHeightAboveSoil = 4; // This is the height above the soil where grass will appear
      int128 maxGrassHeight = soilHeight + grassHeightAboveSoil; // Calculate the maximum height for grass
      if (coord.y > soilHeight && coord.y <= maxGrassHeight) {
        // The current voxel is in the range for grass blocks
        properties.mass = GRASS_MASS;
        properties.energy = 50;
        return TerrainData({ objectTypeId: GrassObjectID, properties: properties });
      } else if (isSoilLayer) {
        int128 topSoilThreshold = 14;
        if (coord.y > soilHeight - topSoilThreshold) {
          // This is the top level of the soil
          properties.mass = SOIL_MASS;
          properties.energy = 200;
          return TerrainData({ objectTypeId: ProteinSoilObjectID, properties: properties });
        } else {
          // This is the bottom level of the soil
          properties.mass = SOIL_MASS;
          properties.energy = 200;
          return TerrainData({ objectTypeId: ConcentrativeSoilObjectID, properties: properties });
        }
      } else {
        properties.mass = STONE_MASS;
        properties.energy = 100;
        return TerrainData({ objectTypeId: StoneObjectID, properties: properties });
      }
    }

    properties.mass = AIR_MASS;
    properties.energy = 0;
    return TerrainData({ objectTypeId: AirObjectID, properties: properties });
  }
}
