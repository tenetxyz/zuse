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
    // require(!entityExists, "Nitrogen entity already exists");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      if (entityExists) {
        return;
      }
      require(receiverNitrogenDelta > 0, "Cannot set a negative nitrogen value");
      Nitrogen.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        int256ToUint256(receiverNitrogenDelta)
      );
    } else {
      require(receiverNitrogenDelta > 0, "Cannot decrease someone's nitrogen");
      require(senderNitrogenDelta < 0, "Cannot increase your own nitrogen");
      uint256 senderNitrogen = int256ToUint256(receiverNitrogenDelta);
      uint256 receiverNitrogen = int256ToUint256(receiverNitrogenDelta);

      {
        bool receiverEntityExists = hasKey(
          MassTableId,
          Mass.encodeKeyTuple(callerAddress, receiverEntity.scale, receiverEntity.entityId)
        );
        if (!receiverEntityExists) {
          receiverEntity = createTerrainEntity(callerAddress, receiverEntity.scale, receiverCoord);
          receiverEntityExists = hasKey(
            EnergyTableId,
            Mass.encodeKeyTuple(callerAddress, receiverEntity.scale, receiverEntity.entityId)
          );
        }
        require(receiverEntityExists, "Receiver entity does not exist");
      }

      require(
        Nitrogen.get(callerAddress, senderEntity.scale, senderEntity.entityId) >= 
        Nitrogen.get(callerAddress, receiverEntity.scale, receiverEntity.entityId),
        "Nitrogen must flow from high to low concentration"
      );

      Nitrogen.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        Nitrogen.get(callerAddress, receiverEntity.scale, receiverEntity.entityId) + receiverNitrogen
      );

      Nitrogen.set(
        callerAddress,
        senderEntity.scale,
        senderEntity.entityId,
        Nitrogen.get(callerAddress, senderEntity.scale, senderEntity.entityId) - senderNitrogen
      );

    }
  }
}
