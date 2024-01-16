// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { ABDKMath64x64 as Math } from "@tenet-utils/src/libraries/ABDKMath64x64.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { ISimInitSystem } from "@tenet-base-simulator/src/codegen/world/ISimInitSystem.sol";
import { Position, ObjectType, ObjectEntity, Faucet, FaucetData, FaucetTableId, OwnedBy, TerrainProperties, TerrainPropertiesTableId } from "@tenet-world/src/codegen/Tables.sol";
import { TerrainData } from "@tenet-world/src/Types.sol";

import { safeStaticCall, safeCall } from "@tenet-utils/src/CallUtils.sol";
import { SIMULATOR_ADDRESS, SHARD_DIM, AIR_MASS, DIRT_MASS, GRASS_MASS, BEDROCK_MASS, STONE_MASS, SAND_MASS, SNOW_MASS, AirObjectID, DirtObjectID, GrassObjectID, BedrockObjectID, SandObjectID, SnowObjectID, StoneObjectID, FaucetObjectID } from "@tenet-world/src/Constants.sol";
import { TerrainSystem as TerrainProtoSystem } from "@tenet-base-world/src/systems/TerrainSystem.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";

int128 constant _0 = 0; // 0 * 2**64
int128 constant _0_5 = 9223372036854775808; // 0.5 * 2**64
int128 constant _1 = 2 ** 64;
int128 constant _2 = 2 * 2 ** 64;
int128 constant _5 = 5 * 2 ** 64;
int128 constant _10 = 10 * 2 ** 64;
int128 constant _16 = 16 * 2 ** 64;

struct Tuple {
  int128 x;
  int128 y;
}

// Spline functions and inspiration from https://github.com/latticexyz/opcraft/blob/main/packages/contracts/src/libraries/LibTerrain.sol
contract TerrainSystem is TerrainProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function emptyObjectId() internal pure override returns (bytes32) {
    return AirObjectID;
  }

  function spawnInitialFaucets() public {
    bytes32[][] memory numFaucets = getKeysInTable(FaucetTableId);
    require(numFaucets.length == 0, "TerrainSystem: Faucets already spawned");

    VoxelCoord memory faucetCoord1 = VoxelCoord(50, 10, 50);
    setFaucetAgent(faucetCoord1);
  }

  function setFaucetAgent(VoxelCoord memory coord) internal {
    bytes32 objectTypeId = FaucetObjectID;

    // Create entity
    bytes32 eventEntityId = getUniqueEntity();
    Position.set(eventEntityId, coord.x, coord.y, coord.z);
    ObjectType.set(eventEntityId, objectTypeId);
    bytes32 objectEntityId = getUniqueEntity();
    ObjectEntity.set(eventEntityId, objectEntityId);

    // This will place the agent, so it will check if the object there is air
    ObjectProperties memory faucetProperties = IWorld(_world()).enterWorld(objectTypeId, coord, objectEntityId);
    ISimInitSystem(SIMULATOR_ADDRESS).initObject(objectEntityId, faucetProperties);

    // TODO: Make this the world contract, so that FaucetSystem can build using it
    OwnedBy.set(objectEntityId, address(0)); // Set owner to 0 so no one can claim it
    Faucet.set(objectEntityId, FaucetData({ claimers: new address[](0), claimerAmounts: new uint256[](0) }));
  }

  function getTerrainObjectTypeId(VoxelCoord memory coord) public view override returns (bytes32) {
    return getTerrainObjectData(coord).objectTypeId;
  }

  function getTerrainObjectProperties(
    VoxelCoord memory coord,
    ObjectProperties memory requestedProperties
  ) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    // use cache if possible
    if (hasKey(TerrainPropertiesTableId, TerrainProperties.encodeKeyTuple(coord.x, coord.y, coord.z))) {
      bytes memory encodedTerrainProperties = TerrainProperties.get(coord.x, coord.y, coord.z);
      return abi.decode(encodedTerrainProperties, (ObjectProperties));
    }

    objectProperties = getTerrainObjectData(coord).properties;

    TerrainProperties.set(coord.x, coord.y, coord.z, abi.encode(objectProperties));

    return objectProperties;
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
    Tuple[] memory splines = new Tuple[](3);
    splines[0] = Tuple(_0, _0);
    splines[1] = Tuple(_0_5, _0_5);
    splines[2] = Tuple(_1, _0_5);
    return applySpline(x, splines);
  }

  function getTerrainObjectData(VoxelCoord memory coord) internal view returns (TerrainData memory) {
    ObjectProperties memory properties;

    // Compute perlin height
    int128 perlin999 = IWorld(_world()).world_PerlinSystem_noise2d(coord.x - 550, coord.z + 550, 149, 64);
    int128 continentalHeight = continentalness(perlin999);
    int128 terrainHeight = Math.mul(perlin999, _10);
    int128 perlin49 = IWorld(_world()).world_PerlinSystem_noise2d(coord.x, coord.z, 49, 64);
    terrainHeight = Math.add(terrainHeight, Math.mul(perlin49, _5));
    terrainHeight = Math.add(terrainHeight, IWorld(_world()).world_PerlinSystem_noise2d(coord.x, coord.z, 13, 64));
    terrainHeight = Math.div(terrainHeight, _16);

    int128 height = terrainHeight;
    height = Math.add(continentalHeight, Math.div(height, _2));

    // Scale height
    height = int32(Math.muli(height, 256) - 70);

    if (coord.y < height) {
      if (coord.y > 30) {
        if (coord.y > 70) {
          properties.mass = SNOW_MASS;
          properties.energy = 200;
          return TerrainData({ objectTypeId: SnowObjectID, properties: properties });
        } else {
          properties.mass = STONE_MASS;
          properties.energy = 100;
          return TerrainData({ objectTypeId: StoneObjectID, properties: properties });
        }
      } else if (coord.y < 5) {
        if (coord.y < -10) {
          properties.mass = BEDROCK_MASS;
          properties.energy = 500;
          return TerrainData({ objectTypeId: BedrockObjectID, properties: properties });
        } else {
          properties.mass = SAND_MASS;
          properties.energy = 50;
          return TerrainData({ objectTypeId: SandObjectID, properties: properties });
        }
      } else {
        if (coord.y == height - 1) {
          properties.mass = GRASS_MASS;
          properties.energy = 100;
          return TerrainData({ objectTypeId: GrassObjectID, properties: properties });
        } else {
          properties.mass = DIRT_MASS;
          properties.energy = 50;
          return TerrainData({ objectTypeId: DirtObjectID, properties: properties });
        }
      }
    }

    properties.mass = AIR_MASS;
    properties.energy = 0;
    return TerrainData({ objectTypeId: AirObjectID, properties: properties });
  }
}
