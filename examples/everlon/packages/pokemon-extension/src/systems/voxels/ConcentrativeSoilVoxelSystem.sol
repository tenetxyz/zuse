// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, ConcentrativeSoilVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { EventType, SoilType } from "@tenet-pokemon-extension/src/codegen/Types.sol";

bytes32 constant ConcentrativeSoilVoxelVariantID = bytes32(keccak256("soil-concentrative"));

contract ConcentrativeSoilVoxelSystem is VoxelType {
  function registerObject() public override {
    address world = _world();
    VoxelVariantsRegistryData memory soilVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, ConcentrativeSoilVoxelVariantID, soilVariant);

    bytes32[] memory soilChildVoxelTypes = new bytes32[](1);
    soilChildVoxelTypes[0] = ConcentrativeSoilVoxelID;
    bytes32 baseVoxelTypeId = ConcentrativeSoilVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Concentrative Soil",
      ConcentrativeSoilVoxelID,
      baseVoxelTypeId,
      soilChildVoxelTypes,
      soilChildVoxelTypes,
      ConcentrativeSoilVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pokemon_ConcentrativeSoi_enterWorld.selector,
        IWorld(world).pokemon_ConcentrativeSoi_exitWorld.selector,
        IWorld(world).pokemon_ConcentrativeSoi_variantSelector.selector,
        IWorld(world).pokemon_ConcentrativeSoi_activate.selector,
        IWorld(world).pokemon_ConcentrativeSoi_eventHandler.selector,
        IWorld(world).pokemon_ConcentrativeSoi_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, ConcentrativeSoilVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    bool hasValue = true;
    Soil.set(callerAddress, entity, EventType.None, 0, SoilType.Concentrative, hasValue);
  }

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Soil.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ConcentrativeSoilVoxelVariantID;
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
      IWorld(_world()).pokemon_SoilSystem_eventHandlerSoil(
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
      IWorld(_world()).pokemon_SoilSystem_neighbourEventHandlerSoil(callerAddress, neighbourEntityId, centerEntityId);
  }
}
