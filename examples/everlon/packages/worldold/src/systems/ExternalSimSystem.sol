// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord, VoxelEntity, InteractionSelector } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { OwnedBy, Position, VoxelType } from "@tenet-world/src/codegen/Tables.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { WorldConfig, WorldConfigTableId } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { initEntity, initAgent } from "@tenet-simulator/src/CallUtils.sol";
import { getInteractionSelectors } from "@tenet-registry/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract ExternalSimSystem is System {
  function createTerrainEntity(uint32 scale, VoxelCoord memory coord) public returns (VoxelEntity memory) {
    address callerAddress = _msgSender();
    require(
      callerAddress == SIMULATOR_ADDRESS || callerAddress == _world(),
      "Only simulator can create terrain entities"
    );
    bytes32 terrainVoxelTypeId = IWorld(_world()).getTerrainVoxel(coord);
    uint256 initMass = IWorld(_world()).getTerrainMass(scale, coord);
    uint256 initEnergy = IWorld(_world()).getTerrainEnergy(scale, coord);
    VoxelCoord memory initVelocity = IWorld(_world()).getTerrainVelocity(scale, coord);
    return spawnBody(terrainVoxelTypeId, coord, bytes4(0), initMass, initEnergy, initVelocity, 0, 0);
  }

  function spawnBody(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes4 mindSelector,
    uint256 initMass,
    uint256 initEnergy,
    VoxelCoord memory initVelocity,
    uint256 initStamina,
    uint256 initHealth
  ) public returns (VoxelEntity memory eventVoxelEntity) {
    require(
      _msgSender() == SIMULATOR_ADDRESS ||
        _msgSender() == _world() ||
        _msgSender() == 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, // TODO: find a better way to figure out world deployer
      "Not approved to spawn bodies"
    );

    address caAddress = WorldConfig.get(voxelTypeId);
    // Create new body entity
    eventVoxelEntity = VoxelEntity({
      scale: VoxelTypeRegistry.getScale(IStore(REGISTRY_ADDRESS), voxelTypeId),
      entityId: getUniqueEntity()
    });
    Position.set(eventVoxelEntity.scale, eventVoxelEntity.entityId, coord.x, coord.y, coord.z);

    // Update layers
    IWorld(_world()).enterCA(caAddress, eventVoxelEntity, voxelTypeId, mindSelector, coord);
    {
      CAVoxelTypeData memory entityCAVoxelType = CAVoxelType.get(
        IStore(caAddress),
        _world(),
        eventVoxelEntity.entityId
      );
      VoxelType.set(
        eventVoxelEntity.scale,
        eventVoxelEntity.entityId,
        entityCAVoxelType.voxelTypeId,
        entityCAVoxelType.voxelVariantId
      );
    }
    // TODO: Should we run this?
    // IWorld(_world()).runCA(caAddress, eventVoxelEntity, bytes4(0));

    initEntity(SIMULATOR_ADDRESS, eventVoxelEntity, initMass, initEnergy, initVelocity);
    {
      InteractionSelector[] memory interactionSelectors = getInteractionSelectors(
        IStore(REGISTRY_ADDRESS),
        voxelTypeId
      );
      if (interactionSelectors.length > 1) {
        initAgent(SIMULATOR_ADDRESS, eventVoxelEntity, initStamina, initHealth);
      }
    }

    return eventVoxelEntity;
  }
}