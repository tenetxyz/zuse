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
import { console } from "forge-std/console.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, getNeighbourEntities, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";

contract EnergySystem is System {
  // Constraints
  function energyTransfer(
    bytes32 entityId,
    VoxelCoord memory coord,
    bytes32 energyReceiverEntityId,
    VoxelCoord memory energyReceiverCoord,
    uint256 energyToTransfer
  ) public {
    address callerAddress = _msgSender();
    bool entityExists = hasKey(EnergyTableId, Energy.encodeKeyTuple(callerAddress, entityId));
    uint256 currentEnergy = Energy.get(callerAddress, entityId);
    require(entityExists && currentEnergy >= energyToTransfer, "Not enough energy to transfer");
    require(distanceBetween(coord, energyReceiverCoord) == 1, "Energy can only be fluxed to a surrounding neighbour");
    bool energyReceiverEntityExists = hasKey(
      EnergyTableId,
      Energy.encodeKeyTuple(callerAddress, energyReceiverEntityId)
    );

    if (uint256(energyReceiverEntityId) == 0) {
      VoxelEntity memory newTerrainEntity = createTerrainEntity(callerAddress, energyReceiverCoord);
      energyReceiverEntityId = newTerrainEntity.entityId;
      energyReceiverEntityExists = hasKey(EnergyTableId, Energy.encodeKeyTuple(callerAddress, energyReceiverEntityId));
    }
    require(energyReceiverEntityExists, "Energy receiver entity does not exist");
    // Increase energy of energyReceiverEntity
    uint256 newReceiverEnergy = Energy.get(callerAddress, energyReceiverEntityId) + energyToTransfer;
    Energy.set(callerAddress, energyReceiverEntityId, newReceiverEnergy);
    // Decrease energy of eventEntity
    uint256 newEnergy = currentEnergy - energyToTransfer;
    Energy.set(callerAddress, entityId, newEnergy);
  }
}
