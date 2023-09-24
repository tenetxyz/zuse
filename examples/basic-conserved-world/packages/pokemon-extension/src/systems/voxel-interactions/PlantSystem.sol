// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { SingleVoxelInteraction } from "@tenet-base-ca/src/prototypes/SingleVoxelInteraction.sol";
import { BlockDirection, BodyPhysicsData, CAEventData, CAEventType, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { EnergySource } from "@tenet-pokemon-extension/src/codegen/tables/EnergySource.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { Plant } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { entityIsEnergySource, entityIsSoil, entityIsPlant } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";

contract PlantSystem is SingleVoxelInteraction {
  function runSingleInteraction(
    address callerAddress,
    bytes32 plantEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    changedEntity = false;
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return entityIsPlant(callerAddress, entityId);
  }

  function eventHandlerPlant(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory, bytes[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
