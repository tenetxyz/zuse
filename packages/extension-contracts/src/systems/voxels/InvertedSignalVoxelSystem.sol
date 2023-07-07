// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenetxyz/contracts/src/prototypes/VoxelType.sol";

import { IWorld } from "../../../src/codegen/world/IWorld.sol";

import { Signal, InvertedSignal, SignalData, InvertedSignalData, SignalTableId, InvertedSignalTableId, SignalSource, SignalSourceTableId, PoweredData, Powered } from "../../codegen/Tables.sol";
import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { PositionData } from "@tenetxyz/contracts/src/codegen/tables/Position.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { registerExtension, registerVoxelType, entityIsSignal, entityIsInvertedSignal, entityIsPowered, entityIsSignalSource } from "../../Utils.sol";
import { SignalOffID, SignalOnID, SignalOnTexture } from "./SignalVoxelSystem.sol";
import { VoxelVariantsKey } from "../../Types.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";

bytes32 constant InvertedSignalID = bytes32(keccak256("invertedsignal"));

contract InvertedSignalVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    registerVoxelType(
      world,
      "Inverted Signal",
      InvertedSignalID,
      SignalOnTexture,
      IWorld(world).extension_InvertedSignalVo_invertedSignalVariantSelector.selector
    );
  }

  function invertedSignalVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    InvertedSignalData memory invertedSignalData = getOrCreateInvertedSignal(entity);
    if (invertedSignalData.isActive) {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SignalOnID });
    } else {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SignalOffID });
    }
  }

  function getOrCreateInvertedSignal(bytes32 entity) public returns (InvertedSignalData memory) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    if (!entityIsInvertedSignal(entity, callerNamespace)) {
      InvertedSignal.set(
        callerNamespace,
        entity,
        InvertedSignalData({ isActive: true, direction: BlockDirection.None, hasValue: true })
      );
    }

    return InvertedSignal.get(callerNamespace, entity);
  }
}
