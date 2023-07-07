// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Signal, SignalData, SignalTableId, SignalSource, SignalSourceTableId, InvertedSignal, InvertedSignalData } from "../../codegen/Tables.sol";

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { PositionData } from "@tenetxyz/contracts/src/codegen/tables/Position.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { registerExtension, registerVoxelType, registerVoxelVariant, getOppositeDirection, entityIsSignal, entityIsSignalSource, entityIsInvertedSignal } from "../../Utils.sol";
import { VoxelVariantsData, VoxelVariantsKey } from "../../Types.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";

bytes32 constant SignalSourceID = bytes32(keccak256("signalsource"));

string constant SignalSourceTexture = "bafkreifciafvv63x3nnnsdvsccp45ggcx5xczfhoaz3xy3y5k666ma2m4y";

string constant SignalSourceUVWrap = "bafkreibyxohq35sq2fqujxffs5nfjdtfx5cmnqhnyliar2xbkqxgcd7d5u";

contract SignalSourceVoxelSystem is System {
  function registerSignalSourceVoxel() public {
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
      SignalSourceTexture,
      IWorld(world).extension_SignalSourceVoxe_signalSourceVariantSelector.selector
    );
  }

  function signalSourceVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    getOrCreateSignalSource(entity);
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SignalSourceID });
  }

  function getOrCreateSignalSource(bytes32 entity) public returns (bool) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    if (!entityIsSignalSource(entity, callerNamespace)) {
      bool isNatural = true;
      bool hasValue = true;
      SignalSource.set(callerNamespace, entity, isNatural, hasValue);
    }

    return SignalSource.get(callerNamespace, entity).isNatural;
  }
}
