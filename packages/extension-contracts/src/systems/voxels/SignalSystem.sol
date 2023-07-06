// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Signal, SignalData, InvertedSignalData, InvertedSignal, SignalTableId, SignalSource, SignalSourceTableId } from "../../codegen/Tables.sol";

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { PositionData } from "@tenetxyz/contracts/src/codegen/tables/Position.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { registerExtension, registerVoxelVariant, registerVoxelType, calculateBlockDirection, getOppositeDirection, getEntityPositionStrict, entityIsSignal, entityIsSignalSource, entityIsInvertedSignal } from "../../Utils.sol";
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

contract SignalSystem is System {
  function registerSignalVoxel() public {
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
      IWorld(world).extension_SignalSystem_signalVariantSelector.selector
    );

    registerExtension(world, "SignalSystem", IWorld(world).extension_SignalSystem_eventHandler.selector);
  }

  function signalVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    SignalData memory signalData = getOrCreateSignal(entity);
    if (signalData.isActive) {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SignalOnID });
    } else {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SignalOffID });
    }
  }

  function getOrCreateSignal(bytes32 entity) public returns (SignalData memory) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    if (!entityIsSignal(entity, callerNamespace)) {
      Signal.set(
        callerNamespace,
        entity,
        SignalData({ isActive: false, direction: BlockDirection.None, hasValue: true })
      );
    }

    return Signal.get(callerNamespace, entity);
  }

  function updateSignal(
    bytes16 callerNamespace,
    bytes32 signalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) private returns (bool changedEntity) {
    SignalData memory signalData = Signal.get(callerNamespace, signalEntity);
    changedEntity = false;

    bool compareIsSignalSource = entityIsSignalSource(compareEntity, callerNamespace);
    bool compareIsActiveSignal = entityIsSignal(compareEntity, callerNamespace);
    if (compareIsActiveSignal) {
      SignalData memory compareSignalData = Signal.get(callerNamespace, compareEntity);
      compareIsActiveSignal =
        compareSignalData.isActive &&
        compareSignalData.direction != getOppositeDirection(compareBlockDirection);
    }
    bool compareIsActiveInvertedSignal = entityIsInvertedSignal(compareEntity, callerNamespace);
    if (compareIsActiveInvertedSignal) {
      InvertedSignalData memory compareInvertedSignalData = InvertedSignal.get(callerNamespace, compareEntity);
      compareIsActiveInvertedSignal = compareInvertedSignalData.isActive;
    }

    if (signalData.isActive) {
      // if we're active and the source direction is the same as the compare block direction
      // and if the compare entity is not active, we should become inactive
      if (signalData.direction == compareBlockDirection) {
        if (!compareIsSignalSource && !compareIsActiveSignal && !compareIsActiveInvertedSignal) {
          signalData.isActive = false;
          signalData.direction = BlockDirection.None;
          Signal.set(callerNamespace, signalEntity, signalData);
          changedEntity = true;
        }
      }
    } else {
      // if we're not active, and the compare entity is active, we should become active
      // compare entity could be a signal source, or it could be an active signal
      if (compareIsSignalSource || compareIsActiveSignal || compareIsActiveInvertedSignal) {
        signalData.isActive = true;
        signalData.direction = compareBlockDirection;
        Signal.set(callerNamespace, signalEntity, signalData);
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
    if (entityIsSignal(centerEntityId, callerNamespace)) {
      for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
        bytes32 neighbourEntityId = neighbourEntityIds[i];
        if (uint256(neighbourEntityId) == 0) {
          continue;
        }

        BlockDirection centerBlockDirection = calculateBlockDirection(
          getEntityPositionStrict(neighbourEntityId),
          centerPosition
        );
        updateSignal(callerNamespace, centerEntityId, neighbourEntityId, centerBlockDirection);
      }
    }

    // case two: neighbour is signal, check center to see if things need to change
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];

      if (uint256(neighbourEntityId) == 0 || !entityIsSignal(neighbourEntityId, callerNamespace)) {
        changedEntityIds[i] = 0;
        continue;
      }

      BlockDirection centerBlockDirection = calculateBlockDirection(
        centerPosition,
        getEntityPositionStrict(neighbourEntityId)
      );

      bool changedEntity = updateSignal(callerNamespace, neighbourEntityId, centerEntityId, centerBlockDirection);

      if (changedEntity) {
        changedEntityIds[i] = neighbourEntityId;
      } else {
        changedEntityIds[i] = 0;
      }
    }

    return changedEntityIds;
  }
}
