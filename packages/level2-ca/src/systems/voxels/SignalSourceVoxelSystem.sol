// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig, SignalSource } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, SignalSourceVoxelID, SignalSourceVoxelVariantID, SignalSourceTexture, SignalSourceUVWrap } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

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

    bytes32[] memory signalChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      signalChildVoxelTypes[i] = AirVoxelID;
    }
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Signal",
      SignalSourceVoxelID,
      signalChildVoxelTypes,
      SignalSourceVoxelVariantID
    );

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      SignalSourceVoxelID,
      IWorld(world).enterWorldSignalSource.selector,
      IWorld(world).exitWorldSignalSource.selector,
      IWorld(world).variantSelectorSignalSource.selector
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

  function variantSelectorSignalSource(address callerAddress, bytes32 entity) public view returns (bytes32) {
    return SignalSourceVoxelVariantID;
  }
}
