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

contract PokemonTerrainSystem is System {
  function initPokemonTerrain(address worldAddress) public {
    VoxelCoord[4] memory spawnCoords = [
      VoxelCoord({ x: 300, y: 0, z: 0 }),
      VoxelCoord({ x: 200, y: 0, z: 0 }),
      VoxelCoord({ x: 300, y: 0, z: -100 }),
      VoxelCoord({ x: 200, y: 0, z: -100 })
    ];
    // First shard
    VoxelCoord memory firstFaucetAgentCoord = VoxelCoord({ x: 346, y: 15, z: 53 });
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
    VoxelCoord memory secondFaucetAgentCoord = VoxelCoord({ x: 259, y: 9, z: 60 });
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
    VoxelCoord memory thirdFaucetAgentCoord = VoxelCoord({ x: 325, y: 15, z: -59 });
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
    VoxelCoord memory fourthFaucetAgentCoord = VoxelCoord({ x: 233, y: 15, z: -62 });
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
      xCorner: 262,
      yCorner: 8,
      zCorner: 50,
      xLength: 20,
      zLength: 20,
      yLength: 15,
      includeAir: true
    });
    customSections[2] = TerrainSectionData({
      useExistingBlock: true,
      voxelTypeId: AirVoxelID,
      energy: 500,
      xCorner: 335,
      yCorner: 12,
      zCorner: 63,
      xLength: 20,
      zLength: 20,
      yLength: 15,
      includeAir: true
    });
    customSections[3] = TerrainSectionData({
      useExistingBlock: true,
      voxelTypeId: AirVoxelID,
      energy: 500,
      xCorner: 306,
      yCorner: 13,
      zCorner: -86,
      xLength: 20,
      zLength: 20,
      yLength: 15,
      includeAir: true
    });
    customSections[4] = TerrainSectionData({
      useExistingBlock: true,
      voxelTypeId: AirVoxelID,
      energy: 500,
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

  function getPokemonVoxelType(VoxelCoord memory coord) public view returns (TerrainData memory) {
    VoxelCoord memory shardCoord = coordToShardCoord(coord);

    bool isTerrain = false;
    int128 noiseScale = Math.div(85, 100); // Smaller for smoother/larger hills, larger for more frequent/smaller hills.
    int128 heightScaleFactor = Math.fromInt(25); // The maximum height difference in your terrain.
    {
      // Adjust the scale for the Perlin noise based on your shard size and preference for terrain variation.

      int128 shiftedX = Math.fromInt(coord.x + 20);
      int128 shiftedZ = Math.fromInt(coord.z + 15);

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
      // Generate a noise value specifically for soil layering
      int128 soilNoise = IWorld(_world()).pokemon_PerlinSystem_noise(
        int256(Math.toInt(Math.mul(coord.x, noiseScale))),
        int256(coord.y),
        int256(Math.toInt(Math.mul(coord.z, noiseScale))),
        int256(50),
        uint8(64) // precision
      );
      // int128 maxSoilHeight = Math.toInt(Math.mul(Math.fromInt(SHARD_DIM), Math.div(3, 25))); // Adjust this value as needed
      int128 maxSoilHeight = 12;
      int128 factor = Math.toInt(Math.mul(soilNoise, heightScaleFactor));
      int128 soilHeight = factor < maxSoilHeight ? factor : maxSoilHeight;

      // Determine if the current voxel is within the bottommost range of the terrain
      bool isSoilLayer = coord.y <= soilHeight;
      if (isSoilLayer) {
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
            return
              TerrainData({
                voxelTypeId: section.useExistingBlock ? GrassVoxelID : section.voxelTypeId,
                energy: section.energy
              });
          }
        }

        return TerrainData({ voxelTypeId: GrassVoxelID, energy: 50 });
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
