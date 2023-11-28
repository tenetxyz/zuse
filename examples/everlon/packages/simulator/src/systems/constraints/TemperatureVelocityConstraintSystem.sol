// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { Velocity, VelocityData, VelocityTableId } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Temperature, TemperatureTableId } from "@tenet-simulator/src/codegen/tables/Temperature.sol";

import { absInt32 } from "@tenet-utils/src/MathUtils.sol";
import { VoxelCoord, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";
import { getVelocity } from "@tenet-simulator/src/Utils.sol";
import { voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { getEntityIdFromObjectEntityId, getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";
import { WORLD_MOVE_SIG } from "@tenet-base-world/src/Constants.sol";

contract TemperatureVelocityConstraintSystem is Constraint {
  function registerTemperatureVelocitySelector() public {
    SimAction.set(
      SimTable.Temperature,
      SimTable.Velocity,
      IWorld(_world()).temperatureVelocityTransformation.selector,
      IWorld(_world()).temperatureVelocityTransfer.selector
    );
  }

  function decodeAmounts(
    bytes memory fromAmount,
    bytes memory ToAmount
  ) internal pure returns (int256, VoxelCoord[] memory) {
    return (abi.decode(fromAmount, (int256)), abi.decode(ToAmount, (VoxelCoord[])));
  }

  function temperatureVelocityTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function temperatureVelocityTransfer(
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
    // You can do this by calling move though, just not directly
    // TODO: rethink if this should be consolidated with the on move event in WorldMoveEventSystem
    revert("TemperatureVelocityConstraintSystem: You can't convert your own temperature to velocity");
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
      hasKey(TemperatureTableId, Temperature.encodeKeyTuple(worldAddress, senderObjectEntityId)),
      "TemperatureVelocityConstraintSystem: Sender entity not initialized"
    );
    (, VoxelCoord[] memory receiverPositionDelta) = decodeAmounts(fromAmount, toAmount);

    bytes32 workingEntityId = getEntityIdFromObjectEntityId(IStore(worldAddress), receiverObjectEntityId);
    bytes32 objectTypeId = ObjectType.get(IStore(worldAddress), workingEntityId);
    VoxelCoord memory workingCoord = receiverCoord;
    for (uint256 i = 0; i < receiverPositionDelta.length; i++) {
      // Note: we can't use IMoveSystem here because we need to safe call it
      (bool moveSuccess, bytes memory moveReturnData) = worldAddress.call(
        abi.encodeWithSignature(
          WORLD_MOVE_SIG,
          senderObjectEntityId,
          objectTypeId,
          workingCoord,
          receiverPositionDelta[i]
        )
      );
      if (moveSuccess && moveReturnData.length > 0) {
        (, workingEntityId) = abi.decode(moveReturnData, (bytes32, bytes32));
        // The entity could have been moved some place else, besides the new coord
        // so we need to update the working coord
        if (
          !voxelCoordsAreEqual(getVoxelCoordStrict(IStore(worldAddress), workingEntityId), receiverPositionDelta[i])
        ) {
          // this means some collision happened which caused other movements
          // for now we just stop the loop
          break;
        }
        workingCoord = receiverPositionDelta[i];
      } else {
        // Could not move, so we break out of the loop
        break;
      }
    }
  }
}
