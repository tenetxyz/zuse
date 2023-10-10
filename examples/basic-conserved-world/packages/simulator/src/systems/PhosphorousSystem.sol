// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Phosphorous, PhosphorousTableId, SimSelectors, Object, ObjectTableId, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int256ToUint256, addUint256AndInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract PhosphorousSystem is SimHandler {
  function registerPhosphorousSelectors() public {
    SimSelectors.set(
      SimTable.Phosphorous,
      SimTable.Phosphorous,
      IWorld(_world()).updatePhosphorousFromPhosphorous.selector,
      ValueType.Int256,
      ValueType.Int256
    );
  }

  function updatePhosphorousFromPhosphorous(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderPhosphorousDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverPhosphorousDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      PhosphorousTableId,
      Phosphorous.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(!entityExists, "Phosphorous entity already exists");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      require(receiverPhosphorousDelta > 0, "Cannot set a negative phosphorous value");
      Phosphorous.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        int256ToUint256(receiverPhosphorousDelta)
      );
    } else {
      revert("You can't set the object type of another entity");
    }
  }
}
