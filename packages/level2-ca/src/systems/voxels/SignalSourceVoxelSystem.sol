// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig, SignalSource } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, SignalSourceVoxelID, Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant SignalSourceVoxelVariantID = bytes32(keccak256("signalsource"));

string constant SignalSourceTexture = "bafkreifciafvv63x3nnnsdvsccp45ggcx5xczfhoaz3xy3y5k666ma2m4y";
string constant SignalSourceUVWrap = "bafkreibyxohq35sq2fqujxffs5nfjdtfx5cmnqhnyliar2xbkqxgcd7d5u";

contract SignalSourceVoxelSystem is System {
  function registerVoxelSignalSource() public {
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

    bytes32[] memory signalChildVoxelTypes = VoxelTypeRegistry.getChildVoxelTypeIds(IStore(REGISTRY_ADDRESS), Level2AirVoxelID);
    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Signal Source",
      SignalSourceVoxelID,
      baseVoxelTypeId,
      signalChildVoxelTypes,
      signalChildVoxelTypes,
      SignalSourceVoxelVariantID
    );

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      SignalSourceVoxelID,
      IWorld(world).enterWorldSignalSource.selector,
      IWorld(world).exitWorldSignalSource.selector,
      IWorld(world).variantSelectorSignalSource.selector,
      IWorld(world).activateSelectorSignalSource.selector,
      IWorld(world).eventHandlerSignalSource.selector
    );
  }

  function enterWorldSignalSource(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    bool isNaturalSignalSource = true;
    bool hasValue = true;
    SignalSource.set(callerAddress, entity, isNaturalSignalSource, hasValue);
  }

  function exitWorldSignalSource(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    SignalSource.deleteRecord(callerAddress, entity);
  }

  function variantSelectorSignalSource(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    return SignalSourceVoxelVariantID;
  }

  function activateSelectorSignalSource(address callerAddress, bytes32 entity) public view returns (string memory) {}

  function eventHandlerSignalSource(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {}
}
