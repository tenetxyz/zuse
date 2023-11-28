// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";

import { VoxelCoord, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";

contract MassConstraintSystem is Constraint {
  function registerMassSelector() public {
    SimAction.set(
      SimTable.Mass,
      SimTable.Mass,
      IWorld(_world()).massTransformation.selector,
      IWorld(_world()).massTransfer.selector
    );
  }

  function decodeAmounts(bytes memory fromAmount, bytes memory ToAmount) internal pure returns (int256, int256) {
    return (abi.decode(fromAmount, (int256)), abi.decode(ToAmount, (int256)));
  }

  function massTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function massTransfer(
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
    require(hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, objectEntityId)), "Mass must be initialized");
    (int256 senderMassDelta, int256 receiverMassDelta) = decodeAmounts(fromAmount, toAmount);
    if (receiverMassDelta == 0) {
      return;
    }
    uint256 currentMass = Mass.get(worldAddress, objectEntityId);
    uint256 newMass = addUint256AndInt256(currentMass, receiverMassDelta);
    if (currentMass > 0) {
      // World is allowed to increase mass, eg during build
      require(_msgSender() == _world() || currentMass >= newMass, "MassConstraintSystem: Cannot increase mass");
    }
    Mass.set(worldAddress, objectEntityId, newMass);

    // Calculate how much energy this operation requires
    bool isMassIncrease = receiverMassDelta > 0; // flux in if mass increases
    uint256 energyRequired = int256ToUint256(receiverMassDelta) * 10;
    if (!isMassIncrease) {
      energyRequired = energyRequired * 2;
    }
    IWorld(_world()).fluxEnergy(isMassIncrease, worldAddress, objectEntityId, energyRequired);
  }

  function transfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    revert("MassConstraintSystem: You can't transfer mass to another entity");
  }
}
