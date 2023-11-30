// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Nitrogen, NitrogenTableId } from "@tenet-simulator/src/codegen/tables/Nitrogen.sol";
import { Phosphorus, PhosphorusTableId } from "@tenet-simulator/src/codegen/tables/Phosphorus.sol";
import { Potassium, PotassiumTableId } from "@tenet-simulator/src/codegen/tables/Potassium.sol";
import { IBuildSystem } from "@tenet-base-world/src/codegen/world/IBuildSystem.sol";

import { VoxelCoord, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";

import { NUM_MAX_INIT_NPK } from "@tenet-simulator/src/Constants.sol";

contract PotassiumConstraintSystem is Constraint {
  function registerPotassiumSelector() public {
    SimAction.set(
      SimTable.Potassium,
      SimTable.Potassium,
      IWorld(_world()).potassiumTransformation.selector,
      IWorld(_world()).potassiumTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(toAmount, (int256)));
  }

  function potassiumTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function potassiumTransfer(
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
      !hasKey(PotassiumTableId, Potassium.encodeKeyTuple(worldAddress, objectEntityId)),
      "PotassiumConstraintSystem: Potassium entity already initialized"
    );
    (, int256 receiverPotassiumDelta) = decodeAmounts(fromAmount, toAmount);
    require(receiverPotassiumDelta >= 0, "PotassiumConstraintSystem: Cannot set a negative potassium value");

    uint256 potassiumAmount = int256ToUint256(receiverPotassiumDelta);
    uint256 objectNPK = potassiumAmount +
      Nitrogen.get(worldAddress, objectEntityId) +
      Phosphorus.get(worldAddress, objectEntityId);
    require(
      objectNPK <= NUM_MAX_INIT_NPK,
      "PotassiumConstraintSystem: NPK must be less than or equal to the initial NPK constant"
    );

    Potassium.set(worldAddress, objectEntityId, potassiumAmount);
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
      hasKey(PotassiumTableId, Potassium.encodeKeyTuple(worldAddress, senderObjectEntityId)),
      "PotassiumConstraintSystem: Potassium entity not initialized"
    );
    (int256 senderPotassiumDelta, int256 receiverPotassiumDelta) = decodeAmounts(fromAmount, toAmount);
    require(receiverPotassiumDelta > 0, "PotassiumConstraintSystem: Cannot decrease someone's potassium");
    require(senderPotassiumDelta < 0, "PotassiumConstraintSystem: Cannot increase your own potassium");
    uint256 senderPotassium = int256ToUint256(receiverPotassiumDelta);
    uint256 receiverPotassium = int256ToUint256(receiverPotassiumDelta);
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, receiverObjectEntityId)),
      "PotassiumConstraintSystem: Receiver entity not initialized"
    );

    uint256 currentSenderPotassium = Potassium.get(worldAddress, senderObjectEntityId);
    uint256 currentReceiverPotassium = Potassium.get(worldAddress, receiverObjectEntityId);
    require(
      currentSenderPotassium >= senderPotassium,
      "PotassiumConstraintSystem: Sender does not have enough potassium"
    );
    require(
      currentSenderPotassium >= currentReceiverPotassium,
      "PotassiumConstraintSystem: Potassium must flow from high to low concentration"
    );

    Potassium.set(worldAddress, receiverObjectEntityId, currentReceiverPotassium + receiverPotassium);
    Potassium.set(worldAddress, senderObjectEntityId, currentSenderPotassium - senderPotassium);
  }
}
