// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { hasEntity, addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { callOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { CAMind } from "@tenet-base-ca/src/codegen/tables/CAMind.sol";
import { KeysInTable } from "@latticexyz/world/src/modules/keysintable/tables/KeysInTable.sol";
import { Interactions, InteractionsTableId } from "@tenet-base-world/src/codegen/tables/Interactions.sol";
import { MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH, MAX_UNIQUE_ENTITY_INTERACTIONS_RUN, MAX_SAME_VOXEL_INTERACTION_RUN } from "@tenet-utils/src/Constants.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeData, VoxelTypeTableId } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { WorldConfig } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
import { runInteraction, enterWorld, exitWorld, activateVoxel, moveLayer } from "@tenet-base-ca/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityAtCoord, calculateChildCoords, calculateParentCoord } from "@tenet-base-world/src/Utils.sol";
import { getVonNeumannNeighbours, getMooreNeighbours } from "@tenet-utils/src/VoxelCoordUtils.sol";

abstract contract TerrainSystem is System {
  function emptyObjectId() internal pure virtual returns (bytes32);

  function getTerrainObjectTypeId(VoxelCoord memory coord) public virtual returns (bytes32);

  function getTerrainObjectProperties(
    ObjectProperties memory requestedProperties
  ) public virtual returns (ObjectProperties memory);

  function createTerrainEntity(bytes32 objectTypeId, VoxelCoord memory coord) public returns (bytes32, bytes32) {
    // TODO: require caller can only be world or sim
    bytes32 terrainObjectTypeId = getTerrainObjectTypeId(coord);
    require(
      terrainObjectTypeId == emptyVoxelId() || terrainObjectTypeId == objectTypeId,
      "Invalid object type id on createTerrainEntity"
    );
    bytes32 newEntityId = getUniqueEntity();
    Position.set(newEntityId, coord.x, coord.y, coord.z);
    bytes32 newObjectEntityId = getUniqueEntity();
    ObjectEntity.set(newEntityId, newObjectEntityId);

    ObjectProperties memory requestedProperties = IWorld(_world()).enterWorld(objectTypeId, coord, newObjectEntityId);
    ObjectProperties memory properties = getTerrainObjectProperties(requestedProperties);
    // Set voxel type
    // initEntity(SIMULATOR_ADDRESS, eventVoxelEntity, initMass, initEnergy, initVelocity);
    // {
    //   InteractionSelector[] memory interactionSelectors = getInteractionSelectors(
    //     IStore(REGISTRY_ADDRESS),
    //     voxelTypeId
    //   );
    //   if (interactionSelectors.length > 1) {
    //     initAgent(SIMULATOR_ADDRESS, eventVoxelEntity, initStamina, initHealth);
    //   }
    // }
    return (newEntityId, newObjectEntityId);
  }
}
