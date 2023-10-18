// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, BodySimData } from "@tenet-utils/src/Types.sol";
import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeTableId } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { WORLD_ADDRESS, BASE_CA_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { getEntitySimData } from "@tenet-world/src/CallUtils.sol";
import { getEntityAtCoord, getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";
import { getNeighbourEntities } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { Pokemon, PokemonData } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { Plant, PlantData, PlantStage } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";

contract DerivedSystem is System {
  function deriveState(VoxelEntity memory entity, VoxelCoord memory coord) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);
    console.log("deriveState");

    // Core world data
    bytes32 voxelTypeId = VoxelType.getVoxelTypeId(worldStore, entity.scale, entity.entityId);
    bytes32 entityId = getEntityAtCoord(worldStore, 1, coord);
    VoxelCoord memory entityCoord = getVoxelCoordStrict(worldStore, entity);
    (bytes32[] memory neighbourEntities, ) = getNeighbourEntities(WORLD_ADDRESS, entity);
    console.logBytes32(voxelTypeId);
    console.logBytes32(entityId);
    console.logUint(neighbourEntities.length);

    // Simulator data
    BodySimData memory simData = getEntitySimData(WORLD_ADDRESS, entity);
    console.logUint(simData.mass);

    // CA data
    bytes32 caEntity = CAEntityMapping.get(caStore, WORLD_ADDRESS, entity.entityId);
    PlantData memory plantData = Plant.get(caStore, WORLD_ADDRESS, caEntity);
    console.logUint(plantData.lastInteractionBlock);
    PokemonData memory pokemonData = Pokemon.get(caStore, WORLD_ADDRESS, caEntity);
    console.logUint(uint(pokemonData.pokemonType));
  }
}
