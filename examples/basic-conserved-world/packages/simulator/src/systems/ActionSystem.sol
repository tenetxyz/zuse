// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { Action, SimSelectors, Object, ObjectTableId, Health, HealthTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType, SimTable, ValueType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract ActionSystem is SimHandler {
  function registerActionSelectors() public {
    SimSelectors.set(
      SimTable.Stamina,
      SimTable.Action,
      IWorld(_world()).setActionFromStamina.selector,
      ValueType.Uint256,
      ValueType.ObjectType
    );
  }

  function setActionFromStamina(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    uint256 senderStamina,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    ObjectType receiverActionType
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      ObjectTableId,
      Action.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
    );
    if (isEntityEqual(senderEntity, receiverEntity)) {} else {}
  }
}
