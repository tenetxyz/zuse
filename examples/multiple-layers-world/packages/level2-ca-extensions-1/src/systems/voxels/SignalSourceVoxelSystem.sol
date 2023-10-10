// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { SignalSource } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, SignalSourceVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection, ComponentDef } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant SignalSourceVoxelVariantID = bytes32(keccak256("signalsource"));

string constant SignalSourceTexture = "bafkreifciafvv63x3nnnsdvsccp45ggcx5xczfhoaz3xy3y5k666ma2m4y";
string constant SignalSourceUVWrap = "bafkreibyxohq35sq2fqujxffs5nfjdtfx5cmnqhnyliar2xbkqxgcd7d5u";

contract SignalSourceVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();

    VoxelVariantsRegistryData memory signalSourceVariant;
    signalSourceVariant.blockType = NoaBlockType.BLOCK;
    signalSourceVariant.opaque = true;
    signalSourceVariant.solid = true;
    string[] memory signalSourceMaterials = new string[](1);
    signalSourceMaterials[0] = SignalSourceTexture;
    signalSourceVariant.materials = abi.encode(signalSourceMaterials);
    signalSourceVariant.uvWrap = SignalSourceUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, SignalSourceVoxelVariantID, signalSourceVariant);

    bytes32[] memory signalChildVoxelTypes = VoxelTypeRegistry.getChildVoxelTypeIds(
      IStore(REGISTRY_ADDRESS),
      Level2AirVoxelID
    );
    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Signal Source",
      SignalSourceVoxelID,
      baseVoxelTypeId,
      signalChildVoxelTypes,
      signalChildVoxelTypes,
      SignalSourceVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).extension1_SignalSourceVoxe_enterWorld.selector,
        IWorld(world).extension1_SignalSourceVoxe_exitWorld.selector,
        IWorld(world).extension1_SignalSourceVoxe_variantSelector.selector,
        IWorld(world).extension1_SignalSourceVoxe_activate.selector,
        IWorld(world).extension1_SignalSourceVoxe_eventHandler.selector,
        IWorld(world).extension1_SignalSourceVoxe_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, SignalSourceVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    bool isNaturalSignalSource = true;
    bool hasValue = true;
    SignalSource.set(callerAddress, entity, isNaturalSignalSource, hasValue);
  }

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    SignalSource.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SignalSourceVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bool, bytes memory) {}

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, bytes memory) {}
}
