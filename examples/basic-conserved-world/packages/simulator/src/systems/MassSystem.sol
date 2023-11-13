// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { SimSelectors, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { SimTable, VoxelCoord, VoxelTypeData, VoxelEntity, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract MassSystem is SimHandler {
  function registerMassSelectors() public {
    SimSelectors.set(
      SimTable.Mass,
      SimTable.Mass,
      IWorld(_world()).updateMass.selector,
      ValueType.Int256,
      ValueType.Int256
    );
  }

  function updateMass(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderMassDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverMassDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = Mass.getHasValue(callerAddress, senderEntity.scale, senderEntity.entityId);
    require(entityExists, "Sender entity does not exist");
    if (receiverMassDelta == 0) {
      return;
    }
    if (isEntityEqual(senderEntity, receiverEntity)) {
      // Transformation
      uint256 currentMass = Mass.getMass(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      uint256 newMass = addUint256AndInt256(currentMass, receiverMassDelta);
      if (currentMass > 0) {
        require(currentMass >= newMass, "Cannot increase mass");
      }
      Mass.set(callerAddress, receiverEntity.scale, receiverEntity.entityId, newMass, true);
      // Calculate how much energy this operation requires
      bool isMassIncrease = receiverMassDelta > 0; // flux in if mass increases
      uint256 energyRequired = int256ToUint256(receiverMassDelta) * 10;
      if (!isMassIncrease) {
        energyRequired = energyRequired * 2;
      }
      IWorld(_world()).fluxEnergy(isMassIncrease, callerAddress, receiverEntity, energyRequired);
    } else {
      revert("You can't transfer mass to another entity");
    }
  }
}
