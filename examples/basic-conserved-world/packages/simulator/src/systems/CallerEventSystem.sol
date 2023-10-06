// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { console } from "forge-std/console.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";

contract CallerEventSystem is System {
  function onBuild(VoxelEntity memory entity, VoxelCoord memory coord, uint256 entityMass) public {
    address callerAddress = _msgSender();
  }

  function onMine(VoxelEntity memory entity, VoxelCoord memory coord) public {
    address callerAddress = _msgSender();
  }

  function onMove(
    VoxelEntity memory oldEntity,
    VoxelCoord memory oldCoord,
    VoxelEntity memory newEntity,
    VoxelCoord memory newCoord
  ) public {
    address callerAddress = _msgSender();
  }

  function onActivate(VoxelEntity memory entity, VoxelCoord memory coord) public {
    address callerAddress = _msgSender();
  }
}
