// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { SIM_MASS_CHANGE_SIG } from "@tenet-simulator/src/Constants.sol";
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
