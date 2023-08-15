// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { WorldConfig, Position, PositionTableId, VoxelTypeTableId, VoxelTypeData, TruthTable, TruthTableData, TruthTableCR, TruthTableCRData, Spawn } from "@tenet-contracts/src/codegen/Tables.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { LEVEL_2_CA_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { getVoxelCoordStrict } from "@tenet-contracts/src/Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { SignalSourceVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
// import { entityIsActiveSignal, isEntityIsInactiveSignal } from "@tenet-level2-ca/src/InteractionUtils.sol";
import { VoxelType } from "@tenet-contracts/src/codegen/tables/voxelType.sol";
import { InterfaceVoxel } from "@tenet-utils/src/Types.sol";
import { voxelCoordToString } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { Signal, SignalData } from "@tenet-level2-ca-extensions-1/src/codegen/tables/Signal.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

contract TruthTableClassifySystem is System {
  function registerTruthTable(
    string memory name,
    string memory description,
    uint256[] memory inputRows,
    uint256[] memory outputRows,
    uint16 numInputBits,
    uint16 numOutputBits
  ) public {
    // each index in this uint256 array is a row in the input of the truth table
    // each bit is whether that input is on/off
    require(
      inputRows.length == outputRows.length,
      "ClassifyBooleanLogicSystem: inputRows and outputRows must have the same length"
    );

    bytes32 booleanClassifierId = getUniqueEntity();
    TruthTable.set(
      booleanClassifierId,
      TruthTableData({
        name: name,
        description: description,
        creator: _msgSender(),
        inputRows: inputRows,
        outputRows: outputRows,
        numInputBits: numInputBits,
        numOutputBits: numOutputBits
      })
    );
  }

  // VoxelEntity
  function classifyIfCreationSatisfiesTruthTable(
    bytes32 booleanClassifierId,
    bytes32 spawnId,
    InterfaceVoxel[] memory inInterfaces,
    InterfaceVoxel[] memory outInterfaces
  ) public {
    // TODO: do validation that is like in ClassifyCreationSystem
    // right now, I didn't do it because for the demo, we don't expect users to add their own classifiers
    // the important thing is that we need to verify that all in/out entities are in the spawn

    VoxelCoord[] memory inCoords = new VoxelCoord[](inInterfaces.length);
    for (uint i = 0; i < inCoords.length; i++) {
      inCoords[i] = getVoxelCoordStrict(2, inInterfaces[i].entity.entityId);
    }

    bytes32[] memory outEntities = new bytes32[](outInterfaces.length);
    for (uint i = 0; i < outInterfaces.length; i++) {
      outEntities[i] = outInterfaces[i].entity.entityId;
    }

    // These are the signal source voxels we'll use for each input.
    // if the ith input is a '1', we will place the ith signal source on that input coord
    bytes32[] memory inSignalSources = new bytes32[](inCoords.length);
    for (uint i = 0; i < inCoords.length; i++) {
      inSignalSources[i] = giftVoxel(SignalSourceVoxelID);
    }

    TruthTableData memory tableData = TruthTable.get(booleanClassifierId);
    // ensure that each row in the truth table holds true
    for (uint i = 0; i < tableData.inputRows.length; i++) {
      uint256 inStates = tableData.inputRows[i];
      uint256 outStates = tableData.outputRows[i];
      requireTableRowHolds(inStates, outStates, inCoords, outEntities, inSignalSources);
    }

    bytes32 creationId = Spawn.getCreationId(spawnId);
    TruthTableCR.set(
      booleanClassifierId,
      creationId,
      TruthTableCRData({
        blockNumber: block.number,
        inInterfaces: abi.encode(inInterfaces), // so we know what the input/outputs are
        outInterfaces: abi.encode(outInterfaces) // so we know what the input/outputs are
      })
    );
  }

  function requireTableRowHolds(
    uint256 inStates,
    uint256 outStates,
    VoxelCoord[] memory inCoords,
    bytes32[] memory outEntities,
    bytes32[] memory inSignalSources
  ) private {
    clearCoords(inCoords);

    // place the power blocks for the inputs
    for (uint i = 0; i < inCoords.length; i++) {
      bool ithInterfaceIsTrue = inStates & (1 << i) != 0;
      if (ithInterfaceIsTrue) {
        VoxelCoord memory inCoord = inCoords[i];
        build(inCoord, inSignalSources[i]);
      }
    }

    // No need to run the simulation logic since the build function automatically runs the simulation logic
    for (uint i = 0; i < outEntities.length; i++) {
      bool ithInterfaceIsTrue = outStates & (1 << i) != 0;
      if (ithInterfaceIsTrue) {
        require(
          isEntityActiveSignal(outEntities[i]),
          string(
            abi.encode(
              "classify failed. out voxel must be active. inStates=",
              Strings.toString(inStates),
              " outStates=",
              Strings.toString(outStates)
            )
          )
        );
      } else {
        require(
          isEntityInactiveSignal(outEntities[i]),
          string(
            abi.encode(
              "classify failed. out voxel must be inactive. inStates=",
              Strings.toString(inStates),
              " outStates=",
              Strings.toString(outStates)
            )
          )
        );
      }
    }
  }

  function clearCoords(VoxelCoord[] memory coords) private {
    // mine the coord so we can place power sources at it
    for (uint256 i = 0; i < coords.length; i++) {
      IWorld(_world()).clearCoord(2, coords[i]); // clear at scale 2 since that is the scale of the signal source
    }
  }

  function build(VoxelCoord memory coord, bytes32 entity) private {
    IWorld(_world()).build(2, entity, coord, bytes4(0));
  }

  function giftVoxel(bytes32 baseVoxelType) private returns (bytes32) {
    return IWorld(_world()).giftVoxel(baseVoxelType);
  }

  function isEntityActiveSignal(bytes32 entity) private view returns (bool) {
    SignalData memory signalData = Signal.get(IStore(LEVEL_2_CA_ADDRESS), _world(), entity);
    return signalData.hasValue && signalData.isActive;
  }

  function isEntityInactiveSignal(bytes32 entity) private view returns (bool) {
    SignalData memory signalData = Signal.get(IStore(LEVEL_2_CA_ADDRESS), _world(), entity);
    return signalData.hasValue && !signalData.isActive;
  }
}
