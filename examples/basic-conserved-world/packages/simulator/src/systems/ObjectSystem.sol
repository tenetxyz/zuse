// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Object, ObjectTableId, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract ObjectSystem is SimHandler {
  function setObjectType(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    ObjectType senderObjectType,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    ObjectType receiverObjectType
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      ObjectTableId,
      Object.encodeKeyTuple(callerAddress, receiverEntity.scale, receiverEntity.entityId)
    );
    require(!entityExists, "Object type already set");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      Object.set(callerAddress, receiverEntity.scale, receiverEntity.entityId, receiverObjectType);
    } else {
      revert("You can't set the object type of another entity");
    }
  }
}
