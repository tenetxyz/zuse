// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

//import { Perlin } from "noise/world.sol";
//import { Perlin } from "./Perlin.sol";
import { ABDKMath64x64 as Math } from "../libraries/ABDKMath64x64.sol";
import { Biome, STRUCTURE_CHUNK, STRUCTURE_CHUNK_CENTER } from "../Constants.sol";
import { AirID } from "./voxels/AirVoxelSystem.sol";
import { GrassID } from "./voxels/GrassVoxelSystem.sol";
import { DirtID } from "./voxels/DirtVoxelSystem.sol";
import { BedrockID } from "./voxels/BedrockVoxelSystem.sol";

import { VoxelCoord, Tuple, VoxelVariantsKey } from "../Types.sol";
import { div } from "../Utils.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { CHUNK_MIN_Y, TENET_NAMESPACE, EMPTY_NAMESPACE, EMPTY_ID } from "../Constants.sol";

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
  function getTerrainVoxel(VoxelCoord memory coord) public view returns (VoxelVariantsKey memory) {
    // int128[4] memory biome = getBiome(coord.x, coord.z);
    // int32 height = getHeight(coord.x, coord.z, biome);
    return getTerrainVoxel(coord.x, coord.y, coord.z);
  }

  function getTerrainVoxel(
    int32 x,
    int32 y,
    int32 z
  )
    internal
    view
    returns (
      // int32 height,
      // int128[4] memory biomeValues
      VoxelVariantsKey memory
    )
  {
    VoxelVariantsKey memory voxelTypeId;

    voxelTypeId = Bedrock(y);
    if (voxelTypeId.voxelVariantId != EMPTY_ID) return voxelTypeId;

    voxelTypeId = Air(y);
    if (voxelTypeId.voxelVariantId != EMPTY_ID) return voxelTypeId;

    voxelTypeId = Grass(y);
    if (voxelTypeId.voxelVariantId != EMPTY_ID) return voxelTypeId;

    voxelTypeId = Dirt(y);
    if (voxelTypeId.voxelVariantId != EMPTY_ID) return voxelTypeId;

    return VoxelVariantsKey({ voxelVariantNamespace: EMPTY_NAMESPACE, voxelVariantId: EMPTY_ID });
  }

  function getHeight(int32 x, int32 z, int128[4] memory biome) internal view returns (int32) {
    // Compute perlin height
    int128 perlin999 = IWorld(_world()).tenet_PerlinSystem_noise2d(x - 550, z + 550, 999, 64);
    int128 continentalHeight = continentalness(perlin999);
    int128 terrainHeight = Math.mul(perlin999, _10);
    int128 perlin49 = IWorld(_world()).tenet_PerlinSystem_noise2d(x, z, 49, 64);
    terrainHeight = Math.add(terrainHeight, Math.mul(perlin49, _5));
    terrainHeight = Math.add(terrainHeight, IWorld(_world()).tenet_PerlinSystem_noise2d(x, z, 13, 64));
    terrainHeight = Math.div(terrainHeight, _16);

    // Compute biome height
    int128 height = Math.mul(biome[uint256(Biome.Mountains)], mountains(terrainHeight));
    height = Math.add(height, Math.mul(biome[uint256(Biome.Desert)], desert(terrainHeight)));
    height = Math.add(height, Math.mul(biome[uint256(Biome.Forest)], forest(terrainHeight)));
    height = Math.add(height, Math.mul(biome[uint256(Biome.Savanna)], savanna(terrainHeight)));
    height = Math.div(height, Math.add(Math.add(Math.add(Math.add(biome[0], biome[1]), biome[2]), biome[3]), _1));

    height = Math.add(continentalHeight, Math.div(height, _2));

    // Create valleys
    int128 valley = valleys(
      Math.div(Math.add(Math.mul(IWorld(_world()).tenet_PerlinSystem_noise2d(x, z, 333, 64), _2), perlin49), _3)
    );
    height = Math.mul(height, valley);

    // Scale height
    return int32(Math.muli(height, 256) - 128);
  }

  function getBiome(int32 x, int32 z) internal view returns (int128[4] memory) {
    int128 heat = IWorld(_world()).tenet_PerlinSystem_noise2d(x + 222, z + 222, 444, 64);
    int128 humidity = IWorld(_world()).tenet_PerlinSystem_noise(z, x, 999, 333, 64);

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

  function getMaxBiome(int128[4] memory biomeValues) internal pure returns (uint8 biome) {
    int128 maxBiome;
    for (uint256 i; i < biomeValues.length; i++) {
      if (biomeValues[i] > maxBiome) {
        maxBiome = biomeValues[i];
        biome = uint8(i);
      }
    }
  }

  function getBiomeVector(Biome biome) internal pure returns (Tuple memory) {
    if (biome == Biome.Mountains) return Tuple(_0, _0);
    if (biome == Biome.Desert) return Tuple(_0, _1);
    if (biome == Biome.Forest) return Tuple(_1, _0);
    if (biome == Biome.Savanna) return Tuple(_1, _1);
    revert("unknown biome");
  }

  function getCoordHash(int32 x, int32 z) internal pure returns (uint16) {
    uint256 hash = uint256(keccak256(abi.encode(x, z)));
    return uint16(hash % 1024);
  }

  function getChunkCoord(int32 x, int32 z) internal pure returns (int32, int32) {
    return (div(x, STRUCTURE_CHUNK), div(z, STRUCTURE_CHUNK));
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
    height = getHeight(chunkCenterX, chunkCenterZ, biome);
    offset = VoxelCoord(x - chunkX * STRUCTURE_CHUNK, y - height, z - chunkZ * STRUCTURE_CHUNK);
  }

  function getBiomeHash(int32 x, int32 y, uint8 biome) internal pure returns (uint16) {
    return getCoordHash(div(x, 300) + div(y, 300), int32(uint32(biome)));
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Utils
  //////////////////////////////////////////////////////////////////////////////////////

  // return Math.sqrt(Math.pow(a[0] - b[0], 2) + Math.pow(a[1] - b[1], 2));
  function euclidean(Tuple memory a, Tuple memory b) internal pure returns (int128) {
    return Math.sqrt(Math.add(Math.pow(Math.sub(a.x, b.x), 2), Math.pow(Math.sub(a.y, b.y), 2)));
  }

  function euclideanVec(int128[] memory a, int128[] memory b) internal pure returns (int128) {
    return euclidean(Tuple(a[0], a[1]), Tuple(b[0], b[1]));
  }

  function euclideanRaw(int128 a0, int128 a1, int128 b0, int128 b1) internal pure returns (int128) {
    return euclidean(Tuple(a0, a1), Tuple(b0, b1));
  }

  function pos(int128 x) internal pure returns (int128) {
    return x < 0 ? int128(0) : x;
  }

  function coordEq(VoxelCoord memory a, uint8[3] memory b) internal pure returns (bool) {
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
    return IWorld(_world()).tenet_PerlinSystem_lerp(t, points[0].y, points[1].y);
  }

  function continentalness(int128 x) internal view returns (int128) {
    Tuple[] memory splines = new Tuple[](3);
    splines[0] = Tuple(_0, _0);
    splines[1] = Tuple(_0_5, _0_5);
    splines[2] = Tuple(_1, _0_5);
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
  // voxel occurrence functions
  //////////////////////////////////////////////////////////////////////////////////////

  function Air(VoxelCoord memory coord) public pure returns (VoxelVariantsKey memory) {
    return Air(coord.y);
  }

  function Air(int32 y) internal pure returns (VoxelVariantsKey memory) {
    if (y > 10) {
      return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: AirID });
    }

    return VoxelVariantsKey({ voxelVariantNamespace: EMPTY_NAMESPACE, voxelVariantId: EMPTY_ID });
  }

  function Bedrock(VoxelCoord memory coord) public pure returns (VoxelVariantsKey memory) {
    return Bedrock(coord.y);
  }

  function Bedrock(int32 y) internal pure returns (VoxelVariantsKey memory) {
    if (y <= CHUNK_MIN_Y) {
      return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: BedrockID });
    }

    return VoxelVariantsKey({ voxelVariantNamespace: EMPTY_NAMESPACE, voxelVariantId: EMPTY_ID });
  }

  function Grass(VoxelCoord memory coord) public pure returns (VoxelVariantsKey memory) {
    return Grass(coord.y);
  }

  function Grass(int32 y) internal pure returns (VoxelVariantsKey memory) {
    if (y == 10) {
      return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: GrassID });
    }

    return VoxelVariantsKey({ voxelVariantNamespace: EMPTY_NAMESPACE, voxelVariantId: EMPTY_ID });
  }

  function Dirt(VoxelCoord memory coord) public pure returns (VoxelVariantsKey memory) {
    return Dirt(coord.y);
  }

  function Dirt(int32 y) internal pure returns (VoxelVariantsKey memory) {
    if (y > CHUNK_MIN_Y && y < 10) {
      return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: DirtID });
    }

    return VoxelVariantsKey({ voxelVariantNamespace: EMPTY_NAMESPACE, voxelVariantId: EMPTY_ID });
  }
}
