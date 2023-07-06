// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { SandID, LogID, OrangeFlowerID, SandTexture, LogTexture, OrangeFlowerTexture, SignalID, SignalOffTexture, SignalOnTexture, SignalSourceID, InvertedSignalID, SignalSourceTexture } from "../src/prototypes/Voxels.sol";
import { REGISTER_VOXEL_TYPE_SIG } from "@tenetxyz/contracts/src/constants.sol";

// import { bytes4ToString } from "../../contracts/src/Utils.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);
    // ------------------ EXAMPLES ------------------
    // Call world init function
    IWorld world = IWorld(worldAddress);
    world.tenet_ExtensionInitSys_init();
    // Note: These have to be here instead of ExtensionInitSystem as they have be called from the deployer account
    // otherwise the msgSender is not the namespace owner
    registerVoxelType(
      "Sand",
      SandID,
      SandTexture,
      world.tenet_ExtensionInitSys_sandVariantSelector.selector,
      worldAddress
    );
    registerVoxelType(
      "Log",
      LogID,
      LogTexture,
      IWorld(world).tenet_ExtensionInitSys_logVariantSelector.selector,
      worldAddress
    );
    registerVoxelType(
      "Orange Flower",
      OrangeFlowerID,
      OrangeFlowerTexture,
      IWorld(world).tenet_ExtensionInitSys_orangeFlowerVariantSelector.selector,
      worldAddress
    );
    registerVoxelType(
      "Signal",
      SignalID,
      SignalOffTexture,
      IWorld(world).tenet_ExtensionInitSys_signalVariantSelector.selector,
      worldAddress
    );
    registerVoxelType(
      "Signal Source",
      SignalSourceID,
      SignalSourceTexture,
      IWorld(world).tenet_ExtensionInitSys_signalSourceVariantSelector.selector,
      worldAddress
    );
    registerVoxelType(
      "Inverted Signal",
      InvertedSignalID,
      SignalOnTexture,
      IWorld(world).tenet_ExtensionInitSys_invertedSignalVariantSelector.selector,
      worldAddress
    );

    registerExtension(
      "SignalSourceSystem",
      IWorld(worldAddress).tenet_SignalSourceSyst_eventHandler.selector,
      worldAddress
    );
    registerExtension("SignalSystem", IWorld(worldAddress).tenet_SignalSystem_eventHandler.selector, worldAddress);
    // need to call registerExtension() in the world contract with PoweredSystem
    registerExtension("PoweredSystem", IWorld(worldAddress).tenet_PoweredSystem_eventHandler.selector, worldAddress);
    registerExtension(
      "Inverted Signal System",
      IWorld(worldAddress).tenet_InvertedSignalSy_eventHandler.selector,
      worldAddress
    );

    registerClassifier(
      "AND Gate",
      "Classifies if this creation is an AND Gate",
      IWorld(worldAddress).tenet_AndGateSystem_classify.selector,
      worldAddress
    );
    vm.stopBroadcast();
  }

  function registerVoxelType(
    string memory voxelTypeName,
    bytes32 voxelTypeId,
    string memory defaultTextureHash,
    bytes4 variantSelector,
    address worldAddress
  ) private {
    (bool success, bytes memory result) = worldAddress.call(
      abi.encodeWithSignature(REGISTER_VOXEL_TYPE_SIG, voxelTypeName, voxelTypeId, defaultTextureHash, variantSelector)
    );
    require(success, string(abi.encodePacked("Failed to register voxelType: ", voxelTypeName)));
  }

  function registerExtension(string memory extensionName, bytes4 eventHandlerSelector, address worldAddress) private {
    (bool success, bytes memory result) = worldAddress.call(
      abi.encodeWithSignature("tenet_ExtensionSystem_registerExtension(bytes4)", eventHandlerSelector)
    );
    require(success, string(abi.encodePacked("Failed to register extension: ", extensionName)));
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
