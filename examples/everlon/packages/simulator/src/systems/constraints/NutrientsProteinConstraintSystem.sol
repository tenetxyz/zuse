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
import { Protein, ProteinTableId } from "@tenet-simulator/src/codegen/tables/Protein.sol";

import { VoxelCoord, SimTable } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";
import { requireHasNPK } from "@tenet-simulator/src/Utils.sol";

contract NutrientsProteinConstraintSystem is Constraint {
  function registerNutrientsProteinSelector() public {
    SimAction.set(
      SimTable.Nutrients,
      SimTable.Protein,
      IWorld(_world()).nutrientsProteinTransformation.selector,
      IWorld(_world()).nutrientsProteinTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(toAmount, (int256)));
  }

  function nutrientsProteinTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function nutrientsProteinTransfer(
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
    revert("NutrientsProteinConstraintSystem: You can't convert your nutrients to protein");
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
      "NutrientsProteinConstraintSystem: Nutrients must be initialized"
    );
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, receiverObjectEntityId)),
      "NutrientsProteinConstraintSystem: Receiver entity must be initialized"
    );

    uint256 senderNutrients;
    uint256 receiverProtein;
    {
      (int256 senderNutrientsDelta, int256 receiverProteinDelta) = decodeAmounts(fromAmount, toAmount);
      require(receiverProteinDelta > 0, "NutrientsProteinConstraintSystem: Cannot decrease someone's elixir");
      require(senderNutrientsDelta < 0, "NutrientsProteinConstraintSystem: Cannot increase your own nutrients");
      senderNutrients = int256ToUint256(senderNutrientsDelta);
      receiverProtein = int256ToUint256(receiverProteinDelta);
    }

    requireHasNPK(worldAddress, senderObjectEntityId);
    {
      uint256 senderNPK = Nitrogen.get(worldAddress, senderObjectEntityId) +
        Phosphorus.get(worldAddress, senderObjectEntityId) +
        Potassium.get(worldAddress, senderObjectEntityId);

      uint256 actualTransfer = (senderNutrients * senderNPK) / (180);
      actualTransfer = (actualTransfer * Nitrogen.get(worldAddress, senderObjectEntityId)) / (40); //if they have lower than 40 P, its bad; else its good

      uint256 ninetyFivePercent = (senderNutrients * 95) / 100;
      if (actualTransfer > ninetyFivePercent) {
        actualTransfer = ninetyFivePercent;
      }

      receiverProtein = actualTransfer;
    }

    require(
      senderNutrients >= receiverProtein,
      "NutrientsProteinConstraintSystem: Not enough nutrients to convert to protein"
    );
    uint256 currentSenderNutrients = Nutrients.get(worldAddress, senderObjectEntityId);
    require(
      currentSenderNutrients >= senderNutrients,
      "NutrientsProteinConstraintSystem: Not enough nutrients to transfer"
    );

    Protein.set(
      worldAddress,
      receiverObjectEntityId,
      Protein.get(worldAddress, receiverObjectEntityId) + receiverProtein
    );
    Nutrients.set(worldAddress, senderObjectEntityId, currentSenderNutrients - senderNutrients);

    uint256 energyCost = senderNutrients - receiverProtein;
    if (energyCost > 0) {
      IWorld(_world()).fluxEnergy(false, worldAddress, senderObjectEntityId, energyCost);
    }
  }
}
