// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { SingleVoxelInteraction } from "@tenet-base-ca/src/prototypes/SingleVoxelInteraction.sol";
import { BlockDirection, BodyPhysicsData, CAEventData, CAEventType, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { EnergySource } from "@tenet-pokemon-extension/src/codegen/tables/EnergySource.sol";
import { entityIsEnergySource, entityIsSoil } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";

uint256 constant ENERGY_SOURCE_WAIT_BLOCKS = 50;

contract EnergySourceSystem is SingleVoxelInteraction {
  function runSingleInteraction(
    address callerAddress,
    bytes32 energySourceEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    changedEntity = false;
    uint256 lastInteractionBlock = EnergySource.getLastInteractionBlock(callerAddress, energySourceEntity);
    if (block.number <= lastInteractionBlock + ENERGY_SOURCE_WAIT_BLOCKS) {
      // Must wait for 50 blocks
      console.log("skipping bro")
      return (changedEntity, entityData);
    }

    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(energySourceEntity);
    console.log("entityBodyPhysics");
    console.logBytes32(energySourceEntity);
    console.logUint(entityBodyPhysics.energy);

    uint256 emittedEnergy = entityBodyPhysics.energy / 10; // Emit 10% of its energy

    // Check if the neighbor is a Soil cell
    if (entityIsSoil(callerAddress, compareEntity)) {
      // Transfer energy to Soil
      VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), compareEntity);
      console.log("flux out");
      console.logUint(emittedEnergy);
      entityData = abi.encode(transferEnergy(neighbourCoord, emittedEnergy));
      EnergySource.setLastInteractionBlock(callerAddress, energySourceEntity, block.number);
      changedEntity = true;
    }

    return (changedEntity, entityData);
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return entityIsEnergySource(callerAddress, entityId);
  }

  function eventHandlerEnergySource(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory, bytes[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
