// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenetxyz/contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { SignalSource } from "../../codegen/Tables.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { registerVoxelType, registerVoxelVariant, entityIsSignalSource } from "../../Utils.sol";
import { VoxelVariantsData, VoxelVariantsKey } from "../../Types.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";

bytes32 constant SignalSourceID = bytes32(keccak256("signalsource"));

string constant SignalSourceTexture = "bafkreifciafvv63x3nnnsdvsccp45ggcx5xczfhoaz3xy3y5k666ma2m4y";

string constant SignalSourceUVWrap = "bafkreibyxohq35sq2fqujxffs5nfjdtfx5cmnqhnyliar2xbkqxgcd7d5u";

contract SignalSourceVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory signalSourceVariant;
    signalSourceVariant.blockType = NoaBlockType.BLOCK;
    signalSourceVariant.opaque = true;
    signalSourceVariant.solid = true;
    string[] memory signalSourceMaterials = new string[](1);
    signalSourceMaterials[0] = SignalSourceTexture;
    signalSourceVariant.materials = abi.encode(signalSourceMaterials);
    signalSourceVariant.uvWrap = SignalSourceUVWrap;
    registerVoxelVariant(world, SignalSourceID, signalSourceVariant);

    registerVoxelType(
      world,
      "Signal Source",
      SignalSourceID,
      EXTENSION_NAMESPACE,
      SignalSourceID,
      IWorld(world).extension_SignalSourceVoxe_signalSourceVariantSelector.selector
    );
  }

  function addProperties(bytes32 entity, bytes16 callerNamespace) public override {
    if (!entityIsSignalSource(entity, callerNamespace)) {
      bool isNaturalSignalSource = true;
      bool hasValue = true;
      SignalSource.set(callerNamespace, entity, isNaturalSignalSource, hasValue);
    }
  }

  function removeProperties(bytes32 entity, bytes16 callerNamespace) public override {
    if (entityIsSignalSource(entity, callerNamespace)) {
      SignalSource.deleteRecord(callerNamespace, entity);
    }
  }

  function signalSourceVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    super.updateProperties(entity);
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SignalSourceID });
  }
}
