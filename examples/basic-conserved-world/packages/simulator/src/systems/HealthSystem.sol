// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { SimSelectors, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract HealthSystem is SimHandler {
  function registerHealthSelectors() public {
    SimSelectors.set(
      SimTable.Energy,
      SimTable.Health,
      IWorld(_world()).updateHealthFromEnergy.selector,
      ValueType.Int256,
      ValueType.Int256
    );
  }

  function updateHealthFromEnergy(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderEnergyDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverHealthDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      EnergyTableId,
      Energy.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Sender entity does not exist");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      revert("You can't convert your own energy to health");
    } else {
      require(receiverHealthDelta > 0, "Cannot decrease others health");
      require(senderEnergyDelta < 0, "Cannot increase your own energy");
      uint256 senderEnergy = int256ToUint256(senderEnergyDelta);
      uint256 receiverHealth = int256ToUint256(receiverHealthDelta);
      require(senderEnergy == receiverHealth, "Sender energy must equal receiver health");
      uint256 currentSenderEnergy = Energy.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentSenderEnergy >= senderEnergy, "Sender does not have enough energy");
      Energy.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentSenderEnergy - senderEnergy);
      uint256 currentReceiverHealth = Health.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      Health.set(callerAddress, receiverEntity.scale, receiverEntity.entityId, currentReceiverHealth + receiverHealth);
    }
  }
}
