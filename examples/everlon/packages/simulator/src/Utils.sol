// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { Nitrogen, NitrogenTableId } from "@tenet-simulator/src/codegen/tables/Nitrogen.sol";
import { Phosphorus, PhosphorusTableId } from "@tenet-simulator/src/codegen/tables/Phosphorus.sol";
import { Potassium, PotassiumTableId } from "@tenet-simulator/src/codegen/tables/Potassium.sol";

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { Velocity, VelocityData, VelocityTableId } from "@tenet-simulator/src/codegen/tables/Velocity.sol";

function getVelocity(address worldAddress, bytes32 objectEntityId) view returns (VoxelCoord memory) {
  bytes memory velocity = Velocity.getVelocity(worldAddress, objectEntityId);
  return abi.decode(velocity, (VoxelCoord));
}

function requireHasNPK(address worldAddress, bytes32 objectEntityId) view {
  require(
    hasKey(NitrogenTableId, Nitrogen.encodeKeyTuple(worldAddress, objectEntityId)),
    "requireHasNPK: Entity nitrogen must be initialized"
  );
  require(
    hasKey(PhosphorusTableId, Phosphorus.encodeKeyTuple(worldAddress, objectEntityId)),
    "requireHasNPK: Entity phosphorus must be initialized"
  );
  require(
    hasKey(PotassiumTableId, Potassium.encodeKeyTuple(worldAddress, objectEntityId)),
    "requireHasNPK: Entity potassium must be initialized"
  );
}
