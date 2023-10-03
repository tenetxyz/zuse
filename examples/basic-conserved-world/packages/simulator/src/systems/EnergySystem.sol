// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { isZeroCoord, voxelCoordsAreEqual, uint256ToInt32, dot, mulScalar, divScalar, min, add, sub, safeSubtract, safeAdd, abs, absInt32 } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { console } from "forge-std/console.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, getNeighbourEntities, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";

uint256 constant MAXIMUM_ENERGY_OUT = 100;
uint256 constant MAXIMUM_ENERGY_IN = 100;

contract EnergySystem is System {
  // Constraints
  function energyTransfer(
    VoxelEntity memory entity,
    VoxelCoord memory coord,
    VoxelEntity memory energyReceiverEntity,
    VoxelCoord memory energyReceiverCoord,
    uint256 energyToTransfer
  ) public {
    address callerAddress = _msgSender();
    bool entityExists = hasKey(EnergyTableId, Energy.encodeKeyTuple(callerAddress, entity.scale, entity.entityId));
    uint256 currentEnergy = Energy.get(callerAddress, entity.scale, entity.entityId);
    require(entityExists && currentEnergy >= energyToTransfer, "Not enough energy to transfer");
    require(distanceBetween(coord, energyReceiverCoord) == 1, "Energy can only be fluxed to a surrounding neighbour");
    bool energyReceiverEntityExists = hasKey(
      EnergyTableId,
      Energy.encodeKeyTuple(callerAddress, energyReceiverEntity.scale, energyReceiverEntity.entityId)
    );

    if (!energyReceiverEntityExists) {
      VoxelEntity memory newTerrainEntity = createTerrainEntity(callerAddress, energyReceiverCoord);
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

  function fluxEnergyOut(VoxelEntity memory entity, uint256 energyToFlux) public {
    address callerAddress = _msgSender();
    IWorld(_world()).fluxEnergy(false, callerAddress, entity, energyToFlux);
  }
}
