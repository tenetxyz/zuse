// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Script } from "forge-std/Script.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { console } from "forge-std/console.sol";
import { IShardSystem } from "@tenet-world/src/codegen/world/IShardSystem.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";

contract VerifySpawn is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // Call world init function
    IShardSystem world = IShardSystem(worldAddress);
    IStore store = IStore(worldAddress);

    VoxelCoord memory spawnCoord = VoxelCoord({ x: 0, y: 0, z: 0 });
    VoxelCoord memory faucetAgentCoord = VoxelCoord({ x: 0, y: 10, z: 0 });
    world.verifyShard(spawnCoord, faucetAgentCoord);

    vm.stopBroadcast();
  }
}
