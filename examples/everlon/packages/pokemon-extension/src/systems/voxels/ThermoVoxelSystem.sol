// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, ThermoVoxelID, PlantSeedVoxelVariantID, PlantProteinVoxelVariantID, PlantElixirVoxelVariantID, PlantFlowerVoxelVariantID } from "@tenet-pokemon-extension/src/Constants.sol";
import { Plant, PlantData } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { Thermo, ThermoData } from "@tenet-pokemon-extension/src/codegen/tables/Thermo.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { VoxelCoord, ComponentDef, BodySimData } from "@tenet-utils/src/Types.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { EventType } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { getEntitySimData, transfer } from "@tenet-level1-ca/src/Utils.sol";
import { PlantConsumer } from "@tenet-pokemon-extension/src/Types.sol";

bytes32 constant ThermoColdVoxelVariantID = bytes32(keccak256("thermo-cold"));
bytes32 constant ThermoHotVoxelVariantID = bytes32(keccak256("thermo-hot"));

contract ThermoVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory thermoVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, ThermoColdVoxelVariantID, thermoVariant);
    registerVoxelVariant(REGISTRY_ADDRESS, ThermoHotVoxelVariantID, thermoVariant);

    bytes32[] memory thermoChildVoxelTypes = new bytes32[](1);
    thermoChildVoxelTypes[0] = ThermoVoxelID;
    bytes32 baseVoxelTypeId = ThermoVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Thermo",
      ThermoVoxelID,
      baseVoxelTypeId,
      thermoChildVoxelTypes,
      thermoChildVoxelTypes,
      ThermoHotVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pokemon_ThermoVoxelSyste_enterWorld.selector,
        IWorld(world).pokemon_ThermoVoxelSyste_exitWorld.selector,
        IWorld(world).pokemon_ThermoVoxelSyste_variantSelector.selector,
        IWorld(world).pokemon_ThermoVoxelSyste_activate.selector,
        IWorld(world).pokemon_ThermoVoxelSyste_eventHandler.selector,
        IWorld(world).pokemon_ThermoVoxelSyste_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      10
    );

    registerCAVoxelType(CA_ADDRESS, ThermoVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Thermo.set(
      callerAddress,
      entity,
      ThermoData({ lastEvent: EventType.None, lastInteractionBlock: 0, hasValue: true })
    );
  }

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Thermo.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    address callerAddress = super.getCallerAddress();
    BodySimData memory entitySimData = getEntitySimData(entity);
    if (entitySimData.temperature > 0) {
      return ThermoHotVoxelVariantID;
    } else {
      return ThermoColdVoxelVariantID;
    }
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_ThermoSystem_eventHandlerThermo(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_ThermoSystem_neighbourEventHandlerThermo(
        callerAddress,
        neighbourEntityId,
        centerEntityId
      );
  }
}
