// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

//import { Perlin } from "noise/world.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { ABDKMath64x64 as Math } from "@tenet-utils/src/libraries/ABDKMath64x64.sol";

import { AirObjectID, SnowObjectID, AsphaltObjectID, BasaltObjectID, ClayBrickObjectID, CottonObjectID, StoneObjectID, EmberstoneObjectID, CobblestoneObjectID, MoonstoneObjectID, GraniteObjectID, QuartziteObjectID, LimestoneObjectID, SunstoneObjectID, SoilObjectID, GravelObjectID, ClayObjectID, BedrockObjectID, LavaObjectID, DiamondOreObjectID, GoldOreObjectID, CoalOreObjectID, SilverOreObjectID, NeptuniumOreObjectID, GrassObjectID, MuckGrassObjectID, DirtObjectID, MuckDirtObjectID, MossObjectID, CottonBushObjectID, MossGrassObjectID, SwitchGrassObjectID, OakLogObjectID, BirchLogObjectID, SakuraLogObjectID, RubberLogObjectID, OakLeafObjectID, BirchLeafObjectID, SakuraLeafObjectID, RubberLeafObjectID } from "@tenet-world/src/Constants.sol";

import { Biome, STRUCTURE_CHUNK, STRUCTURE_CHUNK_CENTER, AIR_MASS, SOIL_MASS, GRAVEL_MASS, CLAY_MASS, LAVA_MASS, BEDROCK_MASS, MOSS_GRASS_MASS, SWITCH_GRASS_MASS, COTTON_BUSH_MASS, MOSS_MASS, MUCK_GRASS_MASS, GRASS_MASS, MUCK_DIRT_MASS, DIRT_MASS, COAL_ORE_MASS, SILVER_ORE_MASS, GOLD_ORE_MASS, DIAMOND_ORE_MASS, NEPTUNIUM_ORE_MASS, SNOW_MASS, ASPHALT_MASS, BASALT_MASS, CLAY_BRICK_MASS, COTTON_MASS, STONE_MASS, COBBLESTONE_MASS, GRANITE_MASS, LIMESTONE_MASS, EMBERSTONE_MASS, MOONSTONE_MASS, QUARTZITE_MASS, SUNSTONE_MASS, OAK_LOG_MASS, BIRCH_LOG_MASS, SAKURA_LOG_MASS, RUBBER_LOG_MASS, OAK_LEAF_MASS, BIRCH_LEAF_MASS, SAKURA_LEAF_MASS, RUBBER_LEAF_MASS, BEDROCK_MASS } from "@tenet-world/src/Constants.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { floorDiv } from "@tenet-utils/src/MathUtils.sol";
import { TerrainData } from "@tenet-world/src/Types.sol";

struct Tuple {
  int128 x;
  int128 y;
}

int128 constant _0 = 0; // 0 * 2**64
int128 constant _0_3 = 5534023222112865484; // 0.3 * 2**64
int128 constant _0_4 = 7378697629483820646; // 0.4 * 2**64
int128 constant _0_45 = 8301034833169298227; // 0.45 * 2**64
int128 constant _0_49 = 9038904596117680291; // 0.49 * 2**64
int128 constant _0_499 = 9204925292781066256; // 0.499 * 2**64
int128 constant _0_501 = 9241818780928485359; // 0.501 * 2**64
int128 constant _0_5 = 9223372036854775808; // 0.5 * 2**64
int128 constant _0_51 = 9407839477591871324; // 0.51 * 2**64
int128 constant _0_55 = 10145709240540253388; // 0.55 * 2**64
int128 constant _0_6 = 11068046444225730969; // 0.6 * 2**64
int128 constant _0_75 = 13835058055282163712; // 0.75 * 2**64
int128 constant _0_8 = 14757395258967641292; // 0.8 * 2**64
int128 constant _0_9 = 16602069666338596454; // 0.9 * 2**64
int128 constant _1 = 2 ** 64;
int128 constant _2 = 2 * 2 ** 64;
int128 constant _3 = 3 * 2 ** 64;
int128 constant _4 = 4 * 2 ** 64;
int128 constant _5 = 5 * 2 ** 64;
int128 constant _10 = 10 * 2 ** 64;
int128 constant _16 = 16 * 2 ** 64;

