// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenetxyz/contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Signal, SignalData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { registerVoxelVariant, registerVoxelType, entityIsSignal } from "../../Utils.sol";
import { VoxelVariantsData, VoxelVariantsKey } from "../../Types.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";

bytes32 constant SignalID = bytes32(keccak256("signal"));

bytes32 constant SignalOffID = bytes32(keccak256("signal.off"));
bytes32 constant SignalOnID = bytes32(keccak256("signal.on"));

string constant SignalOffTexture = "bafkreihofjdel3lyz2vbqq6txdujbjvg2mqsaeczxeb7gszj2ltmhpinui";
string constant SignalOnTexture = "bafkreihitx2k2hpnqnxmdpc5qgsuexeqkvshlezzfwzdh7u3av6x3ar7qy";

string constant SignalOffUVWrap = "bafkreifdtu65gok35bevprpupxucirs2tan2k77444sl67stdhdgzwffra";
string constant SignalOnUVWrap = "bafkreib3vwppyquoziyisfjz3eodmtg6nneenkp2ejy7e3itycdfamm2ye";

contract SignalVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory signalOffVariant;
    signalOffVariant.blockType = NoaBlockType.BLOCK;
    signalOffVariant.opaque = true;
    signalOffVariant.solid = true;
    string[] memory signalOffMaterials = new string[](1);
    signalOffMaterials[0] = SignalOffTexture;
    signalOffVariant.materials = abi.encode(signalOffMaterials);
    signalOffVariant.uvWrap = SignalOffUVWrap;
    registerVoxelVariant(world, SignalOffID, signalOffVariant);

    VoxelVariantsData memory signalOnVariant;
    signalOnVariant.blockType = NoaBlockType.BLOCK;
    signalOnVariant.opaque = true;
    signalOnVariant.solid = true;
    string[] memory signalOnMaterials = new string[](1);
    signalOnMaterials[0] = SignalOnTexture;
    signalOnVariant.materials = abi.encode(signalOnMaterials);
    signalOnVariant.uvWrap = SignalOnUVWrap;
    registerVoxelVariant(world, SignalOnID, signalOnVariant);

    registerVoxelType(
      world,
      "Signal",
      SignalID,
      SignalOffTexture,
      SignalOffUVWrap,
      IWorld(world).extension_SignalVoxelSyste_signalVariantSelector.selector
    );
  }

  function addProperties(bytes32 entity, bytes16 callerNamespace) public override {
    if (!entityIsSignal(entity, callerNamespace)) {
      Signal.set(
        callerNamespace,
        entity,
        SignalData({ isActive: false, direction: BlockDirection.None, hasValue: true })
      );
    }
  }

  function removeProperties(bytes32 entity, bytes16 callerNamespace) public override {
    if (entityIsSignal(entity, callerNamespace)) {
      Signal.deleteRecord(callerNamespace, entity);
    }
  }

  function signalVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    (, bytes16 callerNamespace) = super.setupVoxel(entity);
    SignalData memory signalData = Signal.get(callerNamespace, entity);
    if (signalData.isActive) {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SignalOnID });
    } else {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SignalOffID });
    }
  }
}
