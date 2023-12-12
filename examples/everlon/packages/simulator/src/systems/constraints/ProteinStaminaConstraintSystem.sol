// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Protein, ProteinTableId } from "@tenet-simulator/src/codegen/tables/Protein.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";

import { VoxelCoord, SimTable } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";

contract ProteinStaminaConstraintSystem is Constraint {
  function registerProteinStaminaSelector() public {
    SimAction.set(
      SimTable.Protein,
      SimTable.Stamina,
      IWorld(_world()).proteinStaminaTransformation.selector,
      IWorld(_world()).proteinStaminaTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(toAmount, (int256)));
  }

  function proteinStaminaTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function proteinStaminaTransfer(
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
    revert("ProteinStaminaConstraintSystem: You can't convert your own protein to stamina");
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
      hasKey(ProteinTableId, Protein.encodeKeyTuple(worldAddress, senderObjectEntityId)),
      "ProteinStaminaConstraintSystem: Sender protein must be initialized"
    );
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, receiverObjectEntityId)),
      "ProteinStaminaConstraintSystem: Receiver entity must be initialized"
    );
    (int256 senderProteinDelta, int256 receiverStaminaDelta) = decodeAmounts(fromAmount, toAmount);
    require(receiverStaminaDelta > 0, "ProteinStaminaConstraintSystem: Cannot decrease others stamina");
    require(senderProteinDelta < 0, "ProteinStaminaConstraintSystem: Cannot increase your own protein");
    uint256 senderProtein = int256ToUint256(senderProteinDelta);
    uint256 receiverStamina = int256ToUint256(receiverStaminaDelta);
    require(
      senderProtein == receiverStamina,
      "ProteinStaminaConstraintSystem: Sender protein must equal receiver stamina"
    );
    uint256 currentSenderProtein = Protein.get(worldAddress, senderObjectEntityId);
    require(
      currentSenderProtein >= senderProtein,
      "ProteinStaminaConstraintSystem: Sender does not have enough protein"
    );
    Protein.set(worldAddress, senderObjectEntityId, currentSenderProtein - senderProtein);
    uint256 currentReceiverStamina = Stamina.get(worldAddress, receiverObjectEntityId);
    Stamina.set(worldAddress, receiverObjectEntityId, currentReceiverStamina + receiverStamina);
  }
}
