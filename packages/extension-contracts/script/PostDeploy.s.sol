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
    (bool success, bytes memory result) = worldAddress.call(
      abi.encodeWithSignature(
        REGISTER_VOXEL_TYPE_SIG,
        SandID,
        SandTexture,
        world.tenet_ExtensionInitSys_sandVariantSelector.selector
      )
    );
    require(success, "Failed to register sand type");
    (success, result) = worldAddress.call(
      abi.encodeWithSignature(
        REGISTER_VOXEL_TYPE_SIG,
        LogID,
        LogTexture,
        IWorld(world).tenet_ExtensionInitSys_logVariantSelector.selector
      )
    );
    require(success, "Failed to register log type");
    (success, result) = worldAddress.call(
      abi.encodeWithSignature(
        REGISTER_VOXEL_TYPE_SIG,
        OrangeFlowerID,
        OrangeFlowerTexture,
        IWorld(world).tenet_ExtensionInitSys_orangeFlowerVariantSelector.selector
      )
    );
    require(success, "Failed to register orange flower type");
    (success, result) = worldAddress.call(
      abi.encodeWithSignature(
        REGISTER_VOXEL_TYPE_SIG,
        SignalID,
        SignalOffTexture,
        IWorld(world).tenet_ExtensionInitSys_signalVariantSelector.selector
      )
    );
    require(success, "Failed to register signal type");
    (success, result) = worldAddress.call(
      abi.encodeWithSignature(
        REGISTER_VOXEL_TYPE_SIG,
        SignalSourceID,
        SignalSourceTexture,
        IWorld(world).tenet_ExtensionInitSys_signalSourceVariantSelector.selector
      )
    );
    require(success, "Failed to register signal source type");
    (success, result) = worldAddress.call(
      abi.encodeWithSignature(
        REGISTER_VOXEL_TYPE_SIG,
        InvertedSignalID,
        SignalOnTexture,
        IWorld(world).tenet_ExtensionInitSys_invertedSignalVariantSelector.selector
      )
    );
    require(success, "Failed to register signal type");
    // need to call registerExtension() in the world contract with PoweredSystem
    bytes4 signalSourceEventHandler = IWorld(worldAddress).tenet_SignalSourceSyst_eventHandler.selector;
    bytes4 signalEventHandler = IWorld(worldAddress).tenet_SignalSystem_eventHandler.selector;
    bytes4 poweredEventHandler = IWorld(worldAddress).tenet_PoweredSystem_eventHandler.selector;
    bytes4 invertedSignalEventHandler = IWorld(worldAddress).tenet_InvertedSignalSy_eventHandler.selector;
    // TODO: we should write a script to simplify this process (for devs writing for our platform) if this is long-term
    (success, result) = worldAddress.call(
      abi.encodeWithSignature("tenet_ExtensionSystem_registerExtension(bytes4)", signalSourceEventHandler)
    );
    require(success, "Failed to registerExtension SignalSourceSystem");
    (success, result) = worldAddress.call(
      abi.encodeWithSignature("tenet_ExtensionSystem_registerExtension(bytes4)", signalEventHandler)
    );
    require(success, "Failed to registerExtension SignalSystem");
    (success, result) = worldAddress.call(
      abi.encodeWithSignature("tenet_ExtensionSystem_registerExtension(bytes4)", poweredEventHandler)
    );
    require(success, "Failed to registerExtension PoweredSystem");
    (success, result) = worldAddress.call(
      abi.encodeWithSignature("tenet_ExtensionSystem_registerExtension(bytes4)", invertedSignalEventHandler)
    );
    require(success, "Failed to registerExtension InvertedSignalSystem");
    bytes4 andGateClassifier = IWorld(worldAddress).tenet_AndGateSystem_classify.selector;
    (success, result) = worldAddress.call(
      abi.encodeWithSignature(
        "tenet_RegClassifierSys_registerClassifier(bytes4,string,string)",
        andGateClassifier,
        "AND Gate",
        "Classifies if this creation is an AND Gate"
      )
    );
    require(success, "Failed to registerClassifier AndGateClassifierSystem");
    vm.stopBroadcast();
  }
}
