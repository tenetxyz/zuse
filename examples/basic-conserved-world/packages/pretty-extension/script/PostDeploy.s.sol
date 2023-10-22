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
    IWorld(worldAddress).pretty_C16777237_registerBody();
IWorld(worldAddress).pretty_C5517_registerBody();
IWorld(worldAddress).pretty_C16777227_registerBody();
IWorld(worldAddress).pretty_C16777223_registerBody();
IWorld(worldAddress).pretty_C2556_registerBody();
IWorld(worldAddress).pretty_C6413010_registerBody();
IWorld(worldAddress).pretty_C16777225_registerBody();
IWorld(worldAddress).pretty_C40128_registerBody();
IWorld(worldAddress).pretty_C40_registerBody();
IWorld(worldAddress).pretty_C16777217_registerBody();
IWorld(worldAddress).pretty_C3_registerBody();
IWorld(worldAddress).pretty_C3448_registerBody();
IWorld(worldAddress).pretty_C3453_registerBody();
IWorld(worldAddress).pretty_C3492_registerBody();
IWorld(worldAddress).pretty_C3111964_registerBody();
IWorld(worldAddress).pretty_C317684_registerBody();
IWorld(worldAddress).pretty_C317064_registerBody();
IWorld(worldAddress).pretty_C317504_registerBody();
IWorld(worldAddress).pretty_C3110244_registerBody();
IWorld(worldAddress).pretty_C3113444_registerBody();
IWorld(worldAddress).pretty_C16777229_registerBody();
IWorld(worldAddress).pretty_C74681_registerBody();
IWorld(worldAddress).pretty_C74684_registerBody();
IWorld(worldAddress).pretty_C741026_registerBody();
IWorld(worldAddress).pretty_C16777220_registerBody();

    vm.stopBroadcast();
  }
}
