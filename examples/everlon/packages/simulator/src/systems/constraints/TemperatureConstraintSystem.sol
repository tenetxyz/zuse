// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Temperature, TemperatureTableId } from "@tenet-simulator/src/codegen/tables/Temperature.sol";

import { VoxelCoord, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";

contract TemperatureConstraintSystem is Constraint {
  function registerTemperatureSelector() public {
    SimAction.set(
      SimTable.Temperature,
      SimTable.Temperature,
      IWorld(_world()).temperatureTransformation.selector,
      IWorld(_world()).temperatureTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory toAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(toAmount, (int256)));
  }

  function temperatureTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function temperatureTransfer(
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
    revert("TemperatureConstraintSystem: You can't convert your own temperature to temperature");
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
      "TemperatureConstraintSystem: Temperature must be initialized"
    );
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, receiverObjectEntityId)),
      "TemperatureConstraintSystem: Mass must be initialized"
    );
    uint256 senderTemperature;
    uint256 receiverTemperature;
    {
      (int256 senderTemperatureDelta, int256 receiverTemperatureDelta) = decodeAmounts(fromAmount, toAmount);
      require(receiverTemperatureDelta > 0, "Cannot decrease someone's temperature");
      require(senderTemperatureDelta < 0, "Cannot increase your own temperature");
      require(
        !hasKey(StaminaTableId, Stamina.encodeKeyTuple(worldAddress, receiverObjectEntityId)),
        "TemperatureConstraintSystem: Can't have both stamina and temperature"
      );
      senderTemperature = int256ToUint256(receiverTemperatureDelta);
      receiverTemperature = int256ToUint256(receiverTemperatureDelta);
    }

    uint256 currentSenderTemperature = Temperature.get(worldAddress, senderObjectEntityId);
    require(
      currentSenderTemperature >= senderTemperature,
      "TemperatureConstraintSystem: Not enough temperature to transfer"
    );
    uint256 currentReceiverTemperature = Temperature.get(worldAddress, receiverObjectEntityId);
    require(
      currentSenderTemperature >= currentReceiverTemperature,
      "TemperatureConstraintSystem: Can't transfer from low to high"
    );

    receiverTemperature = calcReceiverTemperature(
      worldAddress,
      senderObjectEntityId,
      receiverObjectEntityId,
      senderTemperature
    );
    if (receiverTemperature == 0) {
      return;
    }
    require(
      senderTemperature >= receiverTemperature,
      "TemperatureConstraintSystem: Not enough temperature to transfer"
    );

    Temperature.set(worldAddress, receiverObjectEntityId, currentReceiverTemperature + receiverTemperature);
    Temperature.set(worldAddress, senderObjectEntityId, currentSenderTemperature - senderTemperature);

    uint256 energyCost = senderTemperature - receiverTemperature;
    if (energyCost > 0) {
      IWorld(_world()).fluxEnergy(false, worldAddress, senderObjectEntityId, energyCost);
    }

    IWorld(_world()).applyTemperatureEffects(worldAddress, receiverObjectEntityId);
  }

  function calcReceiverTemperature(
    address worldAddress,
    bytes32 senderObjectEntityId,
    bytes32 receiverObjectEntityId,
    uint256 senderTemperature
  ) internal returns (uint256) {
    uint256 mass = Mass.get(worldAddress, senderObjectEntityId);

    // Calculate the actual transfer amount
    uint256 actualTransfer = (senderTemperature * mass) / (50); //50 is a high mass according to current Everlon perlin budgets

    uint256 ninetyFivePercent = (senderTemperature * 95) / 100;
    if (actualTransfer > ninetyFivePercent) {
      actualTransfer = ninetyFivePercent;
    }

    return actualTransfer;
  }
}
