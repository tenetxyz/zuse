// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, BucketData } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { TerrainProperties, TerrainPropertiesTableId } from "@tenet-world/src/codegen/Tables.sol";
import { getTerrainVoxelId } from "@tenet-base-ca/src/CallUtils.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";
import { SHARD_DIM } from "@tenet-level1-ca/src/Constants.sol";
import { coordToShardCoord } from "@tenet-level1-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

contract LibTerrainSystem is System {
  function getTerrainVoxel(VoxelCoord memory coord) public view returns (bytes32) {
    // Bucket solution
    // BucketData memory bucketData = getTerrainProperties(coord);
    // return getTerrainVoxelFromBucket(bucketData, coord);

    // Flat world solution
    address caAddress = BASE_CA_ADDRESS;
    bytes memory returnData = safeStaticCall(
      caAddress,
      abi.encodeWithSignature("ca_LibTerrainSystem_getTerrainVoxel((int32,int32,int32))", coord),
      string(abi.encode("ca_LibTerrainSystem_getTerrainVoxel ", coord))
    );
    return abi.decode(returnData, (bytes32));
  }

  function getTerrainMass(uint32 scale, VoxelCoord memory coord) public view returns (uint256) {
    // Bucket solution
    // BucketData memory bucketData = getTerrainProperties(coord);
    // bytes32 voxelTypeId = getTerrainVoxelFromBucket(bucketData, coord);

    // Flat world solution
    bytes32 voxelTypeId = getTerrainVoxel(coord);
    uint256 voxelMass = VoxelTypeRegistry.getMass(IStore(REGISTRY_ADDRESS), voxelTypeId);
    return voxelMass;
  }

  function getTerrainEnergy(uint32 scale, VoxelCoord memory coord) public view returns (uint256) {
    // Bucket solution
    // BucketData memory bucketData = getTerrainProperties(coord);
    // return bucketData.energy;

    // Flat world solution
    bytes32 voxelTypeId = getTerrainVoxel(coord);
    if (voxelTypeId == AirVoxelID) {
      return 0;
    } else if (voxelTypeId == BedrockVoxelID) {
      return 1;
    } else if (voxelTypeId == GrassVoxelID) {
      return 100;
    } else if (voxelTypeId == DirtVoxelID) {
      return 150;
    }
  }

  function getTerrainVelocity(uint32 scale, VoxelCoord memory coord) public view returns (VoxelCoord memory) {
    return VoxelCoord({ x: 0, y: 0, z: 0 });
  }

  function getTerrainVoxelFromBucket(
    BucketData memory bucketData,
    VoxelCoord memory coord
  ) public view returns (bytes32) {
    if (bucketData.id == 1) {
      return DirtVoxelID;
    } else if (bucketData.id == 2) {
      return GrassVoxelID;
    } else if (bucketData.id == 3) {
      return BedrockVoxelID;
    }

    return AirVoxelID;
  }

  function setTerrainProperties(VoxelCoord[] memory coords, uint8 bucketIndex) public {
    // TODO: add permissioning check
    for (uint256 i = 0; i < coords.length; i++) {
      TerrainProperties.set(coords[i].x, coords[i].y, coords[i].z, bucketIndex);
    }
  }

  function getTerrainProperties(VoxelCoord memory coord) public view returns (BucketData memory) {
    BucketData[] memory buckets = new BucketData[](4);
    buckets[0] = BucketData({ id: 0, minMass: 0, maxMass: 0, energy: 0, count: 0 });
    buckets[1] = BucketData({
      id: 1,
      minMass: 1,
      maxMass: 50,
      energy: 50,
      count: uint(int(6 * SHARD_DIM * SHARD_DIM))
    });
    buckets[2] = BucketData({
      id: 2,
      minMass: 50,
      maxMass: 100,
      energy: 75,
      count: uint(int(3 * SHARD_DIM * SHARD_DIM))
    });
    buckets[3] = BucketData({
      id: 3,
      minMass: 100,
      maxMass: 300,
      energy: 1000,
      count: uint(int(1 * SHARD_DIM * SHARD_DIM))
    });

    // Note; If the key doesn't exists, it'll return 0, and 0 currently maps to mass 0, energy 0 anyways
    // if (!hasKey(TerrainPropertiesTableId, TerrainProperties.encodeKeyTuple(coord.x, coord.y, coord.z))) {
    //   revert("No terrain properties found");
    // }

    uint256 bucketIndex = TerrainProperties.get(coord.x, coord.y, coord.z);
    require(bucketIndex < buckets.length, "Bucket index out of range");

    return buckets[bucketIndex];
  }

  // Called by CA's on terrain gen
  function onTerrainGen(bytes32 voxelTypeId, VoxelCoord memory coord) public {
    // address caAddress = _msgSender();
    console.log("on terrian gen");
    // TODO: Fix, should check mass matches

    // Bucket solution
    // BucketData memory bucketData = getTerrainProperties(coord);
    // uint256 voxelMass = VoxelTypeRegistry.getMass(IStore(REGISTRY_ADDRESS), voxelTypeId);
    // require(
    //   voxelMass >= bucketData.minMass && voxelMass <= bucketData.maxMass,
    //   "Terrain mass does not match voxel type mass"
    // );
  }

  function setTerrainSelector(VoxelCoord memory coord, address contractAddress, bytes4 terrainSelector) public {
    // TODO: Make this be any CA address
    address caAddress = BASE_CA_ADDRESS;
    safeCall(
      caAddress,
      abi.encodeWithSignature(
        "setTerrainSelector((int32,int32,int32),address,bytes4)",
        coord,
        contractAddress,
        terrainSelector
      ),
      string(abi.encode("setTerrainSelector ", coord, " ", terrainSelector))
    );
  }
}
