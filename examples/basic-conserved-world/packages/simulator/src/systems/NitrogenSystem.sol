// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Nitrogen, NitrogenTableId, Potassium, PotassiumTableId, Phosphorous, PhosphorousTableId, SimSelectors, Object, ObjectTableId, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { int256ToUint256, addUint256AndInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";
import { MAX_INIT_NPK } from "@tenet-simulator/src/Constants.sol";
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
      require(receiverNitrogenDelta >= 0, "Cannot set a negative nitrogen value");

      uint256 senderNPK = Potassium.get(callerAddress, senderEntity.scale, senderEntity.entityId) +
        uint256(receiverNitrogenDelta) +
        Phosphorous.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(senderNPK <= MAX_INIT_NPK, "NPK must be less than or equal to the initial NPK constant");

      Nitrogen.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        int256ToUint256(receiverNitrogenDelta)
      );
    } else {
      require(entityExists, "Nitrogen sender entity does not exist");
      require(receiverNitrogenDelta > 0, "Cannot decrease someone's nitrogen");
      require(senderNitrogenDelta < 0, "Cannot increase your own nitrogen");
      uint256 senderNitrogen = int256ToUint256(receiverNitrogenDelta);
      uint256 receiverNitrogen = int256ToUint256(receiverNitrogenDelta);

      {
        bool receiverEntityExists = Mass.getHasValue(callerAddress, receiverEntity.scale, receiverEntity.entityId);
        if (!receiverEntityExists) {
          receiverEntity = createTerrainEntity(callerAddress, receiverEntity.scale, receiverCoord);
          receiverEntityExists = hasKey(
            EnergyTableId,
            Mass.encodeKeyTuple(callerAddress, receiverEntity.scale, receiverEntity.entityId)
          );
        }
        require(receiverEntityExists, "Receiver entity does not exist");
      }

      uint256 currentSenderNitrogen = Nitrogen.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      uint256 currentReceiverNitrogen = Nitrogen.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      require(currentSenderNitrogen >= senderNitrogen, "Sender does not have enough nitrogen");

      require(currentSenderNitrogen >= currentReceiverNitrogen, "Nitrogen must flow from high to low concentration");

      Nitrogen.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        currentReceiverNitrogen + receiverNitrogen
      );

      Nitrogen.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentSenderNitrogen - senderNitrogen);
    }
  }
}
