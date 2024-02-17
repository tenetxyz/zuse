// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy, EnergyTableId } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";

import { absoluteDifference } from "@tenet-utils/src/MathUtils.sol";
import { VoxelCoord, SimTable } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256, safeSubtract } from "@tenet-utils/src/TypeUtils.sol";

contract EnergyStaminaConstraintSystem is Constraint {
  function registerEnergyStaminaSelector() public {
    SimAction.set(
      SimTable.Energy,
      SimTable.Stamina,
      IWorld(_world()).energyStaminaTransformation.selector,
      IWorld(_world()).energyStaminaTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(toAmount, (int256)));
  }

  function energyStaminaTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function energyStaminaTransfer(
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
    address worldAddress = super.getCallerAddress();
    require(
      hasKey(EnergyTableId, Energy.encodeKeyTuple(worldAddress, objectEntityId)),
      "EnergyStaminaConstraintSystem: Entity must have energy"
    );
    // This transformation is used by the world when an object is mined
    // so we can transfer its energy forms back to general energy
    require(_msgSender() == _world(), "EnergyStaminaConstraintSystem: Transformation must be called by world");
    (int256 energyDelta, int256 staminaDelta) = decodeAmounts(fromAmount, toAmount);
    if ((energyDelta > 0 && staminaDelta > 0) || (energyDelta < 0 && staminaDelta < 0)) {
      revert("EnergyStaminaConstraintSystem: Energy delta and stamina delta must have opposite signs");
    }
    uint256 objectEnergy = int256ToUint256(energyDelta);
    uint256 objectStamina = int256ToUint256(staminaDelta);
    require(
      objectEnergy == objectStamina,
      "EnergyStaminaConstraintSystem: Object energy delta must equal object stamina delta"
    );
    uint256 currentObjectEnergy = Energy.get(worldAddress, objectEntityId);
    if (energyDelta < 0) {
      require(currentObjectEnergy >= objectEnergy, "EnergyStaminaConstraintSystem: Object does not have enough energy");
    }
    Energy.set(worldAddress, objectEntityId, addUint256AndInt256(currentObjectEnergy, energyDelta));
    uint256 currentObjectStamina = Stamina.getStamina(worldAddress, objectEntityId);
    if (staminaDelta < 0) {
      require(
        currentObjectStamina >= objectStamina,
        "EnergyStaminaConstraintSystem: Object does not have enough stamina"
      );
    }
    Stamina.setStamina(worldAddress, objectEntityId, addUint256AndInt256(currentObjectStamina, staminaDelta));
  }

  function transfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    revert("EnergyStaminaConstraintSystem: You can't convert your own energy to others stamina");
  }
}
