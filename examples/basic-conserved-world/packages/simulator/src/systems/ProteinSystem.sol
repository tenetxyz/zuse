// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Protein, ProteinTableId, Elixir, ElixirTableId, Nutrients, NutrientsTableId, SimSelectors, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract ProteinSystem is SimHandler {
  function registerProteinSelectors() public {
    SimSelectors.set(
      SimTable.Nutrients,
      SimTable.Protein,
      IWorld(_world()).updateProteinFromNutrients.selector,
      ValueType.Int256,
      ValueType.Int256
    );
  }

  function updateProteinFromNutrients(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderNutrientsDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    int256 receiverProteinDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      NutrientsTableId,
      Nutrients.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    require(entityExists, "Sender entity does not exist");
    if (isEntityEqual(senderEntity, receiverEntity)) {
      revert("You can't convert your own nutrients to protein");
    } else {
      require(receiverProteinDelta > 0, "Cannot decrease someone's protein");
      require(senderNutrientsDelta < 0, "Cannot increase your own nutrients");
      uint256 senderNutrients = int256ToUint256(senderNutrientsDelta);
      uint256 receiverProtein = int256ToUint256(receiverProteinDelta);
      // TODO: Use NPK to figure out how much nutrients to convert, right now it's 1:1
      require(senderNutrients == receiverProtein, "Sender nutrients must equal receiver protein");
      uint256 currentSenderNutrients = Nutrients.get(callerAddress, senderEntity.scale, senderEntity.entityId);
      require(currentSenderNutrients >= senderNutrients, "Not enough nutrients to transfer");
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
      uint256 currentReceiverProtein = Protein.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      Protein.set(
        callerAddress,
        receiverEntity.scale,
        receiverEntity.entityId,
        currentReceiverProtein + receiverProtein
      );
      Nutrients.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentSenderNutrients - senderNutrients);
    }
  }
}
