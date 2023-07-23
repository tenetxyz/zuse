// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenet-contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerSignal, PowerSignalData, PowerWire, PowerWireData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { getCallerNamespace } from "@tenet-contracts/src/Utils.sol";
import { registerVoxelType, registerVoxelVariant, entityIsGenerator } from "../../Utils.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { VoxelVariantsData } from "@tenet-contracts/src/codegen/tables/VoxelVariants.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";

bytes32 constant PowerSignalID = bytes32(keccak256("powersignal"));

bytes32 constant PowerSignalOffID = bytes32(keccak256("powersignal.off"));
bytes32 constant PowerSignalOnID = bytes32(keccak256("powersignal.on"));
bytes32 constant PowerSignalBrokenID = bytes32(keccak256("powersignal.broken"));

string constant PowerSignalOnTexture = "bafkreie2phfl3w4dodcaiizezn3akmg4xwq3xjvdemanjz57flvoitkwhe";
string constant PowerSignalOffTexture = "bafkreickzqimtlmzkjogvewi4e7wwtsg6dgmmylb2gr6av6yh36ommfbd4";
string constant PowerSignalBrokenTexture = "bafkreigppq2ona2xam2iflprmbalqh2wg7xts2awsec4hdkdv7t4l5brom";

contract PowerSignalVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory powerSignalOffVariant;
    powerSignalOffVariant.blockType = NoaBlockType.MESH;
    powerSignalOffVariant.opaque = false;
    powerSignalOffVariant.solid = false;
    powerSignalOffVariant.frames = 1;
    string[] memory powerSignalOffMaterials = new string[](1);
    powerSignalOffMaterials[0] = PowerSignalOffTexture;
    powerSignalOffVariant.materials = abi.encode(powerSignalOffMaterials);
    registerVoxelVariant(world, PowerSignalOffID, powerSignalOffVariant);

    VoxelVariantsData memory powerSignalOnVariant;
    powerSignalOnVariant.blockType = NoaBlockType.MESH;
    powerSignalOnVariant.opaque = false;
    powerSignalOnVariant.solid = false;
    powerSignalOnVariant.frames = 1;
    string[] memory powerSignalOnMaterials = new string[](1);
    powerSignalOnMaterials[0] = PowerSignalOnTexture;
    powerSignalOnVariant.materials = abi.encode(powerSignalOnMaterials);
    registerVoxelVariant(world, PowerSignalOnID, powerSignalOnVariant);

    VoxelVariantsData memory powerSignalBrokenVariant;
    powerSignalBrokenVariant.blockType = NoaBlockType.MESH;
    powerSignalBrokenVariant.opaque = false;
    powerSignalBrokenVariant.solid = false;
    powerSignalBrokenVariant.frames = 1;
    string[] memory powerSignalBrokenMaterials = new string[](1);
    powerSignalBrokenMaterials[0] = PowerSignalBrokenTexture;
    powerSignalBrokenVariant.materials = abi.encode(powerSignalBrokenMaterials);
    registerVoxelVariant(world, PowerSignalBrokenID, powerSignalBrokenVariant);

    registerVoxelType(
      world,
      "Power Signal",
      PowerSignalID,
      EXTENSION_NAMESPACE,
      PowerSignalOffID,
      IWorld(world).extension_PowerSignalVoxel_variantSelector.selector,
      IWorld(world).extension_PowerSignalVoxel_enterWorld.selector,
      IWorld(world).extension_PowerSignalVoxel_exitWorld.selector,
      IWorld(world).extension_PowerSignalVoxel_activate.selector
    );
  }

  function enterWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    PowerSignal.set(
      callerNamespace,
      entity,
      PowerSignalData({ isActive: false, direction: BlockDirection.None, hasValue: true })
    );

    bytes32 _source = bytes32(0);
    bytes32 _destination = bytes32(0);

    PowerWire.set(
      callerNamespace,
      entity,
      PowerWireData({
        source: _source,
        destination: _destination,
        transferRate: 0,
        maxTransferRate: 45900,
        lastUpdateBlock: block.number,
        sourceDirection: BlockDirection.None,
        destinationDirection: BlockDirection.None,
        isBroken: false,
        hasValue: true
      })
    );
  }

  function exitWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    PowerSignal.deleteRecord(callerNamespace, entity);
    PowerWire.deleteRecord(callerNamespace, entity);
  }

  function variantSelector(bytes32 entity) public view override returns (VoxelVariantsKey memory) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    PowerWireData memory powerWireData = PowerWire.get(callerNamespace, entity);
    PowerSignalData memory powerSignalData = PowerSignal.get(callerNamespace, entity);
    if (powerWireData.isBroken) {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: PowerSignalBrokenID });
    } else {
      if (powerSignalData.isActive) {
        return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: PowerSignalOnID });
      } else {
        return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: PowerSignalOffID });
      }
    }
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
