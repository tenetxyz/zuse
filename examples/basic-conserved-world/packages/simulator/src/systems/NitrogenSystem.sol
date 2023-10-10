// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Nitrogen, NitrogenTableId, SimSelectors, Object, ObjectTableId, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { int256ToUint256, addUint256AndInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract NitrogenSystem is SimHandler {
  function registerNitrogenSelectors() public {
    SimSelectors.set(
      SimTable.Nitrogen,
      SimTable.Nitrogen,
      IWorld(_world()).updateNitrogenFromNitrogen.selector,
      ValueType.Int256,
      ValueType.Int256
    );
  }

  function updateNitrogenFromNitrogen(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderNitrogenDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverNitrogenDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      NitrogenTableId,
      Nitrogen.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(!entityExists, "Nitrogen entity already exists");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      require(receiverNitrogenDelta > 0, "Cannot set a negative nitrogen value");
      Nitrogen.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        int256ToUint256(receiverNitrogenDelta)
      );
    } else {
      revert("You can't set the object type of another entity");
    }
  }
}
