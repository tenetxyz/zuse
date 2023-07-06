// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { SignalData, InvertedSignalData } from "../codegen/Tables.sol";
import { VoxelVariantsKey } from "../types.sol";
import { defineVoxels, SandID, LogID, OrangeFlowerID, SignalOffID, SignalOnID, SignalSourceID } from "../prototypes/Voxels.sol";
import { EXTENSION_NAMESPACE } from "../Constants.sol";

contract ExtensionInitSystem is System {
  function sandVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SandID });
  }

  function logVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: LogID });
  }

  function orangeFlowerVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: OrangeFlowerID });
  }

  function init() public {
    defineVoxels(_world());
  }
}
