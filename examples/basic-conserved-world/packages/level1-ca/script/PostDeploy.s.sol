// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { registerDecisionRule } from "@tenet-registry/src/Utils.sol";
import { FaucetVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { REGISTRY_ADDRESS } from "../src/Constants.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // Register the voxel types
    IWorld(worldAddress).ca_AirVoxelSystem_registerBody();
    IWorld(worldAddress).ca_DirtVoxelSystem_registerBody();
    IWorld(worldAddress).ca_GrassVoxelSystem_registerBody();
    IWorld(worldAddress).ca_BedrockVoxelSyst_registerBody();
    IWorld(worldAddress).ca_FaucetAgentSyste_registerBody();
    IWorld(worldAddress).ca_CobblestoneBrick_registerBody();
    IWorld(worldAddress).ca_CobblestoneShing_registerBody();
    IWorld(worldAddress).ca_GlassVoxelSystem_registerBody();

    IWorld(worldAddress).registerCA();

    vm.stopBroadcast();
  }
}
