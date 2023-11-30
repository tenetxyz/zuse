// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { Shard, ShardData, ShardTableId, TerrainProperties, TerrainPropertiesTableId } from "@tenet-world/src/codegen/Tables.sol";

import { safeStaticCall, safeCall } from "@tenet-utils/src/CallUtils.sol";
import { SIMULATOR_ADDRESS, SHARD_DIM, AirObjectID, NUM_MAX_TOTAL_ENERGY_IN_SHARD, NUM_MAX_TOTAL_MASS_IN_SHARD } from "@tenet-world/src/Constants.sol";
import { TerrainSystem as TerrainProtoSystem } from "@tenet-base-world/src/systems/TerrainSystem.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";

contract TerrainSystem is TerrainProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function emptyObjectId() internal pure override returns (bytes32) {
    return AirObjectID;
  }

  function decodeToBytes32(bytes memory data) external pure returns (bytes32) {
    return abi.decode(data, (bytes32));
  }

  function decodeToObjectProperties(bytes memory data) external pure returns (ObjectProperties memory) {
    return abi.decode(data, (ObjectProperties));
  }

  function getTerrainObjectTypeId(VoxelCoord memory coord) public view override returns (bytes32) {
    VoxelCoord memory shardCoord = coordToShardCoord(coord, SHARD_DIM);
    require(
      hasKey(ShardTableId, Shard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)),
      "TerrainSystem: Shard not claimed"
    );
    ShardData memory shardData = Shard.get(shardCoord.x, shardCoord.y, shardCoord.z);
    (bool terrainSelectorSuccess, bytes memory terrainSelectorReturnData) = safeStaticCall(
      shardData.contractAddress,
      abi.encodeWithSelector(shardData.objectTypeIdSelector, coord),
      "shard terrainSelector"
    );
    if (terrainSelectorSuccess) {
      try this.decodeToBytes32(terrainSelectorReturnData) returns (bytes32 terrainObjectTypeId) {
        return terrainObjectTypeId;
      } catch {}
    }

    return AirObjectID;
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

    VoxelCoord memory shardCoord = coordToShardCoord(coord, SHARD_DIM);
    require(
      hasKey(ShardTableId, Shard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)),
      "TerrainSystem: Shard not claimed"
    );
    ShardData memory shardData = Shard.get(shardCoord.x, shardCoord.y, shardCoord.z);
    (bool propertiesSelectorSuccess, bytes memory propertiesSelectorReturnData) = safeCall(
      shardData.contractAddress,
      abi.encodeWithSelector(shardData.objectPropertiesSelector, coord, requestedProperties),
      "shard terrainSelector"
    );
    if (propertiesSelectorSuccess) {
      try this.decodeToObjectProperties(propertiesSelectorReturnData) returns (ObjectProperties memory decodedValue) {
        objectProperties = decodedValue;
      } catch {}
    }

    // Enforce constraints on terrain
    if (shardData.totalGenMass + objectProperties.mass > NUM_MAX_TOTAL_MASS_IN_SHARD) {
      // Override mass
      objectProperties.mass = 0;
    } else {
      // Update shard data total mass
      shardData.totalGenMass += objectProperties.mass;
    }
    if (shardData.totalGenEnergy + objectProperties.energy > NUM_MAX_TOTAL_ENERGY_IN_SHARD) {
      // Override energy
      objectProperties.energy = 0;
    } else {
      // Update shard data total energy
      shardData.totalGenEnergy += objectProperties.energy;
    }
    Shard.set(shardCoord.x, shardCoord.y, shardCoord.z, shardData);
    TerrainProperties.set(coord.x, coord.y, coord.z, abi.encode(objectProperties));

    return objectProperties;
  }
}
