// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenetxyz/contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { InvertedSignal, InvertedSignalData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { registerVoxelType, entityIsInvertedSignal } from "../../Utils.sol";
import { SignalOffID, SignalOnID, SignalOnTexture, SignalOnUVWrap } from "./SignalVoxelSystem.sol";
import { VoxelVariantsKey } from "@tenetxyz/contracts/src/Types.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";

bytes32 constant InvertedSignalID = bytes32(keccak256("invertedsignal"));

contract InvertedSignalVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    registerVoxelType(
      world,
      "Inverted Signal",
      InvertedSignalID,
      EXTENSION_NAMESPACE,
      SignalOnID,
      IWorld(world).extension_InvertedSignalVo_variantSelector.selector,
      IWorld(world).extension_InvertedSignalVo_enterWorld.selector,
      IWorld(world).extension_InvertedSignalVo_exitWorld.selector
    );
  }

  function enterWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    InvertedSignal.set(
      callerNamespace,
      entity,
      InvertedSignalData({ isActive: true, direction: BlockDirection.None, hasValue: true })
    );
  }

  function exitWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    InvertedSignal.deleteRecord(callerNamespace, entity);
  }

  function variantSelector(bytes32 entity) public view override returns (VoxelVariantsKey memory) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    InvertedSignalData memory invertedSignalData = InvertedSignal.get(callerNamespace, entity);
    if (invertedSignalData.isActive) {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SignalOnID });
    } else {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SignalOffID });
    }
  }
}
