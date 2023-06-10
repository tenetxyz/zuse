// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // ------------------ EXAMPLES ------------------

    // Call increment on the world via the registered function selector
    // uint32 newValue = IWorld(worldAddress).dhvani_IncrementSystem_increment();
    // console.log("Increment via IWorld:", newValue);

    // need to call registerExtension() in the world contract with PoweredSystem
    // address worldAddress = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    bytes4 poweredEventHandler = IWorld(worldAddress).dhvani_PoweredSystem_eventHandler.selector;
    address deployToWorldAddress = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    (bool success, bytes memory result) = deployToWorldAddress.call(abi.encodeWithSignature("tenet_ExtensionSystem_registerExtension(bytes4)", poweredEventHandler));
    console.log("success");
    console.logBool(success);

    vm.stopBroadcast();
  }
}