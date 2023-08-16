// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { BodyTypeRegistry } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { BodyVariantsRegistryData } from "@tenet-registry/src/codegen/tables/BodyVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerBodyVariant, registerBodyType, bodySelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { InvertedSignal, InvertedSignalData } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, InvertedSignalVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { SignalOnVoxelVariantID, SignalOffVoxelVariantID } from "@tenet-level2-ca-extensions-1/src/systems/voxels/SignalVoxelSystem.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { registerCABodyType } from "@tenet-base-ca/src/CallUtils.sol";

contract InvertedSignalVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    bytes32[] memory invertedSignalChildBodyTypes = BodyTypeRegistry.getChildBodyTypeIds(
      IStore(REGISTRY_ADDRESS),
      Level2AirVoxelID
    );
    bytes32 baseBodyTypeId = Level2AirVoxelID;
    registerBodyType(
      REGISTRY_ADDRESS,
      "Inverted Signal",
      InvertedSignalVoxelID,
      baseBodyTypeId,
      invertedSignalChildBodyTypes,
      invertedSignalChildBodyTypes,
      SignalOnVoxelVariantID,
      bodySelectorsForVoxel(
        IWorld(world).extension1_InvertedSignalVo_enterWorld.selector,
        IWorld(world).extension1_InvertedSignalVo_exitWorld.selector,
        IWorld(world).extension1_InvertedSignalVo_variantSelector.selector,
        IWorld(world).extension1_InvertedSignalVo_activate.selector,
        IWorld(world).extension1_InvertedSignalVo_eventHandler.selector
      )
    );

    registerCABodyType(CA_ADDRESS, InvertedSignalVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    InvertedSignal.set(
      callerAddress,
      entity,
      InvertedSignalData({ isActive: true, direction: BlockDirection.None, hasValue: true })
    );
  }

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    InvertedSignal.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    address callerAddress = super.getCallerAddress();
    InvertedSignalData memory invertedSignalData = InvertedSignal.get(callerAddress, entity);
    if (invertedSignalData.isActive) {
      return SignalOnVoxelVariantID;
    } else {
      return SignalOffVoxelVariantID;
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
      IWorld(_world()).extension1_InvertedSignalSy_eventHandlerInvertedSignal(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }
}
