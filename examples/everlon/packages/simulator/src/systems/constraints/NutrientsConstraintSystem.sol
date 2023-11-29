// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Nitrogen, NitrogenTableId } from "@tenet-simulator/src/codegen/tables/Nitrogen.sol";
import { Phosphorus, PhosphorusTableId } from "@tenet-simulator/src/codegen/tables/Phosphorus.sol";
import { Potassium, PotassiumTableId } from "@tenet-simulator/src/codegen/tables/Potassium.sol";
import { Nutrients, NutrientsTableId } from "@tenet-simulator/src/codegen/tables/Nutrients.sol";

import { absoluteDifference } from "@tenet-utils/src/MathUtils.sol";
import { VoxelCoord, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";
import { requireHasNPK } from "@tenet-simulator/src/Utils.sol";
import { NUTRIENT_TRANSFER_MAX_DELTA } from "@tenet-simulator/src/Constants.sol";

contract NutrientsConstraintSystem is Constraint {
  function registerNutrientsSelector() public {
    SimAction.set(
      SimTable.Nutrients,
      SimTable.Nutrients,
      IWorld(_world()).nutrientsTransformation.selector,
      IWorld(_world()).nutrientsTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory ToAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(ToAmount, (int256)));
  }

  function nutrientsTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function nutrientsTransfer(
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
    revert("NutrientsConstraintSystem: You can't convert your own nutrients to nutrients");
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
      hasKey(NutrientsTableId, Nutrients.encodeKeyTuple(worldAddress, senderObjectEntityId)),
      "NutrientsConstraintSystem: Sender nutrients must be initialized"
    );
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, receiverObjectEntityId)),
      "NutrientsConstraintSystem: Receiver entity must be initialized"
    );

    uint256 senderNutrients;
    uint256 receiverNutrients;
    {
      (int256 senderNutrientsDelta, int256 receiverNutrientsDelta) = decodeAmounts(fromAmount, toAmount);
      require(receiverNutrientsDelta > 0, "NutrientsConstraintSystem: Cannot decrease someone's nutrients");
      require(senderNutrientsDelta < 0, "NutrientsConstraintSystem: Cannot increase your own nutrients");
      senderNutrients = int256ToUint256(receiverNutrientsDelta);
      receiverNutrients = int256ToUint256(receiverNutrientsDelta);
    }

    requireHasNPK(worldAddress, senderObjectEntityId);
    requireHasNPK(worldAddress, receiverObjectEntityId);

    uint256 currentSenderNutrients = Nutrients.get(worldAddress, senderObjectEntityId);
    require(currentSenderNutrients >= senderNutrients, "NutrientsConstraintSystem: Not enough nutrients to transfer");

    uint256 currentReceiverNutrients = Nutrients.get(worldAddress, receiverObjectEntityId);
    require(
      absoluteDifference(currentSenderNutrients, currentReceiverNutrients) <= NUTRIENT_TRANSFER_MAX_DELTA,
      "NutrientsConstraintSystem: Can't transfer from high to low if there's a large difference"
    );

    receiverNutrients = calcReceiverNutrients(
      worldAddress,
      senderObjectEntityId,
      receiverObjectEntityId,
      senderNutrients
    );
    if (receiverNutrients == 0) {
      return;
    }
    require(
      senderNutrients >= receiverNutrients,
      "NutrientsConstraintSystem: Not enough energy to nutrients to sender"
    );

    Nutrients.set(worldAddress, receiverObjectEntityId, currentReceiverNutrients + receiverNutrients);
    Nutrients.set(worldAddress, senderObjectEntityId, currentSenderNutrients - senderNutrients);
    uint256 energyCost = senderNutrients - receiverNutrients;
    if (energyCost > 0) {
      IWorld(_world()).fluxEnergy(false, worldAddress, senderObjectEntityId, energyCost);
    }
  }

  function calcReceiverNutrients(
    address worldAddress,
    bytes32 senderObjectEntityId,
    bytes32 receiverObjectEntityId,
    uint256 senderNutrients
  ) internal returns (uint256) {
    uint256 senderNPK = Nitrogen.get(worldAddress, senderObjectEntityId) +
      Phosphorus.get(worldAddress, senderObjectEntityId) +
      Potassium.get(worldAddress, senderObjectEntityId);
    uint256 receiverNPK = Nitrogen.get(worldAddress, receiverObjectEntityId) +
      Phosphorus.get(worldAddress, receiverObjectEntityId) +
      Potassium.get(worldAddress, receiverObjectEntityId);

    // Calculate the actual transfer amount
    uint256 actualTransfer = (senderNutrients * senderNPK * receiverNPK) / (14000);

    uint256 ninetyFivePercent = (senderNutrients * 95) / 100;
    if (actualTransfer > ninetyFivePercent) {
      actualTransfer = ninetyFivePercent;
    }

    return actualTransfer;
  }
}
