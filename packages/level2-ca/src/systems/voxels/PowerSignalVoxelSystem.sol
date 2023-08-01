// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig, PowerSignal, PowerSignalData, PowerWire, PowerWireData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, PowerSignalVoxelID, PowerWireVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant PowerSignalOffVoxelVariantID = bytes32(keccak256("powersignal.off"));
bytes32 constant PowerSignalOnVoxelVariantID = bytes32(keccak256("powersignal.on"));
bytes32 constant PowerSignalBrokenVoxelVariantID = bytes32(keccak256("powersignal.broken"));

string constant PowerSignalOnTexture = "bafkreie2phfl3w4dodcaiizezn3akmg4xwq3xjvdemanjz57flvoitkwhe";
string constant PowerSignalOffTexture = "bafkreickzqimtlmzkjogvewi4e7wwtsg6dgmmylb2gr6av6yh36ommfbd4";
string constant PowerSignalBrokenTexture = "bafkreigppq2ona2xam2iflprmbalqh2wg7xts2awsec4hdkdv7t4l5brom";

contract PowerSignalVoxelSystem is System {
  function registerVoxelPowerSignal() public {
    address world = _world();

    VoxelVariantsRegistryData memory powerSignalOffVariant;
    powerSignalOffVariant.blockType = NoaBlockType.MESH;
    powerSignalOffVariant.opaque = false;
    powerSignalOffVariant.solid = false;
    powerSignalOffVariant.frames = 1;
    string[] memory powerSignalOffMaterials = new string[](1);
    powerSignalOffMaterials[0] = PowerSignalOffTexture;
    powerSignalOffVariant.materials = abi.encode(powerSignalOffMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, PowerSignalOffVoxelVariantID, powerSignalOffVariant);

    VoxelVariantsRegistryData memory powerSignalOnVariant;
    powerSignalOnVariant.blockType = NoaBlockType.MESH;
    powerSignalOnVariant.opaque = false;
    powerSignalOnVariant.solid = false;
    powerSignalOnVariant.frames = 1;
    string[] memory powerSignalOnMaterials = new string[](1);
    powerSignalOnMaterials[0] = PowerSignalOnTexture;
    powerSignalOnVariant.materials = abi.encode(powerSignalOnMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, PowerSignalOnVoxelVariantID, powerSignalOnVariant);

    VoxelVariantsRegistryData memory powerSignalBrokenVariant;
    powerSignalBrokenVariant.blockType = NoaBlockType.MESH;
    powerSignalBrokenVariant.opaque = false;
    powerSignalBrokenVariant.solid = false;
    powerSignalBrokenVariant.frames = 1;
    string[] memory powerSignalBrokenMaterials = new string[](1);
    powerSignalBrokenMaterials[0] = PowerSignalBrokenTexture;
    powerSignalBrokenVariant.materials = abi.encode(powerSignalBrokenMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, PowerSignalBrokenVoxelVariantID, powerSignalBrokenVariant);

    bytes32[] memory powerSignalChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      powerSignalChildVoxelTypes[i] = AirVoxelID;
    }
    bytes32 baseVoxelTypeId = PowerWireVoxelID;
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Power Signal",
      PowerSignalVoxelID,
      baseVoxelTypeId,
      powerSignalChildVoxelTypes,
      powerSignalChildVoxelTypes,
      PowerSignalOffVoxelVariantID
    );

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      PowerSignalVoxelID,
      IWorld(world).enterWorldPowerSignal.selector,
      IWorld(world).exitWorldPowerSignal.selector,
      IWorld(world).variantSelectorPowerSignal.selector,
      IWorld(world).activateSelectorPowerSignal.selector,
      IWorld(world).eventHandlerPowerSignal.selector
    );
  }

  function enterWorldPowerSignal(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    PowerSignal.set(
      callerAddress,
      entity,
      PowerSignalData({ isActive: false, direction: BlockDirection.None, hasValue: true })
    );
  }

  function exitWorldPowerSignal(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    PowerSignal.deleteRecord(callerAddress, entity);
  }

  function variantSelectorPowerSignal(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
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

  function activateSelectorPowerSignal(address callerAddress, bytes32 entity) public view returns (string memory) {}
}
