// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { SimSelectors, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";
import { isZeroCoord, voxelCoordsAreEqual, dot, mulScalar, divScalar, add, sub } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, getNeighbourEntities, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";

uint256 constant MAXIMUM_ENERGY_OUT = 100;
uint256 constant MAXIMUM_ENERGY_IN = 100;

contract EnergySystem is SimHandler {
  function registerEnergySelectors() public {
    SimSelectors.set(
      SimTable.Energy,
      SimTable.Energy,
      IWorld(_world()).updateEnergy.selector,
      ValueType.Int256,
      ValueType.Int256
    );
  }

  function updateEnergy(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderEnergyDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverEnergyDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      EnergyTableId,
      Energy.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Sender entity does not exist");
    if (receiverEnergyDelta == 0) {
      return;
    }
    // If it doesn't exist, it'll be 0
    uint256 currentReceiverEnergy = Energy.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
    if (isEntityEqual(senderEntity, receiverEntity)) {
      // Transformation
      require(receiverEnergyDelta < 0, "Cannot increase your own energy");
      uint256 amountToFlux = int256ToUint256(receiverEnergyDelta);
      require(amountToFlux <= currentReceiverEnergy, "Not enough energy to transfer");
      fluxEnergyOut(callerAddress, receiverEntity, amountToFlux);
    } else {
      // Transfer
      uint256 currentSenderEnergy = Energy.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(receiverEnergyDelta > 0, "Cannot decrease others energy");
      uint256 amountToTransfer = int256ToUint256(receiverEnergyDelta);
      require(currentSenderEnergy >= amountToTransfer, "Not enough energy to transfer");
      energyTransfer(callerAddress, senderEntity, senderCoord, receiverEntity, receiverCoord, amountToTransfer);
    }
  }

  function fluxEnergyOut(address callerAddress, VoxelEntity memory entity, uint256 energyToFlux) internal {
    uint256 currentEnergy = Energy.get(callerAddress, entity.scale, entity.entityId);
    IWorld(_world()).fluxEnergy(false, callerAddress, entity, energyToFlux);
    Energy.set(callerAddress, entity.scale, entity.entityId, currentEnergy - energyToFlux);
  }

  function energyTransfer(
    address callerAddress,
    VoxelEntity memory entity,
    VoxelCoord memory coord,
    VoxelEntity memory energyReceiverEntity,
    VoxelCoord memory energyReceiverCoord,
    uint256 energyToTransfer
  ) internal {
    uint256 currentEnergy = Energy.get(callerAddress, entity.scale, entity.entityId);
    require(currentEnergy >= energyToTransfer, "Not enough energy to transfer");
    require(distanceBetween(coord, energyReceiverCoord) == 1, "Energy can only be fluxed to a surrounding neighbour");
    bool energyReceiverEntityExists = hasKey(
      EnergyTableId,
      Energy.encodeKeyTuple(callerAddress, energyReceiverEntity.scale, energyReceiverEntity.entityId)
    );

    if (!energyReceiverEntityExists) {
      energyReceiverEntity = createTerrainEntity(callerAddress, entity.scale, energyReceiverCoord);
      energyReceiverEntityExists = hasKey(
        EnergyTableId,
        Energy.encodeKeyTuple(callerAddress, energyReceiverEntity.scale, energyReceiverEntity.entityId)
      );
    }
    require(energyReceiverEntityExists, "Energy receiver entity does not exist");
    // Increase energy of energyReceiverEntity
    uint256 newReceiverEnergy = Energy.get(callerAddress, energyReceiverEntity.scale, energyReceiverEntity.entityId) +
      energyToTransfer;
    Energy.set(callerAddress, energyReceiverEntity.scale, energyReceiverEntity.entityId, newReceiverEnergy);
    // Decrease energy of eventEntity
    uint256 newEnergy = currentEnergy - energyToTransfer;
    Energy.set(callerAddress, entity.scale, entity.entityId, newEnergy);
  }
}
