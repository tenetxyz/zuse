// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Nitrogen, NitrogenTableId, Phosphorous, PhosphorousTableId, Potassium, PotassiumTableId, SimSelectors, Object, ObjectTableId, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int256ToUint256, addUint256AndInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";
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
    // require(!entityExists, "Potassium entity already exists");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      if (entityExists) {
        return;
      }
      require(receiverPotassiumDelta > 0, "Cannot set a negative potassium value");


      uint256 senderNPK = Nitrogen.get(callerAddress, senderEntity.scale, senderEntity.entityId)
      + uint256(receiverPotassiumDelta) + Phosphorous.get(callerAddress, senderEntity.scale, senderEntity.entityId);

      require(senderNPK <= 100);

      Potassium.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        int256ToUint256(receiverPotassiumDelta)
      );
    } else {
      require(entityExists, "Potassium sender entity does not exist");
      require(receiverPotassiumDelta > 0, "Cannot decrease someone's Potassium");
      require(senderPotassiumDelta < 0, "Cannot increase your own Potassium");
      uint256 senderPotassium = int256ToUint256(receiverPotassiumDelta);
      uint256 receiverPotassium = int256ToUint256(receiverPotassiumDelta);

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

      uint256 currentSenderPotassium = Potassium.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      uint256 currentReceiverPotassium = Potassium.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      require(currentSenderPotassium >= senderPotassium, "Sender does not have enough nitrogen");

      require(currentSenderPotassium >= currentReceiverPotassium, "Potassium must flow from high to low concentration");

      Potassium.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        currentReceiverPotassium + receiverPotassium
      );

      Potassium.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentSenderPotassium - senderPotassium);
    }
  }
}
