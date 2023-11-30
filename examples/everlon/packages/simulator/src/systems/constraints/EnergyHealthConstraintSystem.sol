// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy, EnergyTableId } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Health, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";

import { absoluteDifference } from "@tenet-utils/src/MathUtils.sol";
import { VoxelCoord, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256, safeSubtract } from "@tenet-utils/src/TypeUtils.sol";

contract EnergyHealthConstraintSystem is Constraint {
  function registerEnergyHealthSelector() public {
    SimAction.set(
      SimTable.Energy,
      SimTable.Health,
      IWorld(_world()).energyHealthTransformation.selector,
      IWorld(_world()).energyHealthTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(toAmount, (int256)));
  }

  function energyHealthTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function energyHealthTransfer(
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
      "EnergyHealthConstraintSystem: Entity must have energy"
    );
    // This transformation is used by the world when an object is mined
    // so we can transfer its energy forms back to general energy
    require(_msgSender() == _world(), "EnergyHealthConstraintSystem: Transformation must be called by world");
    (int256 energyDelta, int256 healthDelta) = decodeAmounts(fromAmount, toAmount);
    if ((energyDelta > 0 && healthDelta > 0) || (energyDelta < 0 && healthDelta < 0)) {
      revert("EnergyHealthConstraintSystem: Energy delta and health delta must have opposite signs");
    }
    uint256 objectEnergy = int256ToUint256(energyDelta);
    uint256 objectHealth = int256ToUint256(healthDelta);
    require(
      objectEnergy == objectHealth,
      "EnergyHealthConstraintSystem: Object energy delta must equal object health delta"
    );
    uint256 currentObjectEnergy = Energy.get(worldAddress, objectEntityId);
    if (energyDelta < 0) {
      require(currentObjectEnergy >= objectEnergy, "EnergyHealthConstraintSystem: Object does not have enough energy");
    }
    Energy.set(worldAddress, objectEntityId, addUint256AndInt256(currentObjectEnergy, energyDelta));
    uint256 currentObjectHealth = Health.getHealth(worldAddress, objectEntityId);
    if (healthDelta < 0) {
      require(currentObjectHealth >= objectHealth, "EnergyHealthConstraintSystem: Object does not have enough health");
    }
    Health.setHealth(worldAddress, objectEntityId, addUint256AndInt256(currentObjectHealth, healthDelta));
  }

  function transfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    revert("EnergyHealthConstraintSystem: You can't convert your own energy to others health");
  }
}
