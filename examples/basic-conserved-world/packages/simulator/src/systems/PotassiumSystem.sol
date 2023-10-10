// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Potassium, PotassiumTableId, SimSelectors, Object, ObjectTableId, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int256ToUint256, addUint256AndInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract PotassiumSystem is SimHandler {
  function registerPotassiumSelectors() public {
    SimSelectors.set(
      SimTable.Potassium,
      SimTable.Potassium,
      IWorld(_world()).updatePotassiumFromPotassium.selector,
      ValueType.Int256,
      ValueType.Int256
    );
  }

  function updatePotassiumFromPotassium(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderPotassiumDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverPotassiumDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      PotassiumTableId,
      Potassium.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    // Note: we can't have a require here because there can be duplicate events,
    // and we don't want to revert if we're just replaying events
    if (entityExists) {
      return;
    }
    // require(!entityExists, "Potassium entity already exists");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      require(receiverPotassiumDelta > 0, "Cannot set a negative potassium value");
      Potassium.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        int256ToUint256(receiverPotassiumDelta)
      );
    } else {
      revert("You can't set the object type of another entity");
    }
  }
}
