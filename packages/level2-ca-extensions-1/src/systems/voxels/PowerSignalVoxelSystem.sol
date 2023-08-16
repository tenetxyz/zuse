// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { BodyTypeRegistry } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { BodyVariantsRegistryData } from "@tenet-registry/src/codegen/tables/BodyVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerBodyVariant, registerBodyType, bodySelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { PowerSignal, PowerSignalData, PowerWire, PowerWireData } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, PowerSignalVoxelID, PowerWireVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { registerCABodyType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant PowerSignalOffVoxelVariantID = bytes32(keccak256("powersignal.off"));
bytes32 constant PowerSignalOnVoxelVariantID = bytes32(keccak256("powersignal.on"));
bytes32 constant PowerSignalBrokenVoxelVariantID = bytes32(keccak256("powersignal.broken"));

string constant PowerSignalOnTexture = "bafkreie2phfl3w4dodcaiizezn3akmg4xwq3xjvdemanjz57flvoitkwhe";
string constant PowerSignalOffTexture = "bafkreickzqimtlmzkjogvewi4e7wwtsg6dgmmylb2gr6av6yh36ommfbd4";
string constant PowerSignalBrokenTexture = "bafkreigppq2ona2xam2iflprmbalqh2wg7xts2awsec4hdkdv7t4l5brom";

contract PowerSignalVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    BodyVariantsRegistryData memory powerSignalOffVariant;
    powerSignalOffVariant.blockType = NoaBlockType.MESH;
    powerSignalOffVariant.opaque = false;
    powerSignalOffVariant.solid = false;
    powerSignalOffVariant.frames = 1;
    string[] memory powerSignalOffMaterials = new string[](1);
    powerSignalOffMaterials[0] = PowerSignalOffTexture;
    powerSignalOffVariant.materials = abi.encode(powerSignalOffMaterials);
    registerBodyVariant(REGISTRY_ADDRESS, PowerSignalOffVoxelVariantID, powerSignalOffVariant);

    BodyVariantsRegistryData memory powerSignalOnVariant;
    powerSignalOnVariant.blockType = NoaBlockType.MESH;
    powerSignalOnVariant.opaque = false;
    powerSignalOnVariant.solid = false;
    powerSignalOnVariant.frames = 1;
    string[] memory powerSignalOnMaterials = new string[](1);
    powerSignalOnMaterials[0] = PowerSignalOnTexture;
    powerSignalOnVariant.materials = abi.encode(powerSignalOnMaterials);
    registerBodyVariant(REGISTRY_ADDRESS, PowerSignalOnVoxelVariantID, powerSignalOnVariant);

    BodyVariantsRegistryData memory powerSignalBrokenVariant;
    powerSignalBrokenVariant.blockType = NoaBlockType.MESH;
    powerSignalBrokenVariant.opaque = false;
    powerSignalBrokenVariant.solid = false;
    powerSignalBrokenVariant.frames = 1;
    string[] memory powerSignalBrokenMaterials = new string[](1);
    powerSignalBrokenMaterials[0] = PowerSignalBrokenTexture;
    powerSignalBrokenVariant.materials = abi.encode(powerSignalBrokenMaterials);
    registerBodyVariant(REGISTRY_ADDRESS, PowerSignalBrokenVoxelVariantID, powerSignalBrokenVariant);

    bytes32[] memory powerSignalChildBodyTypes = BodyTypeRegistry.getChildBodyTypeIds(
      IStore(REGISTRY_ADDRESS),
      PowerWireVoxelID
    );

    registerBodyType(
      REGISTRY_ADDRESS,
      "Power Signal",
      PowerSignalVoxelID,
      PowerWireVoxelID,
      powerSignalChildBodyTypes,
      powerSignalChildBodyTypes,
      PowerSignalOffVoxelVariantID,
      bodySelectorsForVoxel(
        IWorld(world).extension1_PowerSignalVoxel_enterWorld.selector,
        IWorld(world).extension1_PowerSignalVoxel_exitWorld.selector,
        IWorld(world).extension1_PowerSignalVoxel_variantSelector.selector,
        IWorld(world).extension1_PowerSignalVoxel_activate.selector,
        IWorld(world).extension1_PowerSignalVoxel_eventHandler.selector
      )
    );

    registerCABodyType(CA_ADDRESS, PowerSignalVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    PowerSignal.set(
      callerAddress,
      entity,
      PowerSignalData({ isActive: false, direction: BlockDirection.None, hasValue: true })
    );
  }

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    PowerSignal.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    address callerAddress = super.getCallerAddress();
    PowerWireData memory powerWireData = PowerWire.get(callerAddress, entity);
    PowerSignalData memory powerSignalData = PowerSignal.get(callerAddress, entity);
    if (powerWireData.isBroken) {
      return PowerSignalBrokenVoxelVariantID;
    } else {
      if (powerSignalData.isActive) {
        return PowerSignalOnVoxelVariantID;
      } else {
        return PowerSignalOffVoxelVariantID;
      }
    }
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).extension1_PowerSignalSyste_eventHandlerPowerSignal(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }
}
