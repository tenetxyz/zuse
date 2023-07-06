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
    // Call world init function
    IWorld world = IWorld(worldAddress);

    // Register all the voxels
    world.extension_SandSystem_registerSandVoxel();
    world.extension_LogSystem_registerLogVoxel();
    world.extension_FlowerSystem_registerFlowerVoxels();
    world.extension_SignalSystem_registerSignalVoxel();
    world.extension_InvertedSignalSy_registerInvertedSignalVoxel();
    world.extension_SignalSourceSyst_registerSignalSourceVoxel();
    world.extension_PoweredSystem_registerPoweredVoxel();

    // Note: These have to be here instead of ExtensionInitSystem as they have be called from the deployer account
    // otherwise the msgSender is not the namespace owner
    registerClassifier(
      "AND Gate",
      "Classifies if this creation is an AND Gate",
      IWorld(worldAddress).extension_AndGateSystem_classify.selector,
      worldAddress
    );
    vm.stopBroadcast();
  }

  function registerClassifier(
    string memory classifierName,
    string memory classifierDescription,
    bytes4 classifySelector,
    address worldAddress
  ) private {
    (bool success, bytes memory result) = worldAddress.call(
      abi.encodeWithSignature(
        "tenet_RegClassifierSys_registerClassifier(bytes4,string,string)",
        classifySelector,
        classifierName,
        classifierDescription
      )
    );
    require(success, string(abi.encodePacked("Failed to register classifier: ", classifierName)));
  }
}
