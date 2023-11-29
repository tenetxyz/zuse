// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Elixir, ElixirTableId } from "@tenet-simulator/src/codegen/tables/Elixir.sol";
import { Health, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";

import { VoxelCoord, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";

contract ElixirHealthConstraintSystem is Constraint {
  function registerElixirHealthSelector() public {
    SimAction.set(
      SimTable.Elixir,
      SimTable.Health,
      IWorld(_world()).elixirHealthTransformation.selector,
      IWorld(_world()).elixirHealthTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory ToAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(ToAmount, (int256)));
  }

  function elixirHealthTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function elixirHealthTransfer(
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
    revert("ElixirHealthConstraintSystem: You can't convert your own elixir to health");
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
      hasKey(ElixirTableId, Elixir.encodeKeyTuple(worldAddress, senderObjectEntityId)),
      "ElixirHealthConstraintSystem: Sender elixir must be initialized"
    );
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, receiverObjectEntityId)),
      "ElixirHealthConstraintSystem: Receiver entity must be initialized"
    );
    (int256 senderElixirDelta, int256 receiverHealthDelta) = decodeAmounts(fromAmount, toAmount);
    require(receiverHealthDelta > 0, "ElixirHealthConstraintSystem: Cannot decrease others health");
    require(senderElixirDelta < 0, "ElixirHealthConstraintSystem: Cannot increase your own elixir");
    uint256 senderElixir = int256ToUint256(senderElixirDelta);
    uint256 receiverHealth = int256ToUint256(receiverHealthDelta);
    require(senderElixir == receiverHealth, "ElixirHealthConstraintSystem: Sender elixir must equal receiver health");
    uint256 currentSenderElixir = Elixir.get(worldAddress, senderObjectEntityId);
    require(currentSenderElixir >= senderElixir, "ElixirHealthConstraintSystem: Sender does not have enough elixir");
    Elixir.set(worldAddress, senderObjectEntityId, currentSenderElixir - senderElixir);
    uint256 currentReceiverHealth = Health.getHealth(worldAddress, receiverObjectEntityId);
    Health.setHealth(worldAddress, receiverObjectEntityId, currentReceiverHealth + receiverHealth);
  }
}
