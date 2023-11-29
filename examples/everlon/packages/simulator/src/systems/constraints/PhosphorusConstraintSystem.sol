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

contract PhosphorusConstraintSystem is Constraint {
  function registerNitrogenSelector() public {
    SimAction.set(
      SimTable.Phosphorus,
      SimTable.Phosphorus,
      IWorld(_world()).phosphorusTransformation.selector,
      IWorld(_world()).phosphorusTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory ToAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(ToAmount, (int256)));
  }

  function phosphorusTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function phosphorusTransfer(
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
      !hasKey(PhosphorusTableId, Phosphorus.encodeKeyTuple(worldAddress, objectEntityId)),
      "PhosphorusConstraintSystem: Phosphorus entity already initialized"
    );
    (, int256 receiverPhosphorousDelta) = decodeAmounts(fromAmount, toAmount);
    require(receiverPhosphorousDelta >= 0, "PhosphorusConstraintSystem: Cannot set a negative phosphorus value");

    uint256 phosphorousAmount = int256ToUint256(receiverPhosphorousDelta);
    uint256 objectNPK = phosphorousAmount +
      Potassium.get(worldAddress, objectEntityId) +
      Nitrogen.get(worldAddress, objectEntityId);
    require(
      objectNPK <= NUM_MAX_INIT_NPK,
      "PhosphorusConstraintSystem: NPK must be less than or equal to the initial NPK constant"
    );

    Phosphorus.set(worldAddress, objectEntityId, phosphorousAmount);
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
      hasKey(PhosphorusTableId, Phosphorus.encodeKeyTuple(worldAddress, objectEntityId)),
      "PhosphorusConstraintSystem: Phosphorus entity not initialized"
    );
    (int256 senderPhosphorusDelta, int256 receiverPhosphorusDelta) = decodeAmounts(fromAmount, toAmount);
    require(receiverPhosphorusDelta > 0, "PhosphorusConstraintSystem: Cannot decrease someone's phosphorus");
    require(senderPhosphorusDelta < 0, "PhosphorusConstraintSystem: Cannot increase your own phosphorus");
    uint256 senderPhosphorus = int256ToUint256(receiverPhosphorusDelta);
    uint256 receiverPhosphorus = int256ToUint256(receiverPhosphorusDelta);
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, receiverObjectEntityId)),
      "PhosphorusConstraintSystem: Receiver entity not initialized"
    );

    uint256 currentSenderPhosphorus = Phosphorus.get(worldAddress, senderObjectEntityId);
    uint256 currentReceiverPhosphorus = Phosphorus.get(worldAddress, receiverObjectEntityId);
    require(
      currentSenderPhosphorus >= senderPhosphorus,
      "PhosphorusConstraintSystem: Sender does not have enough phosphorus"
    );
    require(
      currentSenderPhosphorus >= currentReceiverPhosphorus,
      "PhosphorusConstraintSystem: Phosphorus must flow from high to low concentration"
    );

    Phosphorus.set(worldAddress, receiverObjectEntityId, currentReceiverPhosphorus + receiverPhosphorus);
    Phosphorus.set(worldAddress, senderObjectEntityId, currentSenderPhosphorus - senderPhosphorus);
  }
}
