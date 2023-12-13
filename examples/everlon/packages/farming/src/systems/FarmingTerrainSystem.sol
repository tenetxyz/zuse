// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-farming/src/codegen/world/IWorld.sol";
import { ABDKMath64x64 as Math } from "@tenet-utils/src/libraries/ABDKMath64x64.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { TerrainData, TerrainSectionData } from "@tenet-world/src/Types.sol";
import { SHARD_DIM, AIR_MASS, DIRT_MASS, GRASS_MASS, BEDROCK_MASS, STONE_MASS, AirObjectID, DirtObjectID, GrassObjectID, BedrockObjectID, StoneObjectID } from "@tenet-world/src/Constants.sol";
import { coordToShardCoord, voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { WORLD_ADDRESS, SOIL_MASS, ConcentrativeSoilObjectID, DiffusiveSoilObjectID, ProteinSoilObjectID, ElixirSoilObjectID } from "@tenet-farming/src/Constants.sol";

import { claimShard } from "@tenet-world/src/CallUtils.sol";

contract FarmingTerrainSystem is System {
  function initFarmingTerrain() public {
    VoxelCoord[4] memory farmingTerrainCoords = [
      VoxelCoord({ x: 300, y: 0, z: 0 }),
      VoxelCoord({ x: 200, y: 0, z: 0 }),
      VoxelCoord({ x: 300, y: 0, z: -100 }),
      VoxelCoord({ x: 200, y: 0, z: -100 })
    ];

    // First shard
    VoxelCoord memory firstFaucetAgentCoord = VoxelCoord({ x: 346, y: 15, z: 53 });
    claimShard(
      WORLD_ADDRESS,
      farmingTerrainCoords[0],
      _world(),
      IWorld(_world()).farming_FarmingTerrainSy_getFarmingTerrainObjectTypeId.selector,
      IWorld(_world()).farming_FarmingTerrainSy_getFarmingTerrainObjectProperties.selector,
      firstFaucetAgentCoord
    );

    // Second shard
    VoxelCoord memory secondFaucetAgentCoord = VoxelCoord({ x: 259, y: 9, z: 60 });
    claimShard(
      WORLD_ADDRESS,
      farmingTerrainCoords[1],
      _world(),
      IWorld(_world()).farming_FarmingTerrainSy_getFarmingTerrainObjectTypeId.selector,
      IWorld(_world()).farming_FarmingTerrainSy_getFarmingTerrainObjectProperties.selector,
      secondFaucetAgentCoord
    );

    // Third shard
    VoxelCoord memory thirdFaucetAgentCoord = VoxelCoord({ x: 325, y: 15, z: -59 });
    claimShard(
      WORLD_ADDRESS,
      farmingTerrainCoords[2],
      _world(),
      IWorld(_world()).farming_FarmingTerrainSy_getFarmingTerrainObjectTypeId.selector,
      IWorld(_world()).farming_FarmingTerrainSy_getFarmingTerrainObjectProperties.selector,
      thirdFaucetAgentCoord
    );

    // Fourth shard
    VoxelCoord memory fourthFaucetAgentCoord = VoxelCoord({ x: 233, y: 15, z: -62 });
    claimShard(
      WORLD_ADDRESS,
      farmingTerrainCoords[3],
      _world(),
      IWorld(_world()).farming_FarmingTerrainSy_getFarmingTerrainObjectTypeId.selector,
      IWorld(_world()).farming_FarmingTerrainSy_getFarmingTerrainObjectProperties.selector,
      fourthFaucetAgentCoord
    );
  }

  function getFarmingTerrainObjectTypeId(VoxelCoord memory coord) public view returns (bytes32) {
    return getFarmingTerrainObjectData(coord).objectTypeId;
  }

  function getFarmingTerrainObjectProperties(
    VoxelCoord memory coord,
    ObjectProperties memory requestedProperties
  ) public view returns (ObjectProperties memory) {
    return getFarmingTerrainObjectData(coord).properties;
  }

  function getCustomSections() internal pure returns (TerrainSectionData[] memory) {
    TerrainSectionData[] memory customSections = new TerrainSectionData[](5);
    customSections[0] = TerrainSectionData({
      useExistingObjectTypeId: false,
      objectTypeId: StoneObjectID,
      mass: STONE_MASS,
      energy: 100,
      xCorner: 290,
      yCorner: 0,
      zCorner: -10,
      xLength: 20,
      zLength: 20,
      yLength: SHARD_DIM,
      includeAir: false
    });
    customSections[1] = TerrainSectionData({
      useExistingObjectTypeId: true,
      objectTypeId: AirObjectID,
      mass: AIR_MASS,
      energy: 300,
      xCorner: 262,
      yCorner: 8,
      zCorner: 50,
      xLength: 20,
      zLength: 20,
      yLength: 15,
      includeAir: true
    });
    customSections[2] = TerrainSectionData({
      useExistingObjectTypeId: true,
      objectTypeId: AirObjectID,
      mass: AIR_MASS,
      energy: 300,
      xCorner: 335,
      yCorner: 12,
      zCorner: 63,
      xLength: 20,
      zLength: 20,
      yLength: 15,
      includeAir: true
    });
    customSections[3] = TerrainSectionData({
      useExistingObjectTypeId: true,
      objectTypeId: AirObjectID,
      mass: AIR_MASS,
      energy: 300,
      xCorner: 306,
      yCorner: 13,
      zCorner: -86,
      xLength: 20,
      zLength: 20,
      yLength: 15,
      includeAir: true
    });
    customSections[4] = TerrainSectionData({
      useExistingObjectTypeId: true,
      objectTypeId: AirObjectID,
      mass: AIR_MASS,
      energy: 300,
      xCorner: 205,
      yCorner: 11,
      zCorner: -70,
      xLength: 20,
      zLength: 20,
      yLength: 15,
      includeAir: true
    });
    return customSections;
  }

  function getFarmingTerrainObjectData(VoxelCoord memory coord) internal view returns (TerrainData memory) {
    ObjectProperties memory properties;
    VoxelCoord memory shardCoord = coordToShardCoord(coord, SHARD_DIM);

    bool isTerrain = false;
    int128 noiseScale = Math.div(85, 100); // Smaller for smoother/larger hills, larger for more frequent/smaller hills.
    int128 heightScaleFactor = Math.fromInt(25); // The maximum height difference in your terrain.
    {
      // Adjust the scale for the Perlin noise based on your shard size and preference for terrain variation.

      int128 shiftedX = Math.fromInt(coord.x + 20);
      int128 shiftedZ = Math.fromInt(coord.z + 15);

      // Generate the Perlin noise value for the current x, z coordinate within the shard.
      int128 noiseValue = IWorld(_world()).farming_PerlinSystem_noise(
        int256(Math.toInt(Math.mul(shiftedX, noiseScale))),
        int256(0),
        int256(Math.toInt(Math.mul(shiftedZ, noiseScale))),
        int256(50), // Denominator can be adjusted if necessary to scale the noise frequency.
        uint8(64) // precision
      );

      // Calculate the height at the current x, z coordinate within the shard.
      int128 heightAtCoord = (shardCoord.y * SHARD_DIM) + Math.toInt(Math.mul(noiseValue, heightScaleFactor));

      // Determine if the current object is terrain (stone) or air.
      isTerrain = coord.y <= heightAtCoord;
    }

    if (isTerrain) {
      bool isSoilLayer;
      {
        // Generate a noise value specifically for soil layering
        int128 soilNoise = IWorld(_world()).farming_PerlinSystem_noise(
          int256(Math.toInt(Math.mul(Math.fromInt(coord.x), noiseScale))),
          int256(coord.y),
          int256(Math.toInt(Math.mul(Math.fromInt(coord.z), noiseScale))),
          int256(50),
          uint8(64) // precision
        );
        // int128 maxSoilHeight = Math.toInt(Math.mul(Math.fromInt(SHARD_DIM), Math.div(3, 25))); // Adjust this value as needed
        int128 maxSoilHeight = 12;
        int128 factor = Math.toInt(Math.mul(soilNoise, heightScaleFactor));
        int128 soilHeight = factor < maxSoilHeight ? factor : maxSoilHeight;

        // Determine if the current object is within the bottommost range of the terrain
        isSoilLayer = coord.y <= soilHeight;
      }
      if (isSoilLayer) {
        // Object is in the central region
        properties.mass = SOIL_MASS;
        properties.energy = 500;
        if (voxelCoordsAreEqual(shardCoord, VoxelCoord({ x: 3, y: 0, z: 0 }))) {
          return TerrainData({ objectTypeId: ProteinSoilObjectID, properties: properties });
        } else if (voxelCoordsAreEqual(shardCoord, VoxelCoord({ x: 2, y: 0, z: 0 }))) {
          return TerrainData({ objectTypeId: ElixirSoilObjectID, properties: properties });
        } else if (voxelCoordsAreEqual(shardCoord, VoxelCoord({ x: 3, y: 0, z: -1 }))) {
          return TerrainData({ objectTypeId: ConcentrativeSoilObjectID, properties: properties });
        } else if (voxelCoordsAreEqual(shardCoord, VoxelCoord({ x: 2, y: 0, z: -1 }))) {
          return TerrainData({ objectTypeId: DiffusiveSoilObjectID, properties: properties });
        } else {
          revert("FarmingTerrainSystem: Invalid shard coord");
        }
      } else {
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
            if (section.useExistingObjectTypeId) {
              properties.mass = GRASS_MASS;
            } else {
              properties.mass = section.mass;
            }
            properties.energy = section.energy;
            return
              TerrainData({
                objectTypeId: section.useExistingObjectTypeId ? GrassObjectID : section.objectTypeId,
                properties: properties
              });
          }
        }

        properties.mass = GRASS_MASS;
        properties.energy = 200;
        return TerrainData({ objectTypeId: GrassObjectID, properties: properties });
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

      if (isInCustomSection) {
        if (section.useExistingObjectTypeId) {
          properties.mass = AIR_MASS;
        } else {
          properties.mass = section.mass;
        }
        properties.energy = section.energy;
        return
          TerrainData({
            objectTypeId: section.useExistingObjectTypeId ? AirObjectID : section.objectTypeId,
            properties: properties
          });
      }
    }

    properties.mass = AIR_MASS;
    properties.energy = 0;
    return TerrainData({ objectTypeId: AirObjectID, properties: properties });
  }
}
