// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { InvertedSignal, InvertedSignalData } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, InvertedSignalVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { SignalOnVoxelVariantID, SignalOffVoxelVariantID } from "@tenet-level2-ca-extensions-1/src/systems/voxels/SignalVoxelSystem.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";

contract InvertedSignalVoxelSystem is System {
  function registerVoxelInvertedSignal() public {
    address world = _world();

    bytes32[] memory invertedSignalChildVoxelTypes = VoxelTypeRegistry.getChildVoxelTypeIds(
      IStore(REGISTRY_ADDRESS),
      Level2AirVoxelID
    );
    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Inverted Signal",
      InvertedSignalVoxelID,
      baseVoxelTypeId,
      invertedSignalChildVoxelTypes,
      invertedSignalChildVoxelTypes,
      SignalOnVoxelVariantID
    );

    registerCAVoxelType(
      CA_ADDRESS,
      InvertedSignalVoxelID,
      IWorld(world).enterWorldInvertedSignal.selector,
      IWorld(world).exitWorldInvertedSignal.selector,
      IWorld(world).variantSelectorInvertedSignal.selector,
      IWorld(world).activateSelectorInvertedSignal.selector,
      IWorld(world).eventHandlerInvertedSignal.selector
    );
  }

  function enterWorldInvertedSignal(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    InvertedSignal.set(
      callerAddress,
      entity,
      InvertedSignalData({ isActive: true, direction: BlockDirection.None, hasValue: true })
    );
  }

  function exitWorldInvertedSignal(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    InvertedSignal.deleteRecord(callerAddress, entity);
  }

  function variantSelectorInvertedSignal(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    InvertedSignalData memory invertedSignalData = InvertedSignal.get(callerAddress, entity);
    if (invertedSignalData.isActive) {
      return SignalOnVoxelVariantID;
    } else {
      return SignalOffVoxelVariantID;
    }
  }

  function activateSelectorInvertedSignal(address callerAddress, bytes32 entity) public view returns (string memory) {}
}
