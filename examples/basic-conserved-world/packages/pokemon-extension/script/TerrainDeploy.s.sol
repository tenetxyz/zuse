// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { SHARD_DIM } from "@tenet-utils/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";

contract TerrainDeploy is Script {
  function run(address worldAddress, address mainWorldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // VoxelCoord memory shardCoord = VoxelCoord({ x: 3, y: 0, z: 0 });
    // uint256[] memory bucketCounts = new uint256[](3);

    // for (int32 x = shardCoord.x * SHARD_DIM; x < (shardCoord.x + 1) * SHARD_DIM; x++) {
    //   for (int32 y = shardCoord.y * SHARD_DIM; y < (shardCoord.y + 1) * SHARD_DIM; y++) {
    //     for (int32 z = shardCoord.z * SHARD_DIM; z < (shardCoord.z + 1) * SHARD_DIM; z++) {
    //       VoxelCoord memory coord = VoxelCoord({ x: x, y: y, z: z });
    //       uint256 bucketIndex = IWorld(worldAddress).pokemon_PokemonTerrainSy_getPokemonBucketIndex(coord);
    //       console.log("coord");
    //       console.logInt(x);
    //       console.logInt(y);
    //       console.logInt(z);
    //       console.log("bucket");
    //       console.logUint(bucketIndex);
    //       bucketCounts[bucketIndex] += 1;
    //       break;
    //     }
    //     break;
    //   }
    //   break;
    // }
    // console.log("bucketCounts");
    // console.logUint(bucketCounts[0]);
    // console.logUint(bucketCounts[1]);
    // console.logUint(bucketCounts[2]);

    IWorld(worldAddress).pokemon_PokemonTerrainSy_initPokemonTerrain(mainWorldAddress);

    vm.stopBroadcast();
  }
}
