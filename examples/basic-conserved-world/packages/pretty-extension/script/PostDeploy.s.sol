// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // Register the voxel types
    IWorld(worldAddress).pretty_OakLogVoxelSyste_registerBody();
    IWorld(worldAddress).pretty_OakLumberStep236_registerBody();
    IWorld(worldAddress).pretty_OakLumberVoxelSy_registerBody();
    IWorld(worldAddress).pretty_OakLumberPeg812V_registerBody();
    IWorld(worldAddress).pretty_StoneVoxelSystem_registerBody();
    IWorld(worldAddress).pretty_OakLumberKnob903_registerBody();
    IWorld(worldAddress).pretty_OakLumberStep235_registerBody();
    IWorld(worldAddress).pretty_OakLumberKnob942_registerBody();
    IWorld(worldAddress).pretty_OakLumberStep194_registerBody();
    IWorld(worldAddress).pretty_OakLumberStep199_registerBody();
    IWorld(worldAddress).pretty_OakLumberFence32_registerBody();
    IWorld(worldAddress).pretty_OakLumberKnob939_registerBody();
    IWorld(worldAddress).pretty_OakLumberStep238_registerBody();
    IWorld(worldAddress).pretty_MossVoxelSystem_registerBody();
    IWorld(worldAddress).pretty_OakLogOutset1196_registerBody();
    IWorld(worldAddress).pretty_OakLogOutset1193_registerBody();
    IWorld(worldAddress).pretty_OakLogOutset1152_registerBody();
    IWorld(worldAddress).pretty_OakLumberPeg773V_registerBody();
    IWorld(worldAddress).pretty_OakLumberSlab172_registerBody();
    IWorld(worldAddress).pretty_OakLumberSlice74_registerBody();
    IWorld(worldAddress).pretty_OakLumberSlab133_registerBody();
    IWorld(worldAddress).pretty_OakLumberSlab169_registerBody();
    IWorld(worldAddress).pretty_OakLumberSlab128_registerBody();
    IWorld(worldAddress).pretty_OakLumberSlice70_registerBody();

    vm.stopBroadcast();
  }
}
