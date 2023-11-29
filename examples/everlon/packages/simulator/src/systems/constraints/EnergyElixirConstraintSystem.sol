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
import { Elixir, ElixirTableId } from "@tenet-simulator/src/codegen/tables/Elixir.sol";

import { absoluteDifference } from "@tenet-utils/src/MathUtils.sol";
import { VoxelCoord, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256, safeSubtract } from "@tenet-utils/src/TypeUtils.sol";

contract EnergyElixirConstraintSystem is Constraint {
  function registerEnergyElixirSelector() public {
    SimAction.set(
      SimTable.Energy,
      SimTable.Elixir,
      IWorld(_world()).energyElixirTransformation.selector,
      IWorld(_world()).energyElixirTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory ToAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(ToAmount, (int256)));
  }

  function energyElixirTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function energyElixirTransfer(
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
      "EnergyElixirConstraintSystem: Entity must have energy"
    );
    // This transformation is used by the world when an object is mined
    // so we can transfer its energy forms back to general energy
    require(_msgSender() == _world(), "EnergyElixirConstraintSystem: Transformation must be called by world");
    (int256 energyDelta, int256 elixirDelta) = decodeAmounts(fromAmount, toAmount);
    if ((energyDelta > 0 && elixirDelta > 0) || (energyDelta < 0 && elixirDelta < 0)) {
      revert("EnergyElixirConstraintSystem: Energy delta and elixir delta must have opposite signs");
    }
    uint256 objectEnergy = int256ToUint256(energyDelta);
    uint256 objectElixir = int256ToUint256(elixirDelta);
    require(
      objectEnergy == objectElixir,
      "EnergyElixirConstraintSystem: Object energy delta must equal object elixir delta"
    );
    uint256 currentObjectEnergy = Energy.get(worldAddress, objectEntityId);
    if (energyDelta < 0) {
      require(currentObjectEnergy >= objectEnergy, "EnergyElixirConstraintSystem: Object does not have enough energy");
    }
    Energy.set(worldAddress, objectEntityId, addUint256AndInt256(currentObjectEnergy, energyDelta));
    uint256 currentObjectElixir = Elixir.get(worldAddress, objectEntityId);
    if (elixirDelta < 0) {
      require(currentObjectElixir >= objectElixir, "EnergyElixirConstraintSystem: Object does not have enough elixir");
    }
    Elixir.set(worldAddress, objectEntityId, addUint256AndInt256(currentObjectElixir, elixirDelta));
  }

  function transfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    revert("EnergyElixirConstraintSystem: You can't convert your own energy to others elixir");
  }
}
