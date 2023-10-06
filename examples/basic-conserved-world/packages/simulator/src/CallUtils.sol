// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord, VoxelEntity, SimTable } from "@tenet-utils/src/Types.sol";
import { SIM_SET_MASS_SIG, SIM_SET_ENERGY_SIG, SIM_VELOCITY_CHANGE_SIG, SIM_VELOCITY_CACHE_UPDATE_SIG, SIM_INIT_ENTITY_SIG } from "@tenet-simulator/src/Constants.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";

function velocityChange(
  address simAddress,
  VoxelCoord memory oldCoord,
  VoxelCoord memory newCoord,
  VoxelEntity memory oldEntity,
  VoxelEntity memory newEntity
) returns (bytes memory) {
  return
    safeCall(
      simAddress,
      abi.encodeWithSignature(SIM_VELOCITY_CHANGE_SIG, oldCoord, newCoord, oldEntity, newEntity),
      string(abi.encode("velocityChange ", oldCoord, " ", newCoord, " ", oldEntity, " ", newEntity))
    );
}

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
  if (senderTable == SimTable.Energy && receiverTable == SimTable.Energy) {
    return
      safeCall(
        simAddress,
        abi.encodeWithSignature(
          SIM_SET_ENERGY_SIG,
          senderEntity,
          senderCoord,
          abi.decode(senderValue, (uint256)),
          receiverEntity,
          receiverCoord,
          abi.decode(receiverValue, (uint256))
        ),
        "setEnergy"
      );
  } else if (senderTable == SimTable.Mass && receiverTable == SimTable.Mass) {
    return
      safeCall(
        simAddress,
        abi.encodeWithSignature(
          SIM_SET_MASS_SIG,
          senderEntity,
          senderCoord,
          abi.decode(senderValue, (uint256)),
          receiverEntity,
          receiverCoord,
          abi.decode(receiverValue, (uint256))
        ),
        "setMass"
      );
  } else {
    revert("Invalid table");
  }
}
