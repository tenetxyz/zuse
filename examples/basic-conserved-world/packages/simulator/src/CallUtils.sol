// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord, VoxelEntity, SimTable, ValueType, ObjectType } from "@tenet-utils/src/Types.sol";
import { SIM_ON_BUILD_SIG, SIM_ON_MINE_SIG, SIM_ON_MOVE_SIG, SIM_ON_ACTIVATE_SIG, SIM_VELOCITY_CACHE_UPDATE_SIG, SIM_INIT_ENTITY_SIG } from "@tenet-simulator/src/Constants.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { SimSelectors, SimSelectorsData } from "@tenet-simulator/src/codegen/tables/SimSelectors.sol";

function updateVelocityCache(address simAddress, VoxelEntity memory entity) returns (bytes memory) {
  return
    safeCall(
      simAddress,
      abi.encodeWithSignature(SIM_VELOCITY_CACHE_UPDATE_SIG, entity),
      string(abi.encode("velocityChange ", entity))
    );
}

function initEntity(
  address simAddress,
  VoxelEntity memory entity,
  uint256 initMass,
  uint256 initEnergy,
  VoxelCoord memory initVelocity
) returns (bytes memory) {
  return
    safeCall(
      simAddress,
      abi.encodeWithSignature(SIM_INIT_ENTITY_SIG, entity, initMass, initEnergy, initVelocity),
      string(abi.encode("initEntity ", entity, " ", initMass, " ", initEnergy, " ", initVelocity))
    );
}

function setSimValue(
  address simAddress,
  VoxelEntity memory senderEntity,
  VoxelCoord memory senderCoord,
  SimTable senderTable,
  bytes memory senderValue,
  VoxelEntity memory receiverEntity,
  VoxelCoord memory receiverCoord,
  SimTable receiverTable,
  bytes memory receiverValue
) returns (bytes memory) {
  SimSelectorsData memory simSelectors = SimSelectors.get(IStore(simAddress), senderTable, receiverTable);
  if (simSelectors.selector == bytes4(0)) {
    revert("Invalid table");
  }
  if (simSelectors.senderValueType == ValueType.Int256 && simSelectors.receiverValueType == ValueType.Int256) {
    return
      safeCall(
        simAddress,
        abi.encodeWithSelector(
          simSelectors.selector,
          senderEntity,
          senderCoord,
          abi.decode(senderValue, (int256)),
          receiverEntity,
          receiverCoord,
          abi.decode(receiverValue, (int256))
        ),
        string(
          abi.encode(
            "setSimValue ",
            senderEntity,
            " ",
            senderCoord,
            " ",
            senderTable,
            " ",
            senderValue,
            " ",
            receiverEntity,
            " ",
            receiverCoord,
            " ",
            receiverTable,
            " ",
            receiverValue
          )
        )
      );
  } else if (
    simSelectors.senderValueType == ValueType.ObjectType && simSelectors.receiverValueType == ValueType.ObjectType
  ) {
    return
      safeCall(
        simAddress,
        abi.encodeWithSelector(
          simSelectors.selector,
          senderEntity,
          senderCoord,
          abi.decode(senderValue, (ObjectType)),
          receiverEntity,
          receiverCoord,
          abi.decode(receiverValue, (ObjectType))
        ),
        string(
          abi.encode(
            "setSimValue ",
            senderEntity,
            " ",
            senderCoord,
            " ",
            senderTable,
            " ",
            senderValue,
            " ",
            receiverEntity,
            " ",
            receiverCoord,
            " ",
            receiverTable,
            " ",
            receiverValue
          )
        )
      );
  } else if (
    simSelectors.senderValueType == ValueType.Int256 && simSelectors.receiverValueType == ValueType.ObjectType
  ) {
    return
      safeCall(
        simAddress,
        abi.encodeWithSelector(
          simSelectors.selector,
          senderEntity,
          senderCoord,
          abi.decode(senderValue, (int256)),
          receiverEntity,
          receiverCoord,
          abi.decode(receiverValue, (ObjectType))
        ),
        string(
          abi.encode(
            "setSimValue ",
            senderEntity,
            " ",
            senderCoord,
            " ",
            senderTable,
            " ",
            senderValue,
            " ",
            receiverEntity,
            " ",
            receiverCoord,
            " ",
            receiverTable,
            " ",
            receiverValue
          )
        )
      );
  } else {
    revert("Invalid value type");
  }
}

function onBuild(
  address simAddress,
  VoxelEntity memory entity,
  VoxelCoord memory coord,
  uint256 entityMass
) returns (bytes memory) {
  return
    safeCall(
      simAddress,
      abi.encodeWithSignature(SIM_ON_BUILD_SIG, entity, coord, entityMass),
      string(abi.encode("onBuild ", entity, " ", coord, " ", entityMass))
    );
}

function onMine(address simAddress, VoxelEntity memory entity, VoxelCoord memory coord) returns (bytes memory) {
  return
    safeCall(
      simAddress,
      abi.encodeWithSignature(SIM_ON_MINE_SIG, entity, coord),
      string(abi.encode("onMine ", entity, " ", coord))
    );
}

function onMove(
  address simAddress,
  VoxelEntity memory oldEntity,
  VoxelCoord memory oldCoord,
  VoxelEntity memory newEntity,
  VoxelCoord memory newCoord
) returns (bytes memory) {
  return
    safeCall(
      simAddress,
      abi.encodeWithSignature(SIM_ON_MOVE_SIG, oldEntity, oldCoord, newEntity, newCoord),
      string(abi.encode("onMove ", oldEntity, " ", oldCoord, " ", newEntity, " ", newCoord))
    );
}

function onActivate(address simAddress, VoxelEntity memory entity, VoxelCoord memory coord) returns (bytes memory) {
  return
    safeCall(
      simAddress,
      abi.encodeWithSignature(SIM_ON_ACTIVATE_SIG, entity, coord),
      string(abi.encode("onActivate ", entity, " ", coord))
    );
}
