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
import { registerExtension, registerVoxelType, registerVoxelVariant, calculateBlockDirection, getOppositeDirection, getEntityPositionStrict, entityIsSignal, entityIsSignalSource, entityIsInvertedSignal } from "../../Utils.sol";
import { VoxelVariantsData, VoxelVariantsKey } from "../../Types.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";

bytes32 constant SignalSourceID = bytes32(keccak256("signalsource"));

string constant SignalSourceTexture = "bafkreifciafvv63x3nnnsdvsccp45ggcx5xczfhoaz3xy3y5k666ma2m4y";

string constant SignalSourceUVWrap = "bafkreibyxohq35sq2fqujxffs5nfjdtfx5cmnqhnyliar2xbkqxgcd7d5u";

contract SignalSourceSystem is System {
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
      IWorld(world).extension_SignalSourceSyst_signalSourceVariantSelector.selector
    );

    registerExtension(world, "SignalSourceSystem", IWorld(world).extension_SignalSourceSyst_eventHandler.selector);
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

  function updateSignalSource(
    bytes16 callerNamespace,
    bytes32 signalSourceEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) private returns (bool changedEntity) {
    changedEntity = false;

    bool isSignalSource = entityIsSignalSource(signalSourceEntity, callerNamespace);
    bool isSignal = entityIsSignal(compareEntity, callerNamespace);
    bool isInvertedSignal = entityIsInvertedSignal(compareEntity, callerNamespace);
    if (isSignal || isInvertedSignal) return changedEntity; // these two cannot be a signal source
    bool isNaturalSignalSource = SignalSource.get(callerNamespace, signalSourceEntity).isNatural;

    bool compareIsActiveInvertedSignal = entityIsInvertedSignal(compareEntity, callerNamespace);
    if (compareIsActiveInvertedSignal) {
      InvertedSignalData memory compareInvertedSignalData = InvertedSignal.get(callerNamespace, compareEntity);
      compareIsActiveInvertedSignal =
        compareInvertedSignalData.isActive &&
        compareInvertedSignalData.direction == BlockDirection.Down;
    }

    if (isSignalSource) {
      // Check if the signal source is still valid
      if (!isNaturalSignalSource && compareBlockDirection == BlockDirection.Down && !compareIsActiveInvertedSignal) {
        SignalSource.deleteRecord(callerNamespace, signalSourceEntity);
        changedEntity = true;
      }
    } else {
      // if a voxel is not a signal source and above a inverted active signal
      // then it should be a signal source
      if (compareIsActiveInvertedSignal) {
        bool isNatural = false;
        bool hasValue = true;
        SignalSource.set(callerNamespace, signalSourceEntity, isNatural, hasValue);
        changedEntity = true;
      }
    }

    return changedEntity;
  }

  // TODO: The logic in this function will be the same for all eventHandlers, so we should somehow generalize this for all of them
  // through a library or something
  function eventHandler(bytes32 centerEntityId, bytes32[] memory neighbourEntityIds) public returns (bytes32[] memory) {
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    // TODO: require not root namespace

    PositionData memory centerPosition = getEntityPositionStrict(centerEntityId);

    // case one: center is signal, check neighbours to see if things need to change
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];
      if (uint256(neighbourEntityId) == 0) {
        continue;
      }

      BlockDirection centerBlockDirection = calculateBlockDirection(
        getEntityPositionStrict(neighbourEntityId),
        centerPosition
      );
      updateSignalSource(callerNamespace, centerEntityId, neighbourEntityId, centerBlockDirection);
    }

    // case two: neighbour is signal, check center to see if things need to change
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];

      if (uint256(neighbourEntityId) == 0) {
        changedEntityIds[i] = 0;
        continue;
      }

      BlockDirection centerBlockDirection = calculateBlockDirection(
        centerPosition,
        getEntityPositionStrict(neighbourEntityId)
      );

      bool changedEntity = updateSignalSource(callerNamespace, neighbourEntityId, centerEntityId, centerBlockDirection);

      if (changedEntity) {
        changedEntityIds[i] = neighbourEntityId;
      } else {
        changedEntityIds[i] = 0;
      }
    }

    return changedEntityIds;
  }
}
