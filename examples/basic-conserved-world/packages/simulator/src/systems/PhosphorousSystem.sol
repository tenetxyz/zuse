// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Nitrogen, NitrogenTableId, Potassium, PotassiumTableId, Phosphorous, PhosphorousTableId, SimSelectors, Object, ObjectTableId, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int256ToUint256, addUint256AndInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";
import { MAX_INIT_NPK } from "@tenet-simulator/src/Constants.sol";
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
    // require(!entityExists, "Phosphorous entity already exists");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      if (entityExists) {
        return;
      }
      require(receiverPhosphorousDelta > 0, "Cannot set a negative phosphorous value");

      uint256 senderNPK = Nitrogen.get(callerAddress, senderEntity.scale, senderEntity.entityId) +
        uint256(receiverPhosphorousDelta) +
        Potassium.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(senderNPK <= MAX_INIT_NPK, "NPK must be less than or equal to the initial NPK constant");

      Phosphorous.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        int256ToUint256(receiverPhosphorousDelta)
      );
    } else {
      require(entityExists, "Phosphorous sender entity does not exist");
      require(receiverPhosphorousDelta > 0, "Cannot decrease someone's Phosphorous");
      require(senderPhosphorousDelta < 0, "Cannot increase your own Phosphorous");
      uint256 senderPhosphorous = int256ToUint256(receiverPhosphorousDelta);
      uint256 receiverPhosphorous = int256ToUint256(receiverPhosphorousDelta);

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

      uint256 currentSenderPhosphorous = Phosphorous.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      uint256 currentReceiverPhosphorous = Phosphorous.get(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId
      );
      require(currentSenderPhosphorous >= senderPhosphorous, "Sender does not have enough phosphorous");

      require(
        currentSenderPhosphorous >= currentReceiverPhosphorous,
        "Phosphorous must flow from high to low concentration"
      );

      Phosphorous.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        currentReceiverPhosphorous + receiverPhosphorous
      );

      Phosphorous.set(
        callerAddress,
        senderEntity.scale,
        senderEntity.entityId,
        currentSenderPhosphorous - senderPhosphorous
      );
    }
  }
}
