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

contract NitrogenConstraintSystem is Constraint {
  function registerNitrogenSelector() public {
    SimAction.set(
      SimTable.Nitrogen,
      SimTable.Nitrogen,
      IWorld(_world()).nitrogenTransformation.selector,
      IWorld(_world()).nitrogenTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory ToAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(ToAmount, (int256)));
  }

  function nitrogenTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function nitrogenTransfer(
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
      !hasKey(NitrogenTableId, Nitrogen.encodeKeyTuple(worldAddress, objectEntityId)),
      "NitrogenConstraintSystem: Nitrogen entity already initialized"
    );
    (, int256 receiverNitrogenDelta) = decodeAmounts(fromAmount, toAmount);
    require(receiverNitrogenDelta >= 0, "NitrogenConstraintSystem: Cannot set a negative nitrogen value");

    uint256 nitrogenAmount = int256ToUint256(receiverNitrogenDelta);
    uint256 objectNPK = nitrogenAmount +
      Potassium.get(worldAddress, objectEntityId) +
      Phosphorus.get(worldAddress, objectEntityId);
    require(
      objectNPK <= NUM_MAX_INIT_NPK,
      "NitrogenConstraintSystem: NPK must be less than or equal to the initial NPK constant"
    );

    Nitrogen.set(worldAddress, objectEntityId, nitrogenAmount);
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
      hasKey(NitrogenTableId, Nitrogen.encodeKeyTuple(worldAddress, objectEntityId)),
      "NitrogenConstraintSystem: Nitrogen entity not initialized"
    );
    (int256 senderNitrogenDelta, int256 receiverNitrogenDelta) = decodeAmounts(fromAmount, toAmount);
    require(receiverNitrogenDelta > 0, "NitrogenConstraintSystem: Cannot decrease someone's nitrogen");
    require(senderNitrogenDelta < 0, "NitrogenConstraintSystem: Cannot increase your own nitrogen");
    uint256 senderNitrogen = int256ToUint256(receiverNitrogenDelta);
    uint256 receiverNitrogen = int256ToUint256(receiverNitrogenDelta);
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, receiverObjectEntityId)),
      "NitrogenConstraintSystem: Receiver entity not initialized"
    );

    uint256 currentSenderNitrogen = Nitrogen.get(worldAddress, senderObjectEntityId);
    uint256 currentReceiverNitrogen = Nitrogen.get(worldAddress, receiverObjectEntityId);
    require(currentSenderNitrogen >= senderNitrogen, "NitrogenConstraintSystem: Sender does not have enough nitrogen");
    require(
      currentSenderNitrogen >= currentReceiverNitrogen,
      "NitrogenConstraintSystem: Nitrogen must flow from high to low concentration"
    );

    Nitrogen.set(worldAddress, receiverObjectEntityId, currentReceiverNitrogen + receiverNitrogen);
    Nitrogen.set(worldAddress, senderObjectEntityId, currentSenderNitrogen - senderNitrogen);
  }
}
