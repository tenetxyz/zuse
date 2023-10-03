// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { SIM_MASS_CHANGE_SIG, SIM_ENERGY_TRANSFER_SIG, SIM_FLUX_ENERGY_OUT_SIG } from "@tenet-simulator/src/Constants.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";

function massChange(
  address simAddress,
  bytes32 entityId,
  VoxelCoord memory coord,
  uint256 newMass
) returns (bytes memory) {
  return
    safeCall(
      simAddress,
      abi.encodeWithSignature(SIM_MASS_CHANGE_SIG, entityId, coord, newMass),
      string(abi.encode("masssChange ", entityId, " ", coord, " ", newMass))
    );
}

function energyTransfer(
  address simAddress,
  bytes32 entityId,
  VoxelCoord memory coord,
  bytes32 energyReceiverEntityId,
  VoxelCoord memory energyReceiverCoord,
  uint256 energyToTransfer
) returns (bytes memory) {
  return
    safeCall(
      simAddress,
      abi.encodeWithSignature(
        SIM_ENERGY_TRANSFER_SIG,
        entityId,
        coord,
        energyReceiverEntityId,
        energyReceiverCoord,
        energyToTransfer
      ),
      string(
        abi.encode(
          "masssChange ",
          entityId,
          " ",
          coord,
          " ",
          energyReceiverEntityId,
          " ",
          energyReceiverCoord,
          " ",
          energyToTransfer
        )
      )
    );
}

function fluxEnergyOut(address simAddress, bytes32 entityId, uint256 energyToFlux) returns (bytes memory) {
  return
    safeCall(
      simAddress,
      abi.encodeWithSignature(SIM_FLUX_ENERGY_OUT_SIG, entityId, energyToFlux),
      string(abi.encode("fluxEnergy ", entityId, " ", energyToFlux))
    );
}
