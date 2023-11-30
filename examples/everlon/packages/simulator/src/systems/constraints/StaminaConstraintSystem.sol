// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";

import { VoxelCoord, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";

contract StaminaConstraintSystem is Constraint {
  function registerStaminaSelector() public {
    SimAction.set(
      SimTable.Stamina,
      SimTable.Stamina,
      IWorld(_world()).staminaTransformation.selector,
      IWorld(_world()).staminaTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(toAmount, (int256)));
  }

  function staminaTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function staminaTransfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transfer(senderObjectEntityId, senderCoord, receiverObjectEntityId, receiverCoord, fromAmount, toAmount);
  }

  function transformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    revert("StaminaConstraintSystem: You can't convert your own stamina to stamina");
  }

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
      "StaminaConstraintSystem: Sender stamina must be initialized"
    );
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, receiverObjectEntityId)),
      "StaminaConstraintSystem: Receiver entity must be initialized"
    );
    (int256 senderStaminaDelta, int256 receiverStaminaDelta) = decodeAmounts(fromAmount, toAmount);
    require(receiverStaminaDelta > 0, "StaminaConstraintSystem: Cannot decrease someone's stamina");
    require(senderStaminaDelta < 0, "StaminaConstraintSystem: Cannot increase your own stamina");
    uint256 senderStamina = int256ToUint256(receiverStaminaDelta);
    uint256 receiverStamina = int256ToUint256(receiverStaminaDelta);
    require(senderStamina == receiverStamina, "StaminaConstraintSystem: Sender stamina must equal receiver stamina");

    uint256 currentSenderStamina = Stamina.get(worldAddress, senderObjectEntityId);
    require(currentSenderStamina >= senderStamina, "StaminaConstraintSystem: Not enough stamina to transfer");

    uint256 currentReceiverStamina = Stamina.get(worldAddress, receiverObjectEntityId);
    Stamina.set(worldAddress, receiverObjectEntityId, currentReceiverStamina + receiverStamina);
    Stamina.set(worldAddress, senderObjectEntityId, currentSenderStamina - senderStamina);
  }
}
