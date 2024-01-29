// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";

import { VoxelCoord, SimTable } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";

contract StaminaHealthConstraintSystem is Constraint {
  function registerStaminaHealthSelector() public {
    SimAction.set(
      SimTable.Stamina,
      SimTable.Health,
      IWorld(_world()).staminaHealthTransformation.selector,
      IWorld(_world()).staminaHealthTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(toAmount, (int256)));
  }

  function staminaHealthTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function staminaHealthTransfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transfer(senderObjectEntityId, senderCoord, receiverObjectEntityId, receiverCoord, fromAmount, toAmount);
  }

  // Represents a defense combat move
  function transformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    revert("StaminaHealthConstraintSystem: You can't convert your own stamina to health");
  }

  // Represents an offense combat move
  function transfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    address worldAddress = super.getCallerAddress();
    require(
      hasKey(StaminaTableId, Stamina.encodeKeyTuple(worldAddress, senderObjectEntityId)),
      "StaminaHealthConstraintSystem: Sender stamina must be initialized"
    );
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, receiverObjectEntityId)),
      "StaminaHealthConstraintSystem: Receiver entity must be initialized"
    );
    (int256 senderStaminaDelta, int256 receiverHealthDelta) = decodeAmounts(fromAmount, toAmount);
    require(senderStaminaDelta <= 0, "StaminaHealthConstraintSystem: Sender stamina delta must be negative");
    require(receiverHealthDelta < 0, "StaminaHealthConstraintSystem: Receiver health delta must be negative");
  }
}
