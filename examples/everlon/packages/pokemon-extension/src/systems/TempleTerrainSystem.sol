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

string constant CLAIM_SHARD_SIG = "claimShard((int32,int32,int32),address,bytes4,(int32,int32,int32))";
bytes32 constant StoneVoxelId = bytes32(keccak256("stone"));

contract TempleTerrainSystem is System {
  function initTempleTerrain(address worldAddress) public {
    VoxelCoord[4] memory spawnCoords = [
      VoxelCoord({ x: 300, y: 0, z: 200 }),
      VoxelCoord({ x: 200, y: 0, z: 200 }),
      VoxelCoord({ x: 300, y: 0, z: 300 }),
      VoxelCoord({ x: 200, y: 0, z: 300 })
    ];
    // First shard
    VoxelCoord memory firstFaucetAgentCoord = VoxelCoord({ x: 372, y: 54, z: 226 });
    callOrRevert(
      worldAddress,
      abi.encodeWithSignature(
        CLAIM_SHARD_SIG,
        spawnCoords[0],
        _world(),
        IWorld(_world()).pokemon_TempleTerrainSys_getTempleVoxelType.selector,
        firstFaucetAgentCoord
      ),
      "claimShard Temple 1"
    );

    // Second shard
    VoxelCoord memory secondFaucetAgentCoord = VoxelCoord({ x: 242, y: 48, z: 241 });
    callOrRevert(
      worldAddress,
      abi.encodeWithSignature(
        CLAIM_SHARD_SIG,
        spawnCoords[1],
        _world(),
        IWorld(_world()).pokemon_TempleTerrainSys_getTempleVoxelType.selector,
        secondFaucetAgentCoord
      ),
      "claimShard Temple 2"
    );

    // Third shard
    VoxelCoord memory thirdFaucetAgentCoord = VoxelCoord({ x: 337, y: 46, z: 349 });
    callOrRevert(
      worldAddress,
      abi.encodeWithSignature(
        CLAIM_SHARD_SIG,
        spawnCoords[2],
        _world(),
        IWorld(_world()).pokemon_TempleTerrainSys_getTempleVoxelType.selector,
        thirdFaucetAgentCoord
      ),
      "claimShard Temple 3"
    );

    // Fourth shard
    VoxelCoord memory fourthFaucetAgentCoord = VoxelCoord({ x: 250, y: 56, z: 371 });
    callOrRevert(
      worldAddress,
      abi.encodeWithSignature(
        CLAIM_SHARD_SIG,
        spawnCoords[3],
        _world(),
        IWorld(_world()).pokemon_TempleTerrainSys_getTempleVoxelType.selector,
        fourthFaucetAgentCoord
      ),
      "claimShard Temple 4"
    );
  }

  function getCustomSections() internal pure returns (TerrainSectionData[] memory) {
    TerrainSectionData[] memory customSections = new TerrainSectionData[](7);
    customSections[0] = TerrainSectionData({
      useExistingBlock: false,
      voxelTypeId: AirVoxelID,
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
      useExistingBlock: false,
      voxelTypeId: AirVoxelID,
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
      useExistingBlock: false,
      voxelTypeId: AirVoxelID,
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
      useExistingBlock: false,
      voxelTypeId: AirVoxelID,
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
      useExistingBlock: false,
      voxelTypeId: AirVoxelID,
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
      useExistingBlock: false,
      voxelTypeId: AirVoxelID,
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
      useExistingBlock: false,
      voxelTypeId: AirVoxelID,
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

  function getTempleVoxelType(VoxelCoord memory coord) public view returns (TerrainData memory) {
    VoxelCoord memory shardCoord = coordToShardCoord(coord);

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
        return TerrainData({ voxelTypeId: section.voxelTypeId, energy: section.energy });
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
      int128 noiseValue = IWorld(_world()).pokemon_PerlinSystem_noise(
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
        int128 soilNoise = IWorld(_world()).pokemon_PerlinSystem_noise(
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
        return TerrainData({ voxelTypeId: GrassVoxelID, energy: 50 });
      } else if (isSoilLayer) {
        int128 topSoilThreshold = 14;
        if (coord.y > soilHeight - topSoilThreshold) {
          // This is the top level of the soil
          return TerrainData({ voxelTypeId: ProteinSoilVoxelID, energy: 200 });
        } else {
          // This is the bottom level of the soil
          return TerrainData({ voxelTypeId: ConcentrativeSoilVoxelID, energy: 200 });
        }
      } else {
        return TerrainData({ voxelTypeId: StoneVoxelId, energy: 100 });
      }
    }

    return TerrainData({ voxelTypeId: AirVoxelID, energy: 0 });
  }
}
