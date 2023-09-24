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

uint256 constant ENERGY_SOURCE_WAIT_BLOCKS = 50;

contract SoilSystem is SingleVoxelInteraction {
  function runSingleInteraction(
    address callerAddress,
    bytes32 soilEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    changedEntity = false;
    uint256 lastEnergy = Soil.getLastEnergy(callerAddress, soilEntity);
    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(soilEntity);
    if (lastEnergy == entityBodyPhysics.energy) {
      // No energy change
      return (changedEntity, entityData);
    }
    Soil.setLastEnergy(callerAddress, soilEntity, entityBodyPhysics.energy);

    uint256 transferEnergyToSoil = entityBodyPhysics.energy / 5; // Transfer 20% of its energy to Soil
    uint256 transferEnergyToPlant = entityBodyPhysics.energy / 10; // Transfer 10% of its energy to Seed or Young Plant

    VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), compareEntity);

    // Check if the neighbor is a Soil, Seed, or Young Plant cell
    if (entityIsSoil(callerAddress, compareEntity)) {
      // Transfer more energy to neighboring Soil
      entityData = abi.encode(transferEnergy(neighbourCoord, transferEnergyToSoil));
    } else if (entityIsPlant(callerAddress, compareEntity) && compareBlockDirection == BlockDirection.Up) {
      PlantStage plantStage = Plant.getStage(callerAddress, compareEntity);
      if (plantStage == PlantStage.Seed || plantStage == PlantStage.Sprout) {
        // Transfer less energy to Seed or Young Plant only if they are on top
        entityData = abi.encode(transferEnergy(neighbourCoord, transferEnergyToPlant));
      }
    }
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return entityIsSoil(callerAddress, entityId);
  }

  function eventHandlerSoil(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory, bytes[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
