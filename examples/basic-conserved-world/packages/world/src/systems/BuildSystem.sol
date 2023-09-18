// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { BuildEvent } from "@tenet-base-world/src/prototypes/BuildEvent.sol";
import { BuildEventData } from "@tenet-base-world/src/Types.sol";
import { OwnedBy, VoxelType, VoxelTypeProperties, BodyPhysics } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { min } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { BuildWorldEventData } from "@tenet-world/src/Types.sol";

uint256 constant MAXIMUM_ENERGY_OUT = 100;

contract BuildSystem is BuildEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function emptyVoxelId() internal pure override returns (bytes32) {
    return AirVoxelID;
  }

  // Called by users
  function buildWithAgent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory agentEntity,
    bytes4 mindSelector
  ) public returns (VoxelEntity memory) {
    BuildWorldEventData memory buildEventData = BuildWorldEventData({ agentEntity: agentEntity });
    return
      build(
        voxelTypeId,
        coord,
        abi.encode(BuildEventData({ mindSelector: mindSelector, worldData: abi.encode(buildEventData) }))
      );
  }

  function postEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal override {
    // Update the mass of the entity to be the type definition's mass
    uint256 bodyMass = VoxelTypeProperties.get(voxelTypeId);
    uint32 scale = eventVoxelEntity.scale;
    BodyPhysics.setMass(scale, eventVoxelEntity.entityId, bodyMass);
    // Calculate how much energy this operation requires
    uint256 energyToDissipate = bodyMass * 100;
    // Go through all the neighbours and equally take from each one, up till MAXIMUM_ENERGY_IN
    // if it runs out, go to the next set of neighbours, another radius away
    uint8 radius = 1;
    // dissipate energy
    while (energyToDissipate > 0) {
      if (radius > 255) {
        revert("Ran out of neighbours to dissipate energy into");
      }
      bytes32[] memory useNeighbourEntities = IWorld(_world()).calculateMooreNeighbourEntities(
        eventVoxelEntity,
        radius
      );
      uint256 numNeighboursWithValues = 0;

      for (uint256 i = 0; i < useNeighbourEntities.length; i++) {
        if (useNeighbourEntities[i] != bytes32(0) && BodyPhysics.getEnergy(scale, useNeighbourEntities[i]) > 0) {
          numNeighboursWithValues++;
        }
      }

      if (numNeighboursWithValues == 0) {
        radius += 1;
        continue;
      }

      // Calculate the average amount of energy to give to each neighbor
      // TODO: This should be based on gravity, not just a flat amount
      uint energyPerNeighbor = energyToDissipate / numNeighboursWithValues;

      for (uint i = 0; i < useNeighbourEntities.length; i++) {
        bytes32 neighborEntity = useNeighbourEntities[i];
        uint256 neighbourEnergy = BodyPhysics.getEnergy(scale, neighborEntity);
        if (neighborEntity == bytes32(0) || neighbourEnergy == 0) {
          continue;
        }

        uint256 energyToTake = min(energyPerNeighbor, MAXIMUM_ENERGY_OUT);
        if (neighbourEnergy < energyToTake) {
          energyToTake = neighbourEnergy;
        }

        // Transfer the energy
        BodyPhysics.setEnergy(scale, neighborEntity, neighbourEnergy - energyToTake);

        // Decrease the amount of energy left to dissipate
        energyToDissipate -= energyToTake;

        // If we have successfully dissipated all energy, exit the loop
        if (energyToDissipate == 0) {
          break;
        }
      }

      // If we've gone through all neighbors and still have energy to dissipate, increase the radius
      if (energyToDissipate > 0) {
        radius += 1;
      }
    }
  }
}
