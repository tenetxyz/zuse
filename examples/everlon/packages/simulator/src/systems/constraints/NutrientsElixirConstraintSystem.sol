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
import { Elixir, ElixirTableId } from "@tenet-simulator/src/codegen/tables/Elixir.sol";

import { VoxelCoord, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";
import { requireHasNPK } from "@tenet-simulator/src/Utils.sol";

contract NutrientsElixirConstraintSystem is Constraint {
  function registerNutrientsElixirSelector() public {
    SimAction.set(
      SimTable.Nutrients,
      SimTable.Elixir,
      IWorld(_world()).nutrientsElixirTransformation.selector,
      IWorld(_world()).nutrientsElixirTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(toAmount, (int256)));
  }

  function nutrientsElixirTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function nutrientsElixirTransfer(
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
    revert("NutrientsElixirConstraintSystem: You can't convert your nutrients to elixir");
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
      "NutrientsElixirConstraintSystem: Nutrients must be initialized"
    );
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, receiverObjectEntityId)),
      "NutrientsElixirConstraintSystem: Receiver entity must be initialized"
    );

    uint256 senderNutrients;
    uint256 receiverElixir;
    {
      (int256 senderNutrientsDelta, int256 receiverElixirDelta) = decodeAmounts(fromAmount, toAmount);
      require(receiverElixirDelta > 0, "NutrientsElixirConstraintSystem: Cannot decrease someone's elixir");
      require(senderNutrientsDelta < 0, "NutrientsElixirConstraintSystem: Cannot increase your own nutrients");
      senderNutrients = int256ToUint256(senderNutrientsDelta);
      receiverElixir = int256ToUint256(receiverElixirDelta);
    }

    requireHasNPK(worldAddress, senderObjectEntityId);
    {
      uint256 senderNPK = Nitrogen.get(worldAddress, senderObjectEntityId) +
        Phosphorus.get(worldAddress, senderObjectEntityId) +
        Potassium.get(worldAddress, senderObjectEntityId);

      uint256 actualTransfer = (senderNutrients * senderNPK) / (180);
      actualTransfer = (actualTransfer * Phosphorus.get(worldAddress, senderObjectEntityId)) / (40); //if they have lower than 40 P, its bad; else its good

      uint256 ninetyFivePercent = (senderNutrients * 95) / 100;
      if (actualTransfer > ninetyFivePercent) {
        actualTransfer = ninetyFivePercent;
      }

      receiverElixir = actualTransfer;
    }

    if (receiverElixir == 0) {
      return;
    }
    require(
      senderNutrients >= receiverElixir,
      "NutrientsElixirConstraintSystem: Not enough nutrients to convert to elixir"
    );
    uint256 currentSenderNutrients = Nutrients.get(worldAddress, senderObjectEntityId);
    require(
      currentSenderNutrients >= senderNutrients,
      "NutrientsElixirConstraintSystem: Not enough nutrients to transfer"
    );

    Elixir.set(worldAddress, receiverObjectEntityId, Elixir.get(worldAddress, receiverObjectEntityId) + receiverElixir);
    Nutrients.set(worldAddress, senderObjectEntityId, currentSenderNutrients - senderNutrients);

    uint256 energyCost = senderNutrients - receiverElixir;
    if (energyCost > 0) {
      IWorld(_world()).fluxEnergy(false, worldAddress, senderObjectEntityId, energyCost);
    }
  }
}
