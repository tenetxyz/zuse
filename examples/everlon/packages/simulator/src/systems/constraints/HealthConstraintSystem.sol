// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Health, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";

import { VoxelCoord, SimTable } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";

contract HealthConstraintSystem is Constraint {
  function registerHealthSelector() public {
    SimAction.set(
      SimTable.Health,
      SimTable.Health,
      IWorld(_world()).healthTransformation.selector,
      IWorld(_world()).healthTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(toAmount, (int256)));
  }

  function healthTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function healthTransfer(
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
    revert("HealthConstraintSystem: You can't convert your own health to health");
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
      hasKey(HealthTableId, Health.encodeKeyTuple(worldAddress, senderObjectEntityId)),
      "HealthConstraintSystem: Sender health must be initialized"
    );
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, receiverObjectEntityId)),
      "HealthConstraintSystem: Receiver entity must be initialized"
    );
    (int256 senderHealthDelta, int256 receiverHealthDelta) = decodeAmounts(fromAmount, toAmount);
    require(receiverHealthDelta > 0, "HealthConstraintSystem: Cannot decrease someone's health");
    require(senderHealthDelta < 0, "HealthConstraintSystem: Cannot increase your own health");
    uint256 senderHealth = int256ToUint256(receiverHealthDelta);
    uint256 receiverHealth = int256ToUint256(receiverHealthDelta);
    require(senderHealth == receiverHealth, "HealthConstraintSystem: Sender health must equal receiver health");

    uint256 currentSenderHealth = Health.getHealth(worldAddress, senderObjectEntityId);
    require(currentSenderHealth >= senderHealth, "HealthConstraintSystem: Not enough health to transfer");

    uint256 currentReceiverHealth = Health.getHealth(worldAddress, receiverObjectEntityId);
    Health.setHealth(worldAddress, receiverObjectEntityId, currentReceiverHealth + receiverHealth);
    Health.setHealth(worldAddress, senderObjectEntityId, currentSenderHealth - senderHealth);
  }
}
