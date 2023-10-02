// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, BucketData } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { TerrainProperties, TerrainPropertiesTableId, BodyPhysics, BodyPhysicsData, VoxelTypeProperties } from "@tenet-world/src/codegen/Tables.sol";
import { getTerrainVoxelId } from "@tenet-base-ca/src/CallUtils.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";
import { SHARD_DIM } from "@tenet-level1-ca/src/Constants.sol";
import { coordToShardCoord } from "@tenet-level1-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract LibTerrainSystem is System {
  function getTerrainVoxel(VoxelCoord memory coord) public view returns (bytes32) {
    BucketData memory bucketData = getTerrainProperties(coord);
    return getTerrainVoxelFromBucket(bucketData, coord);
  }

  function getTerrainVoxelFromBucket(
    BucketData memory bucketData,
    VoxelCoord memory coord
  ) public view returns (bytes32) {
    if (bucketData.maxMass == 0) {
      return AirVoxelID;
    } else if (bucketData.minMass >= 0 && bucketData.maxMass <= 50) {
      return GrassVoxelID;
    } else {
      return BedrockVoxelID;
    }
  }

  function getTerrainBodyPhysicsData(
    address caAddress,
    VoxelCoord memory coord
  ) public returns (bytes32, BodyPhysicsData memory) {
    BodyPhysicsData memory data;

    BucketData memory bucketData = getTerrainProperties(coord);
    bytes32 voxelTypeId = getTerrainVoxelFromBucket(bucketData, coord);
    console.log("voxelTypeId");
    console.logUint(bucketData.minMass);
    console.logUint(bucketData.maxMass);
    console.logBytes32(voxelTypeId);
    uint256 voxelMass = VoxelTypeProperties.get(voxelTypeId);
    require(
      voxelMass >= bucketData.minMass && voxelMass <= bucketData.maxMass,
      "Terrain mass does not match voxel type mass"
    );

    data.mass = voxelMass;
    data.energy = bucketData.energy;
    data.velocity = abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 }));
    data.lastUpdateBlock = block.number;

    return (voxelTypeId, data);
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
      energy: 100,
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
    BucketData memory bucketData = getTerrainProperties(coord);
    uint256 voxelMass = VoxelTypeProperties.get(voxelTypeId);
    require(
      voxelMass >= bucketData.minMass && voxelMass <= bucketData.maxMass,
      "Terrain mass does not match voxel type mass"
    );
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
