// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, PlantVoxelID, SeedVoxelVariantID, SproutVoxelVariantID, FlowerVoxelVariantID } from "@tenet-pokemon-extension/src/Constants.sol";
import { Plant, PlantData } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { VoxelCoord, ComponentDef, BodySimData } from "@tenet-utils/src/Types.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { EventType } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { getEntitySimData, transfer } from "@tenet-level1-ca/src/Utils.sol";

string constant PlantTexture = "bafkreidtk7vevmnzt6is5dreyoocjkyy56bk66zbm5bx6wzck73iogdl6e";
string constant PlantUVWrap = "bafkreiaur4pmmnh3dts6rjtfl5f2z6ykazyuu4e2cbno6drslfelkga3yy";

contract PlantVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory plantVariant;
    plantVariant.blockType = NoaBlockType.BLOCK;
    plantVariant.opaque = true;
    plantVariant.solid = true;
    string[] memory plantMaterials = new string[](1);
    plantMaterials[0] = PlantTexture;
    plantVariant.materials = abi.encode(plantMaterials);
    plantVariant.uvWrap = PlantUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, SeedVoxelVariantID, plantVariant);
    registerVoxelVariant(REGISTRY_ADDRESS, SproutVoxelVariantID, plantVariant);
    registerVoxelVariant(REGISTRY_ADDRESS, FlowerVoxelVariantID, plantVariant);

    bytes32[] memory plantChildVoxelTypes = new bytes32[](1);
    plantChildVoxelTypes[0] = PlantVoxelID;
    bytes32 baseVoxelTypeId = PlantVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Plant",
      PlantVoxelID,
      baseVoxelTypeId,
      plantChildVoxelTypes,
      plantChildVoxelTypes,
      SeedVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pokemon_PlantVoxelSystem_enterWorld.selector,
        IWorld(world).pokemon_PlantVoxelSystem_exitWorld.selector,
        IWorld(world).pokemon_PlantVoxelSystem_variantSelector.selector,
        IWorld(world).pokemon_PlantVoxelSystem_activate.selector,
        IWorld(world).pokemon_PlantVoxelSystem_eventHandler.selector,
        IWorld(world).pokemon_PlantVoxelSystem_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      10
    );

    registerCAVoxelType(CA_ADDRESS, PlantVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    bool hasValue = true;
    Plant.set(callerAddress, entity, PlantStage.Seed, EventType.None, 0, hasValue);
  }

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Plant.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    address callerAddress = super.getCallerAddress();
    PlantData memory plantData = Plant.get(callerAddress, entity);
    // PlantStage plantStage = Plant.getStage(callerAddress, entity);
    BodySimData memory entitySimData = getEntitySimData(entity);
    if (entitySimData.elixir == 0 && entitySimData.protein == 0) {
      return SeedVoxelVariantID;
    } else if (entitySimData.protein > 0) {
      return SproutVoxelVariantID;
    } else {
      return FlowerVoxelVariantID;
    }
    // if (plantStage == PlantStage.Seed) {
    //   return SeedVoxelVariantID;
    // } else if (plantStage == PlantStage.Sprout) {
    //   return SproutVoxelVariantID;
    // } else if (plantStage == PlantStage.Flower) {
    //   return FlowerVoxelVariantID;
    // }
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
      IWorld(_world()).pokemon_PlantSystem_eventHandlerPlant(
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
      IWorld(_world()).pokemon_PlantSystem_neighbourEventHandlerPlant(callerAddress, neighbourEntityId, centerEntityId);
  }
}
