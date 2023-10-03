// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { SIM_MASS_CHANGE_SIG, SIM_ENERGY_TRANSFER_SIG, SIM_FLUX_ENERGY_OUT_SIG, SIM_VELOCITY_CHANGE_SIG, SIM_VELOCITY_CACHE_UPDATE_SIG } from "@tenet-simulator/src/Constants.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";

function massChange(
  address simAddress,
  VoxelEntity memory entity,
  VoxelCoord memory coord,
  uint256 newMass
) returns (bytes memory) {
  return
    safeCall(
      simAddress,
      abi.encodeWithSignature(SIM_MASS_CHANGE_SIG, entity, coord, newMass),
      string(abi.encode("masssChange ", entity, " ", coord, " ", newMass))
    );
}

function energyTransfer(
  address simAddress,
  VoxelEntity memory entity,
  VoxelCoord memory coord,
  VoxelEntity memory energyReceiverEntity,
  VoxelCoord memory energyReceiverCoord,
  uint256 energyToTransfer
) returns (bytes memory) {
  return
    safeCall(
      simAddress,
      abi.encodeWithSignature(
        SIM_ENERGY_TRANSFER_SIG,
        entity,
        coord,
        energyReceiverEntity,
        energyReceiverCoord,
        energyToTransfer
      ),
      string(
        abi.encode(
          "masssChange ",
          entity,
          " ",
          coord,
          " ",
          energyReceiverEntity,
          " ",
          energyReceiverCoord,
          " ",
          energyToTransfer
        )
      )
    );
}

function fluxEnergyOut(address simAddress, VoxelEntity memory entity, uint256 energyToFlux) returns (bytes memory) {
  return
    safeCall(
      simAddress,
      abi.encodeWithSignature(SIM_FLUX_ENERGY_OUT_SIG, entity, energyToFlux),
      string(abi.encode("fluxEnergy ", entity, " ", energyToFlux))
    );
}

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
