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
    IWorld(worldAddress).pretty_C5517_registerBody();
IWorld(worldAddress).pretty_C5_registerBody();
IWorld(worldAddress).pretty_C21_registerBody();
IWorld(worldAddress).pretty_C2556_registerBody();
IWorld(worldAddress).pretty_C11_registerBody();
IWorld(worldAddress).pretty_C13_registerBody();
IWorld(worldAddress).pretty_C6413010_registerBody();
IWorld(worldAddress).pretty_C9_registerBody();
IWorld(worldAddress).pretty_C40128_registerBody();
IWorld(worldAddress).pretty_C40_registerBody();
IWorld(worldAddress).pretty_C31152_registerBody();
IWorld(worldAddress).pretty_C31193_registerBody();
IWorld(worldAddress).pretty_C31196_registerBody();
IWorld(worldAddress).pretty_C3_registerBody();
IWorld(worldAddress).pretty_C3448_registerBody();
IWorld(worldAddress).pretty_C3453_registerBody();
IWorld(worldAddress).pretty_C3492_registerBody();
IWorld(worldAddress).pretty_C319_registerBody();
IWorld(worldAddress).pretty_C313259_registerBody();
IWorld(worldAddress).pretty_C319039_registerBody();
IWorld(worldAddress).pretty_C319399_registerBody();
IWorld(worldAddress).pretty_C319429_registerBody();
IWorld(worldAddress).pretty_C3111964_registerBody();
IWorld(worldAddress).pretty_C317684_registerBody();
IWorld(worldAddress).pretty_C317734_registerBody();
IWorld(worldAddress).pretty_C31773_registerBody();
IWorld(worldAddress).pretty_C318124_registerBody();
IWorld(worldAddress).pretty_C311289_registerBody();
IWorld(worldAddress).pretty_C311339_registerBody();
IWorld(worldAddress).pretty_C311699_registerBody();
IWorld(worldAddress).pretty_C311729_registerBody();
IWorld(worldAddress).pretty_C317064_registerBody();
IWorld(worldAddress).pretty_C31709_registerBody();
IWorld(worldAddress).pretty_C31748_registerBody();
IWorld(worldAddress).pretty_C317504_registerBody();
IWorld(worldAddress).pretty_C311949_registerBody();
IWorld(worldAddress).pretty_C311999_registerBody();
IWorld(worldAddress).pretty_C312359_registerBody();
IWorld(worldAddress).pretty_C312369_registerBody();
IWorld(worldAddress).pretty_C312365_registerBody();
IWorld(worldAddress).pretty_C312389_registerBody();
IWorld(worldAddress).pretty_C3110244_registerBody();
IWorld(worldAddress).pretty_C3113444_registerBody();
IWorld(worldAddress).pretty_C31_registerBody();
IWorld(worldAddress).pretty_C315_registerBody();
IWorld(worldAddress).pretty_C7_registerBody();
IWorld(worldAddress).pretty_C74681_registerBody();
IWorld(worldAddress).pretty_C74684_registerBody();
IWorld(worldAddress).pretty_C741026_registerBody();
IWorld(worldAddress).pretty_C4_registerBody();

    vm.stopBroadcast();
  }
}
