// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { SignalData, InvertedSignalData } from "../codegen/Tables.sol";
import { VoxelVariantsKey } from "../types.sol";
import { defineVoxels, SandID, LogID, OrangeFlowerID, SignalOffID, SignalOnID, SignalSourceID } from "../prototypes/Voxels.sol";
import { TENET_NAMESPACE } from "@tenetxyz/contracts/src/constants.sol";

contract ExtensionInitSystem is System {
  function sandVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: SandID });
  }

  function logVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: LogID });
  }

  function orangeFlowerVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: OrangeFlowerID });
  }

  function signalVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    SignalData memory signalData = IWorld(_world()).tenet_SignalSystem_getOrCreateSignal(entity);
    if (signalData.isActive) {
      return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: SignalOnID });
    } else {
      return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: SignalOffID });
    }
  }

  function invertedSignalVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    InvertedSignalData memory invertedSignalData = IWorld(_world()).tenet_InvertedSignalSy_getOrCreateInvertedSignal(
      entity
    );
    if (invertedSignalData.isActive) {
      return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: SignalOnID });
    } else {
      return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: SignalOffID });
    }
  }

  function signalSourceVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    IWorld(_world()).tenet_SignalSourceSyst_getOrCreateSignalSource(entity);
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: SignalSourceID });
  }

  function init() public {
    defineVoxels(_world());
  }
}
