// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { isZeroCoord, voxelCoordsAreEqual, uint256ToInt32, dot, mulScalar, divScalar, min, add, sub, safeSubtract, safeAdd, abs, absInt32 } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, getNeighbourEntities, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";

uint256 constant MAXIMUM_ENERGY_OUT = 100;
uint256 constant MAXIMUM_ENERGY_IN = 100;

contract EnergySystem is SimHandler {
  function setEnergy(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    uint256 senderEnergy,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    uint256 receiverEnergy
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      EnergyTableId,
      Energy.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Sender entity does not exist");
    // If it doesn't exist, it'll be 0
    uint256 currentReceiverEnergy = Energy.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
    if (isEntityEqual(senderEntity, receiverEntity)) {
      // Transformation
      require(currentReceiverEnergy >= receiverEnergy, "Not enough energy to transfer");
      fluxEnergyOut(callerAddress, receiverEntity, currentReceiverEnergy - receiverEnergy);
    } else {
      // Transfer
      require(receiverEnergy >= currentReceiverEnergy, "Cannot take energy from receiver");
      energyTransfer(
        callerAddress,
        senderEntity,
        senderCoord,
        receiverEntity,
        receiverCoord,
        receiverEnergy - currentReceiverEnergy
      );
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
      VoxelEntity memory newTerrainEntity = createTerrainEntity(callerAddress, entity.scale, energyReceiverCoord);
      energyReceiverEntity = newTerrainEntity;
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
