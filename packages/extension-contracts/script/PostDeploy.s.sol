// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { safeCall } from "../src/Utils.sol";
import { InterfaceVoxel } from "@tenet-contracts/src/Types.sol";

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
    world.extension_SandVoxelSystem_registerVoxel();
    world.extension_LogVoxelSystem_registerVoxel();
    world.extension_FlowerVoxelSyste_registerVoxel();
    world.extension_SignalVoxelSyste_registerVoxel();
    world.extension_InvertedSignalVo_registerVoxel();
    world.extension_SignalSourceVoxe_registerVoxel();
    world.extension_LavaVoxelSystem_registerVoxel();
    world.extension_IceVoxelSystem_registerVoxel();
    world.extension_ThermoGenVoxelSy_registerVoxel();
    world.extension_PowerWireVoxelSy_registerVoxel();
    world.extension_StorageVoxelSyste_registerVoxel();


    // Register all the voxel interactions
    world.extension_SignalSystem_registerInteraction();
    world.extension_InvertedSignalSy_registerInteraction();
    world.extension_PoweredSystem_registerInteraction();
    world.extension_TemperatureSyste_registerInteraction();
    world.extension_ThermoGeneratorS_registerInteraction();
    world.extension_PowerWireSystem_registerInteraction();
    world.extension_StorageSystem_registerInteraction();

    // Note: These have to be here instead of ExtensionInitSystem as they have be called from the deployer account
    // otherwise the msgSender is not the namespace owner
    InterfaceVoxel[] memory andGateInterface = new InterfaceVoxel[](3);
    andGateInterface[0] = InterfaceVoxel({
      index: 0,
      name: "Signal Source 1",
      desc: "The first signal source",
      entity: 0
    });
    andGateInterface[1] = InterfaceVoxel({
      index: 1,
      name: "Signal Source 2",
      desc: "The second signal source",
      entity: 0
    });
    andGateInterface[2] = InterfaceVoxel({
      index: 2,
      name: "Output Signal",
      desc: "The signal with the output",
      entity: 0
    });
    registerClassifier(
      "AND Gate",
      "Classifies if this creation is an AND Gate",
      IWorld(worldAddress).extension_AndGateSystem_classify.selector,
      "AndGateCR",
      andGateInterface,
      worldAddress
    );

    InterfaceVoxel[] memory dirtInterface = new InterfaceVoxel[](0);
    registerClassifier(
      "Two Dirt",
      "Make a creation that is two dirt voxels",
      IWorld(worldAddress).extension_TwoDirtSystem_classify.selector,
      "TwoDirtCR",
      dirtInterface,
      worldAddress
    );
    vm.stopBroadcast();
  }

  function registerClassifier(
    string memory classifierName,
    string memory classifierDescription,
    bytes4 classifySelector,
    string memory classificationResultTableName,
    InterfaceVoxel[] memory selectorInterface,
    address worldAddress
  ) private {
    safeCall(
      worldAddress,
      abi.encodeWithSignature(
        "tenet_RegClassifierSys_registerClassifier(bytes4,string,string,string,(uint256,bytes32,string,string)[])",
        classifySelector,
        classifierName,
        classifierDescription,
        classificationResultTableName,
        selectorInterface
      ),
      string(abi.encode("register classifier: ", classifierName))
    );
  }
}
