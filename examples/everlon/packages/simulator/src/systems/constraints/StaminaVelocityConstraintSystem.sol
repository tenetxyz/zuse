// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Velocity, VelocityData, VelocityTableId } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { absInt32 } from "@tenet-utils/src/MathUtils.sol";

import { VoxelCoord, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";
import { getVelocity } from "@tenet-simulator/src/Utils.sol";

contract StaminaVelocityConstraintSystem is Constraint {
  function registerStaminaVelocitySelector() public {
    SimAction.set(
      SimTable.Stamina,
      SimTable.Velocity,
      IWorld(_world()).staminaVelocityTransformation.selector,
      IWorld(_world()).staminaVelocityTransfer.selector
    );
  }

  function decodeAmounts(
    bytes memory fromAmount,
    bytes memory ToAmount
  ) internal pure returns (int256, VoxelCoord memory) {
    return (abi.decode(fromAmount, (int256)), abi.decode(ToAmount, (VoxelCoord)));
  }

  function staminaVelocityTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function staminaVelocityTransfer(
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
      hasKey(VelocityTableId, Velocity.encodeKeyTuple(worldAddress, objectEntityId)),
      "StaminaVelocityConstraintSystem: Receiver entity not initialized"
    );
    (int256 senderStaminaDelta, VoxelCoord memory receiverVelocityDelta) = decodeAmounts(fromAmount, toAmount);
    // You can only spend stamina to decrease velocity
    // To increase, you have to move
    require(senderStaminaDelta >= 0, "Stamina delta must be positive");
    require(
      receiverVelocityDelta.x <= 0 && receiverVelocityDelta.y <= 0 && receiverVelocityDelta.z <= 0,
      "Velocity delta must be negative"
    );
    VoxelCoord memory currentVelocity = getVelocity(worldAddress, objectEntityId);
    require(
      absInt32(currentVelocity.x) >= absInt32(receiverVelocityDelta.x) &&
        absInt32(currentVelocity.y) >= absInt32(receiverVelocityDelta.y) &&
        absInt32(currentVelocity.z) >= absInt32(receiverVelocityDelta.z),
      "Velocity delta must be less than current velocity"
    );
    VoxelCoord memory newVelocity = VoxelCoord({
      x: (currentVelocity.x >= 0)
        ? currentVelocity.x + receiverVelocityDelta.x
        : currentVelocity.x - receiverVelocityDelta.x,
      y: (currentVelocity.y >= 0)
        ? currentVelocity.y + receiverVelocityDelta.y
        : currentVelocity.y - receiverVelocityDelta.y,
      z: (currentVelocity.z >= 0)
        ? currentVelocity.z + receiverVelocityDelta.z
        : currentVelocity.z - receiverVelocityDelta.z
    });

    // Since this is always a decrease, the entity is always moving in the opposite direction
    // which means we do mass * new velocity
    uint256 resourceRequired = 0;
    {
      // Since the new velocity won't just be 1, we need to do a sum
      uint256 bodyMass = Mass.get(worldAddress, objectEntityId);
      int32 receiverVelocityDeltaX = currentVelocity.x > 0 ? receiverVelocityDelta.x : -receiverVelocityDelta.x;
      uint256 resourceRequiredX = IWorld(_world()).calculateResourceRequired(
        currentVelocity.x,
        receiverVelocityDeltaX,
        bodyMass
      );
      int32 receiverVelocityDeltaY = currentVelocity.y > 0 ? receiverVelocityDelta.y : -receiverVelocityDelta.y;
      uint256 resourceRequiredY = IWorld(_world()).calculateResourceRequired(
        currentVelocity.y,
        receiverVelocityDeltaY,
        bodyMass
      );
      int32 receiverVelocityDeltaZ = currentVelocity.z > 0 ? receiverVelocityDelta.z : -receiverVelocityDelta.z;
      uint256 resourceRequiredZ = IWorld(_world()).calculateResourceRequired(
        currentVelocity.z,
        receiverVelocityDeltaZ,
        bodyMass
      );
      resourceRequired = resourceRequiredX + resourceRequiredY + resourceRequiredZ;
    }

    // Consume stamina
    uint256 currentStamina = Stamina.get(worldAddress, objectEntityId);
    require(currentStamina >= resourceRequired, "Not enough stamina to spend");
    Stamina.set(worldAddress, objectEntityId, currentStamina - resourceRequired);

    // Flux energy
    IWorld(_world()).fluxEnergy(false, worldAddress, objectEntityId, resourceRequired);

    // Update velocity
    Velocity.set(
      worldAddress,
      objectEntityId,
      VelocityData({ lastUpdateBlock: block.number, velocity: abi.encode(newVelocity) })
    );
  }

  function transfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    // You can do this by calling move though, just not directly
    // TODO: rethink if this should be consolidated with the on move event in WorldMoveEventSystem
    revert(
      "StaminaVelocityConstraintSystem: You can't spend your stamina to increase/decrease velocity of another entity"
    );
  }
}
