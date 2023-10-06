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
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";

contract MassSystem is System {
  function setMass(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    uint256 senderMass,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    uint256 receiverMass
  ) public {
    address callerAddress = _msgSender();
    bool entityExists = hasKey(
      MassTableId,
      Mass.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Sender entity does not exist");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      // Transformation
      uint256 currentMass = Mass.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      bool isMassIncrease = currentMass < receiverMass; // flux in if mass increases
      uint256 massDelta = massChange(receiverEntity, receiverCoord, receiverMass);
      // Calculate how much energy this operation requires
      uint256 energyRequired = massDelta * 10;
      IWorld(_world()).fluxEnergy(isMassIncrease, callerAddress, receiverEntity, energyRequired);
    } else {
      revert("You can't transfer mass to another entity");
    }
  }

  function massChange(
    address callerAddress,
    bool entityExists,
    VoxelEntity memory entity,
    VoxelCoord memory coord,
    uint256 newMass
  ) internal returns (uint256 massDelta) {
    if (newMass > 0) {
      // this is a build event
      bool isBuild = false;
      uint256 currentMass = Mass.get(callerAddress, entity.scale, entity.entityId);
      if (entityExists) {
        if (currentMass == 0) {
          isBuild = true;
          massChange = newMass;
        } else {
          // Note: we only allow mass to decrease
          require(currentMass >= newMass, "Cannot increase mass");
          massChange = currentMass - newMass;
        }
      } else {
        uint256 terrainMass = getTerrainMass(callerAddress, entity.scale, coord);
        require(terrainMass == 0 || terrainMass == newMass, "Invalid terrain mass");
        isBuild = true;
        Mass.set(callerAddress, entity.scale, entity.entityId, terrainMass);
        Energy.set(callerAddress, entity.scale, entity.entityId, getTerrainEnergy(callerAddress, entity.scale, coord));
        Velocity.set(
          callerAddress,
          entity.scale,
          entity.entityId,
          block.number,
          abi.encode(getTerrainVelocity(callerAddress, entity.scale, coord))
        );

        massChange = terrainMass;
      }
    } else {
      // this is a mine event
      uint256 massToMine;
      if (entityExists) {
        require(isZeroCoord(getVelocity(callerAddress, entity)), "Cannot mine an entity with velocity");
        massToMine = Mass.get(callerAddress, entity.scale, entity.entityId);
        require(massToMine > 0, "Cannot mine an entity with no mass");
      } else {
        VoxelCoord memory terrainVelocity = getTerrainVelocity(callerAddress, entity.scale, coord);
        uint256 terrainMass = getTerrainMass(callerAddress, entity.scale, coord);
        massToMine = terrainMass;
        require(isZeroCoord(terrainVelocity), "Cannot mine terrain with velocity");
        require(terrainMass > 0, "Cannot mine terrain with no mass");

        Mass.set(callerAddress, entity.scale, entity.entityId, terrainMass);
        Energy.set(callerAddress, entity.scale, entity.entityId, getTerrainEnergy(callerAddress, entity.scale, coord));
        Velocity.set(callerAddress, entity.scale, entity.entityId, block.number, abi.encode(terrainVelocity));
      }

      massChange = massToMine;
    }

    Mass.set(callerAddress, entity.scale, entity.entityId, newMass);
    return massChange;
  }
}
