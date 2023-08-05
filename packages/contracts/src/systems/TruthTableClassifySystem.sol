// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
//import { WorldConfig, Position, PositionTableId, VoxelType, VoxelTypeTableId, VoxelTypeData, TruthTable, TruthTableData } from "@tenet-contracts/src/codegen/Tables.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "@tenet-contracts/src/Types.sol";
//import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "../Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { entityIsActiveSignal, entityIsInactiveSignal } from "@tenet-level2-ca/src/InteractionUtils.sol";

// import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";

contract TruthTableClassifySystem is System {
  function registerTruthTable(
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
        inputRows: inputRows,
        outputRows: outputRows,
        numInputBits: numInputBits,
        numOutputBits: numOutputBits
      })
    );
  }

  // VoxelEntity
  function classify(bytes32 booleanClassifierId, bytes32 spawnId) public {
    TruthTableData memory booleanLogicClassifierData = BooleanLogicClassifier.get(booleanClassifierId);
  }

  function classifyRow(
    uint256 inStates,
    uint256 outStates,
    VoxelType[] memory inInterfaces,
    VoxelType[] memory outInterfaces
  ) private {
    clearCoords(inInterfaces);

    // place the power blocks for the inputs
    for (uint i = 0; i < inInterfaces.length; i++) {
      bool ithInterfaceIsTrue = inStates & (1 << i) != 0;
      if (ithInterfaceIsTrue) {
        build(_world(), in1Coord, inEntity1);
      }
    }

    // No need to run the simulation logic since the build function automatically runs the simulation logic
    for (uint i = 0; i < outInterfaces.length; i++) {
      bool ithInterfaceIsTrue = outStates & (1 << i) != 0;
      if (ithInterfaceIsTrue) {
        require(entityIsActiveSignal(out, _world()), "out voxel must be on");
      } else {
        require(entityIsInactiveSignal(out, _world()), "out voxel cannot be on");
      }
    }
  }

  function clearCoords(VoxelCoord[] memory coords) private {
    // mine the coord so we can place power sources at it
    for (uint256 i = 0; i < coords.length; i++) {
      clearCoord(coords[i]);
    }
  }

  function clearCoord(VoxelCoord memory coord) private returns (bytes32) {
    bytes memory returnData = IWorld(_world()).clearCoord(coord, _world());
    return abi.decode(returnData, (bytes32));
  }

  function build(VoxelCoord memory coord, bytes32 entity) private returns (bytes32) {
    bytes memory returnData = IWorld(_world()).build(abi.encodeWithSignature(BUILD_SIG, entity, coord), "build");
    return abi.decode(returnData, (bytes32));
  }
}