contract LibTerrainSystem is System {
  function getTerrainBlock(VoxelCoord memory coord) public view returns (TerrainData memory) {
    int128[4] memory biome = getBiome(coord.x, coord.z);
    int32 height = getHeight(coord.x, coord.z);
    return getTerrainBlock(coord.x, coord.y, coord.z, height, biome);
  }

  function getTerrainBlock(
    int32 x,
    int32 y,
    int32 z,
    int32 height,
    int128[4] memory biomeValues
  ) internal view returns (TerrainData memory) {
    TerrainData memory terrainData;

    uint8 biome = getMaxBiome(biomeValues);
    int32 distanceFromHeight = height - y;

    terrainData = Structure(x, y, z, height, biome, distanceFromHeight);
    if (terrainData.objectTypeId != bytes32(0)) return terrainData;

    terrainData = TopBlocks(x, y, z, height, biome, distanceFromHeight);
    if (terrainData.objectTypeId != bytes32(0)) return terrainData;

    terrainData = MiddleDecorations(x, y, z, height, biome, distanceFromHeight);
    if (terrainData.objectTypeId != bytes32(0)) return terrainData;

    terrainData = MiddleBlocks(x, y, z, height, biome, distanceFromHeight);
    if (terrainData.objectTypeId != bytes32(0)) return terrainData;

    terrainData = BottomBlocks(x, y, z, height, biome, distanceFromHeight);
    if (terrainData.objectTypeId != bytes32(0)) return terrainData;

    terrainData = Air(y, height);
    if (terrainData.objectTypeId != bytes32(0)) return terrainData;

    ObjectProperties memory properties;
    properties.mass = AIR_MASS;
    properties.energy = 0;

    return TerrainData({ objectTypeId: AirObjectID, properties: properties });
  }

  function getHeight(int32 x, int32 z) internal view returns (int32) {
    // Compute perlin height
    int128 perlin999 = IWorld(_world()).world_PerlinSystem_noise2d(x - 550, z + 550, 149, 64);
    int128 continentalHeight = continentalness(perlin999);
    int128 terrainHeight = Math.mul(perlin999, _10);
    int128 perlin49 = IWorld(_world()).world_PerlinSystem_noise2d(x, z, 49, 64);
    terrainHeight = Math.add(terrainHeight, Math.mul(perlin49, _5));
    terrainHeight = Math.add(terrainHeight, IWorld(_world()).world_PerlinSystem_noise2d(x, z, 13, 64));
    terrainHeight = Math.div(terrainHeight, _16);

    // Compute biome height
    // int128 height = Math.mul(biome[uint256(Biome.Mountains)], mountains(terrainHeight));
    // height = Math.add(height, Math.mul(biome[uint256(Biome.Desert)], desert(terrainHeight)));
    // height = Math.add(height, Math.mul(biome[uint256(Biome.Forest)], forest(terrainHeight)));
    // height = Math.add(height, Math.mul(biome[uint256(Biome.Savanna)], savanna(terrainHeight)));
    // height = Math.div(height, Math.add(Math.add(Math.add(Math.add(biome[0], biome[1]), biome[2]), biome[3]), _1));
    int128 height = terrainHeight;
    height = Math.add(continentalHeight, Math.div(height, _2));

    // Create valleys
    // int128 valley = valleys(
    //   Math.div(Math.add(Math.mul(IWorld(_world()).world_PerlinSystem_noise2d(x, z, 333, 64), _2), perlin49), _3)
    // );
    // height = Math.mul(height, valley);

    // Scale height
    return int32(Math.muli(height, 256) - 70);
  }

  function getBiome(int32 x, int32 z) internal view returns (int128[4] memory) {
    int128 heat = IWorld(_world()).world_PerlinSystem_noise2d(x + 222, z + 222, 111, 64);
    int128 humidity = IWorld(_world()).world_PerlinSystem_noise(z, x, 999, 83, 64);

    Tuple memory biomeVector = Tuple(humidity, heat);
    int128[4] memory biome;

    biome[uint256(Biome.Mountains)] = pos(
      Math.mul(Math.sub(_0_75, euclidean(biomeVector, getBiomeVector(Biome.Mountains))), _2)
    );

    biome[uint256(Biome.Desert)] = pos(
      Math.mul(Math.sub(_0_75, euclidean(biomeVector, getBiomeVector(Biome.Desert))), _2)
    );

    biome[uint256(Biome.Forest)] = pos(
      Math.mul(Math.sub(_0_75, euclidean(biomeVector, getBiomeVector(Biome.Forest))), _2)
    );

    biome[uint256(Biome.Savanna)] = pos(
      Math.mul(Math.sub(_0_75, euclidean(biomeVector, getBiomeVector(Biome.Savanna))), _2)
    );

    return biome;
  }

  function getMaxBiome(int128[4] memory biomeValues) internal view returns (uint8 biome) {
    int128 maxBiome;
    for (uint256 i; i < biomeValues.length; i++) {
      if (biomeValues[i] > maxBiome) {
        maxBiome = biomeValues[i];
        biome = uint8(i);
      }
    }
  }

  function getBiomeVector(Biome biome) internal view returns (Tuple memory) {
    if (biome == Biome.Mountains) return Tuple(_0, _0);
    if (biome == Biome.Desert) return Tuple(_0, _1);
    if (biome == Biome.Forest) return Tuple(_1, _0);
    if (biome == Biome.Savanna) return Tuple(_1, _1);
    revert("unknown biome");
  }

  function getCoordHash(int32 x, int32 z) internal view returns (uint16) {
    uint256 hash = uint256(keccak256(abi.encode(x, z)));
    return uint16(hash % 1024);
  }

  function getChunkCoord(int32 x, int32 z) internal view returns (int32, int32) {
    return (floorDiv(x, STRUCTURE_CHUNK), floorDiv(z, STRUCTURE_CHUNK));
  }

  function getChunkOffsetAndHeight(
    int32 x,
    int32 y,
    int32 z
  ) internal view returns (int32 height, VoxelCoord memory offset) {
    (int32 chunkX, int32 chunkZ) = getChunkCoord(x, z);
    int32 chunkCenterX = chunkX * STRUCTURE_CHUNK + STRUCTURE_CHUNK_CENTER;
    int32 chunkCenterZ = chunkZ * STRUCTURE_CHUNK + STRUCTURE_CHUNK_CENTER;
    int128[4] memory biome = getBiome(chunkCenterX, chunkCenterZ);
    height = getHeight(chunkCenterX, chunkCenterZ);
    offset = VoxelCoord(x - chunkX * STRUCTURE_CHUNK, y - height, z - chunkZ * STRUCTURE_CHUNK);
  }

  function getBiomeHash(int32 x, int32 y, uint8 biome) internal view returns (uint16) {
    return getCoordHash(floorDiv(x, 300) + floorDiv(y, 300), int32(uint32(biome)));
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Utils
  //////////////////////////////////////////////////////////////////////////////////////

  // return Math.sqrt(Math.pow(a[0] - b[0], 2) + Math.pow(a[1] - b[1], 2));
  function euclidean(Tuple memory a, Tuple memory b) internal view returns (int128) {
    return Math.sqrt(Math.add(Math.pow(Math.sub(a.x, b.x), 2), Math.pow(Math.sub(a.y, b.y), 2)));
  }

  function euclideanVec(int128[] memory a, int128[] memory b) internal view returns (int128) {
    return euclidean(Tuple(a[0], a[1]), Tuple(b[0], b[1]));
  }

  function euclideanRaw(int128 a0, int128 a1, int128 b0, int128 b1) internal view returns (int128) {
    return euclidean(Tuple(a0, a1), Tuple(b0, b1));
  }

  function pos(int128 x) internal view returns (int128) {
    return x < 0 ? int128(0) : x;
  }

  function coordEq(VoxelCoord memory a, uint8[3] memory b) internal view returns (bool) {
    return a.x == int32(uint32(b[0])) && a.y == int32(uint32(b[1])) && a.z == int32(uint32(b[2]));
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Spline functions
  //////////////////////////////////////////////////////////////////////////////////////

  function applySpline(int128 x, Tuple[] memory splines) internal view returns (int128) {
    Tuple[2] memory points;

    // Find spline points
    if (splines.length == 2) {
      points = [splines[0], splines[1]];
    } else {
      for (uint256 index; index < splines.length; index++) {
        if (splines[index].x >= x) {
          points = [splines[index - 1], splines[index]];
          break;
        }
      }
    }

    int128 t = Math.div(Math.sub(x, points[0].x), Math.sub(points[1].x, points[0].x));
    return IWorld(_world()).world_PerlinSystem_lerp(t, points[0].y, points[1].y);
  }

  function continentalness(int128 x) internal view returns (int128) {
    Tuple[] memory splines = new Tuple[](2);
    splines[0] = Tuple(_0, _0);
    splines[1] = Tuple(_1, _0_3);
    return applySpline(x, splines);
  }

  function mountains(int128 x) internal view returns (int128) {
    Tuple[] memory splines = new Tuple[](4);
    splines[0] = Tuple(_0, _0);
    splines[1] = Tuple(_0_3, _0_4);
    splines[2] = Tuple(_0_6, _2);
    splines[3] = Tuple(_1, _4);
    return applySpline(x, splines);
  }

  function desert(int128 x) internal view returns (int128) {
    Tuple[] memory splines = new Tuple[](2);
    splines[0] = Tuple(_0, _0);
    splines[1] = Tuple(_1, _0_4);
    return applySpline(x, splines);
  }

  function forest(int128 x) internal view returns (int128) {
    Tuple[] memory splines = new Tuple[](2);
    splines[0] = Tuple(_0, _0);
    splines[1] = Tuple(_1, _0_5);
    return applySpline(x, splines);
  }

  function savanna(int128 x) internal view returns (int128) {
    Tuple[] memory splines = new Tuple[](2);
    splines[0] = Tuple(_0, _0);
    splines[1] = Tuple(_1, _0_4);
    return applySpline(x, splines);
  }

  function valleys(int128 x) internal view returns (int128) {
    Tuple[] memory splines = new Tuple[](8);
    splines[0] = Tuple(_0, _1);
    splines[1] = Tuple(_0_45, _1);
    splines[2] = Tuple(_0_49, _0_9);
    splines[3] = Tuple(_0_499, _0_8);
    splines[4] = Tuple(_0_501, _0_8);
    splines[5] = Tuple(_0_51, _0_9);
    splines[6] = Tuple(_0_55, _1);
    splines[7] = Tuple(_1, _1);
    return applySpline(x, splines);
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Block occurrence functions
  //////////////////////////////////////////////////////////////////////////////////////

  function Air(int32 y, int32 height) internal view returns (TerrainData memory) {
    ObjectProperties memory properties;
    if (y < height) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    properties.mass = AIR_MASS;
    properties.energy = 0;

    return TerrainData({ objectTypeId: AirObjectID, properties: properties });
  }

  function TopPatches(
    int32 x,
    int32 y,
    int32 z,
    int32 height,
    uint8 biome,
    int32 distanceFromHeight
  ) internal view returns (TerrainData memory) {
    ObjectProperties memory properties;
    if (distanceFromHeight != 1) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    (int32 chunkX, int32 chunkZ) = getChunkCoord(x, z);
    uint16 hash = getCoordHash(chunkX, chunkZ);

    if (hash >= 50) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    properties.energy = 100;
    if (biome == uint8(Biome.Mountains)) {
      properties.mass = ASPHALT_MASS;
      return TerrainData({ objectTypeId: AsphaltObjectID, properties: properties });
    } else if (biome == uint8(Biome.Desert)) {
      properties.mass = BASALT_MASS;
      return TerrainData({ objectTypeId: BasaltObjectID, properties: properties });
    } else if (biome == uint8(Biome.Forest)) {
      properties.mass = CLAY_BRICK_MASS;
      return TerrainData({ objectTypeId: ClayBrickObjectID, properties: properties });
    } else if (biome == uint8(Biome.Savanna)) {
      properties.mass = COTTON_MASS;
      return TerrainData({ objectTypeId: CottonObjectID, properties: properties });
    }

    return TerrainData({ objectTypeId: bytes32(0), properties: properties });
  }

  function TopBlocks(
    int32 x,
    int32 y,
    int32 z,
    int32 height,
    uint8 biome,
    int32 distanceFromHeight
  ) internal view returns (TerrainData memory) {
    ObjectProperties memory properties;
    if (y >= height) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    if (y <= 30) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    properties.energy = 100;
    if (y > 70) {
      properties.mass = SNOW_MASS;
      return TerrainData({ objectTypeId: SnowObjectID, properties: properties });
    }

    TerrainData memory patchBlock = TopPatches(x, y, z, height, biome, distanceFromHeight);
    if (patchBlock.objectTypeId != bytes32(0)) return patchBlock;

    if (biome == uint8(Biome.Mountains)) {
      if (distanceFromHeight <= 3) {
        properties.mass = STONE_MASS;
        return TerrainData({ objectTypeId: StoneObjectID, properties: properties });
      } else {
        properties.mass = EMBERSTONE_MASS;
        return TerrainData({ objectTypeId: EmberstoneObjectID, properties: properties });
      }
    } else if (biome == uint8(Biome.Desert)) {
      if (distanceFromHeight <= 3) {
        properties.mass = COBBLESTONE_MASS;
        return TerrainData({ objectTypeId: CobblestoneObjectID, properties: properties });
      } else {
        properties.mass = MOONSTONE_MASS;
        return TerrainData({ objectTypeId: MoonstoneObjectID, properties: properties });
      }
    } else if (biome == uint8(Biome.Forest)) {
      if (distanceFromHeight <= 3) {
        properties.mass = GRANITE_MASS;
        return TerrainData({ objectTypeId: GraniteObjectID, properties: properties });
      } else {
        properties.mass = QUARTZITE_MASS;
        return TerrainData({ objectTypeId: QuartziteObjectID, properties: properties });
      }
    } else if (biome == uint8(Biome.Savanna)) {
      if (distanceFromHeight <= 3) {
        properties.mass = LIMESTONE_MASS;
        return TerrainData({ objectTypeId: LimestoneObjectID, properties: properties });
      } else {
        properties.mass = SUNSTONE_MASS;
        return TerrainData({ objectTypeId: SunstoneObjectID, properties: properties });
      }
    }

    return TerrainData({ objectTypeId: bytes32(0), properties: properties });
  }

  function MiddleBlocks(
    int32 x,
    int32 y,
    int32 z,
    int32 height,
    uint8 biome,
    int32 distanceFromHeight
  ) internal view returns (TerrainData memory) {
    ObjectProperties memory properties;
    if (y >= height) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    if (y > 30 || y < 5) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    properties.energy = 100;
    if (distanceFromHeight <= 3) {
      if (distanceFromHeight == 1) {
        if (biome == uint8(Biome.Mountains)) {
          properties.mass = MUCK_GRASS_MASS;
          return TerrainData({ objectTypeId: MuckGrassObjectID, properties: properties });
        } else if (biome == uint8(Biome.Desert)) {
          properties.mass = MUCK_GRASS_MASS;
          return TerrainData({ objectTypeId: MuckGrassObjectID, properties: properties });
        } else if (biome == uint8(Biome.Forest)) {
          properties.mass = GRASS_MASS;
          return TerrainData({ objectTypeId: GrassObjectID, properties: properties });
        }
      }
      if (biome == uint8(Biome.Savanna)) {
        properties.mass = MOSS_MASS;
        return TerrainData({ objectTypeId: MossObjectID, properties: properties });
      }
    }

    uint16 hash1 = getCoordHash(x, z);
    uint16 hash2 = getCoordHash(y, x + z);
    if (hash1 > 10 && hash1 <= 60 && hash2 > 10 && hash2 <= 60) {
      if (biome == uint8(Biome.Mountains)) {
        properties.mass = COAL_ORE_MASS;
        return TerrainData({ objectTypeId: CoalOreObjectID, properties: properties });
      } else if (biome == uint8(Biome.Desert)) {
        properties.mass = NEPTUNIUM_ORE_MASS;
        return TerrainData({ objectTypeId: NeptuniumOreObjectID, properties: properties });
      } else if (biome == uint8(Biome.Forest)) {
        properties.mass = SILVER_ORE_MASS;
        return TerrainData({ objectTypeId: SilverOreObjectID, properties: properties });
      } else if (biome == uint8(Biome.Savanna)) {
        properties.mass = GOLD_ORE_MASS;
        return TerrainData({ objectTypeId: GoldOreObjectID, properties: properties });
      }
    }

    if (biome == uint8(Biome.Mountains) || biome == uint8(Biome.Desert)) {
      properties.mass = MUCK_DIRT_MASS;
      return TerrainData({ objectTypeId: MuckDirtObjectID, properties: properties });
    } else {
      properties.mass = DIRT_MASS;
      return TerrainData({ objectTypeId: DirtObjectID, properties: properties });
    }
  }

  function BottomBlocks(
    int32 x,
    int32 y,
    int32 z,
    int32 height,
    uint8 biome,
    int32 distanceFromHeight
  ) internal view returns (TerrainData memory) {
    ObjectProperties memory properties;
    if (y >= height) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    if (y >= 5) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    properties.energy = 100;
    if (y < -60) {
      properties.mass = BEDROCK_MASS;
      return TerrainData({ objectTypeId: BedrockObjectID, properties: properties });
    }

    if (y < -50) {
      properties.mass = LAVA_MASS;
      return TerrainData({ objectTypeId: LavaObjectID, properties: properties });
    }

    if (y >= 0) {
      properties.mass = SOIL_MASS;
      return TerrainData({ objectTypeId: SoilObjectID, properties: properties });
    }
    if (y == -1) {
      properties.mass = GRAVEL_MASS;
      return TerrainData({ objectTypeId: GravelObjectID, properties: properties });
    }

    uint16 hash1 = getCoordHash(x, z);
    uint16 hash2 = getCoordHash(y, x + z);
    if (hash1 <= 10 || hash1 > 50) {
      if (hash1 <= 10 && hash2 <= 10) {
        properties.mass = DIAMOND_ORE_MASS;
        return TerrainData({ objectTypeId: DiamondOreObjectID, properties: properties });
      }
    } else {
      if (hash2 > 10 && hash2 <= 50) {
        if (biome == uint8(Biome.Mountains)) {
          properties.mass = COAL_ORE_MASS;
          return TerrainData({ objectTypeId: CoalOreObjectID, properties: properties });
        } else if (biome == uint8(Biome.Desert)) {
          properties.mass = NEPTUNIUM_ORE_MASS;
          return TerrainData({ objectTypeId: NeptuniumOreObjectID, properties: properties });
        } else if (biome == uint8(Biome.Forest)) {
          properties.mass = SILVER_ORE_MASS;
          return TerrainData({ objectTypeId: SilverOreObjectID, properties: properties });
        } else if (biome == uint8(Biome.Savanna)) {
          properties.mass = GOLD_ORE_MASS;
          return TerrainData({ objectTypeId: GoldOreObjectID, properties: properties });
        }
      }
    }

    properties.mass = CLAY_MASS;
    return TerrainData({ objectTypeId: ClayObjectID, properties: properties });
  }

  function MiddleDecorations(
    int32 x,
    int32 y,
    int32 z,
    int32 height,
    uint8 biome,
    int32 distanceFromHeight
  ) internal view returns (TerrainData memory) {
    ObjectProperties memory properties;
    if (y > 30 || y < 5) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    if (y != height) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    properties.energy = 50;
    uint16 hash1 = getCoordHash(x, z);

    if (biome == uint8(Biome.Mountains)) {
      if (hash1 < 10) {
        properties.mass = COTTON_BUSH_MASS;
        return TerrainData({ objectTypeId: CottonBushObjectID, properties: properties });
      }
    } else if (biome == uint8(Biome.Desert)) {
      if (hash1 < 10) {
        properties.mass = COTTON_BUSH_MASS;
        return TerrainData({ objectTypeId: CottonBushObjectID, properties: properties });
      }
    } else if (biome == uint8(Biome.Forest)) {
      if (hash1 < 10) {
        properties.mass = MOSS_GRASS_MASS;
        return TerrainData({ objectTypeId: MossGrassObjectID, properties: properties });
      } else if (hash1 < 25) {
        properties.mass = SWITCH_GRASS_MASS;
        return TerrainData({ objectTypeId: SwitchGrassObjectID, properties: properties });
      }
    } else if (biome == uint8(Biome.Savanna)) {}

    return TerrainData({ objectTypeId: bytes32(0), properties: properties });
  }

  function Structure(
    int32 x,
    int32 y,
    int32 z,
    int32 height,
    uint8 biome,
    int32 distanceFromHeight
  ) internal view returns (TerrainData memory) {
    ObjectProperties memory properties;
    if (y < height) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    (int32 chunkHeight, VoxelCoord memory chunkOffset) = getChunkOffsetAndHeight(x, y, z);
    if (chunkHeight > 30 || chunkHeight < 5) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    (int32 chunkX, int32 chunkZ) = getChunkCoord(x, z);
    uint16 hash = getCoordHash(chunkX, chunkZ);
    if (hash >= 100) return TerrainData({ objectTypeId: bytes32(0), properties: properties });

    bytes32 structObjectTypeId = bytes32(0);
    ObjectProperties memory structObjectProperties;
    if (biome == uint8(Biome.Mountains)) {
      (structObjectTypeId, structObjectProperties) = RubberTree(chunkOffset);
    } else if (biome == uint8(Biome.Desert)) {
      (structObjectTypeId, structObjectProperties) = SakuraTree(chunkOffset);
    } else if (biome == uint8(Biome.Forest)) {
      (structObjectTypeId, structObjectProperties) = OakTree(chunkOffset);
    } else if (biome == uint8(Biome.Savanna)) {
      (structObjectTypeId, structObjectProperties) = BirchTree(chunkOffset);
    }

    if (structObjectTypeId != bytes32(0)) {
      return TerrainData({ objectTypeId: structObjectTypeId, properties: structObjectProperties });
    }

    return TerrainData({ objectTypeId: bytes32(0), properties: properties });
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Structures
  //////////////////////////////////////////////////////////////////////////////////////

  function OakTree(VoxelCoord memory offset) internal view returns (bytes32, ObjectProperties memory) {
    ObjectProperties memory properties;

    properties.mass = OAK_LOG_MASS;
    properties.energy = 100;
    // Trunk
    if (coordEq(offset, [3, 0, 3])) return (OakLogObjectID, properties);
    if (coordEq(offset, [3, 1, 3])) return (OakLogObjectID, properties);
    if (coordEq(offset, [3, 2, 3])) return (OakLogObjectID, properties);
    if (coordEq(offset, [3, 3, 3])) return (OakLogObjectID, properties);

    properties.mass = OAK_LEAF_MASS;
    properties.energy = 50;
    // Leaves
    if (coordEq(offset, [2, 3, 3])) return (OakLeafObjectID, properties);
    if (coordEq(offset, [3, 3, 2])) return (OakLeafObjectID, properties);
    if (coordEq(offset, [4, 3, 3])) return (OakLeafObjectID, properties);
    if (coordEq(offset, [3, 3, 4])) return (OakLeafObjectID, properties);
    if (coordEq(offset, [2, 3, 2])) return (OakLeafObjectID, properties);
    if (coordEq(offset, [4, 3, 4])) return (OakLeafObjectID, properties);
    if (coordEq(offset, [2, 3, 4])) return (OakLeafObjectID, properties);
    if (coordEq(offset, [4, 3, 2])) return (OakLeafObjectID, properties);
    if (coordEq(offset, [2, 4, 3])) return (OakLeafObjectID, properties);
    if (coordEq(offset, [3, 4, 2])) return (OakLeafObjectID, properties);
    if (coordEq(offset, [4, 4, 3])) return (OakLeafObjectID, properties);
    if (coordEq(offset, [3, 4, 4])) return (OakLeafObjectID, properties);
    if (coordEq(offset, [3, 4, 3])) return (OakLeafObjectID, properties);

    return (bytes32(0), properties);
  }

  function BirchTree(VoxelCoord memory offset) internal view returns (bytes32, ObjectProperties memory) {
    ObjectProperties memory properties;

    properties.mass = BIRCH_LOG_MASS;
    properties.energy = 100;
    // Trunk
    if (coordEq(offset, [3, 0, 3])) return (BirchLogObjectID, properties);
    if (coordEq(offset, [3, 1, 3])) return (BirchLogObjectID, properties);
    if (coordEq(offset, [3, 2, 3])) return (BirchLogObjectID, properties);
    if (coordEq(offset, [3, 3, 3])) return (BirchLogObjectID, properties);

    properties.mass = BIRCH_LEAF_MASS;
    properties.energy = 50;
    // Leaves
    if (coordEq(offset, [2, 3, 3])) return (BirchLeafObjectID, properties);
    if (coordEq(offset, [3, 3, 2])) return (BirchLeafObjectID, properties);
    if (coordEq(offset, [4, 3, 3])) return (BirchLeafObjectID, properties);
    if (coordEq(offset, [3, 3, 4])) return (BirchLeafObjectID, properties);
    if (coordEq(offset, [2, 3, 2])) return (BirchLeafObjectID, properties);
    if (coordEq(offset, [4, 3, 4])) return (BirchLeafObjectID, properties);
    if (coordEq(offset, [2, 3, 4])) return (BirchLeafObjectID, properties);
    if (coordEq(offset, [4, 3, 2])) return (BirchLeafObjectID, properties);
    if (coordEq(offset, [2, 4, 3])) return (BirchLeafObjectID, properties);
    if (coordEq(offset, [3, 4, 2])) return (BirchLeafObjectID, properties);
    if (coordEq(offset, [4, 4, 3])) return (BirchLeafObjectID, properties);
    if (coordEq(offset, [3, 4, 4])) return (BirchLeafObjectID, properties);
    if (coordEq(offset, [3, 4, 3])) return (BirchLeafObjectID, properties);

    return (bytes32(0), properties);
  }

  function SakuraTree(VoxelCoord memory offset) internal view returns (bytes32, ObjectProperties memory) {
    ObjectProperties memory properties;

    properties.mass = SAKURA_LOG_MASS;
    properties.energy = 100;
    // Trunk
    if (coordEq(offset, [3, 0, 3])) return (SakuraLogObjectID, properties);
    if (coordEq(offset, [3, 1, 3])) return (SakuraLogObjectID, properties);
    if (coordEq(offset, [3, 2, 3])) return (SakuraLogObjectID, properties);
    if (coordEq(offset, [3, 3, 3])) return (SakuraLogObjectID, properties);

    properties.mass = SAKURA_LEAF_MASS;
    properties.energy = 50;
    // Leaves
    if (coordEq(offset, [2, 3, 3])) return (SakuraLeafObjectID, properties);
    if (coordEq(offset, [3, 3, 2])) return (SakuraLeafObjectID, properties);
    if (coordEq(offset, [4, 3, 3])) return (SakuraLeafObjectID, properties);
    if (coordEq(offset, [3, 3, 4])) return (SakuraLeafObjectID, properties);
    if (coordEq(offset, [2, 3, 2])) return (SakuraLeafObjectID, properties);
    if (coordEq(offset, [4, 3, 4])) return (SakuraLeafObjectID, properties);
    if (coordEq(offset, [2, 3, 4])) return (SakuraLeafObjectID, properties);
    if (coordEq(offset, [4, 3, 2])) return (SakuraLeafObjectID, properties);
    if (coordEq(offset, [2, 4, 3])) return (SakuraLeafObjectID, properties);
    if (coordEq(offset, [3, 4, 2])) return (SakuraLeafObjectID, properties);
    if (coordEq(offset, [4, 4, 3])) return (SakuraLeafObjectID, properties);
    if (coordEq(offset, [3, 4, 4])) return (SakuraLeafObjectID, properties);
    if (coordEq(offset, [3, 4, 3])) return (SakuraLeafObjectID, properties);

    return (bytes32(0), properties);
  }

  function RubberTree(VoxelCoord memory offset) internal view returns (bytes32, ObjectProperties memory) {
    ObjectProperties memory properties;

    properties.mass = RUBBER_LOG_MASS;
    properties.energy = 100;
    // Trunk
    if (coordEq(offset, [3, 0, 3])) return (RubberLogObjectID, properties);
    if (coordEq(offset, [3, 1, 3])) return (RubberLogObjectID, properties);
    if (coordEq(offset, [3, 2, 3])) return (RubberLogObjectID, properties);
    if (coordEq(offset, [3, 3, 3])) return (RubberLogObjectID, properties);

    properties.mass = RUBBER_LEAF_MASS;
    properties.energy = 50;
    // Leaves
    if (coordEq(offset, [2, 3, 3])) return (RubberLeafObjectID, properties);
    if (coordEq(offset, [3, 3, 2])) return (RubberLeafObjectID, properties);
    if (coordEq(offset, [4, 3, 3])) return (RubberLeafObjectID, properties);
    if (coordEq(offset, [3, 3, 4])) return (RubberLeafObjectID, properties);
    if (coordEq(offset, [2, 3, 2])) return (RubberLeafObjectID, properties);
    if (coordEq(offset, [4, 3, 4])) return (RubberLeafObjectID, properties);
    if (coordEq(offset, [2, 3, 4])) return (RubberLeafObjectID, properties);
    if (coordEq(offset, [4, 3, 2])) return (RubberLeafObjectID, properties);
    if (coordEq(offset, [2, 4, 3])) return (RubberLeafObjectID, properties);
    if (coordEq(offset, [3, 4, 2])) return (RubberLeafObjectID, properties);
    if (coordEq(offset, [4, 4, 3])) return (RubberLeafObjectID, properties);
    if (coordEq(offset, [3, 4, 4])) return (RubberLeafObjectID, properties);
    if (coordEq(offset, [3, 4, 3])) return (RubberLeafObjectID, properties);

    return (bytes32(0), properties);
  }
}
