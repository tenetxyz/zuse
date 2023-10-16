// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, SoilVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { EventType, SoilType } from "@tenet-pokemon-extension/src/codegen/Types.sol";

bytes32 constant SoilVoxelVariantID = bytes32(keccak256("soil"));
string constant SoilTexture = "bafkreidtk7vevmnzt6is5dreyoocjkyy56bk66zbm5bx6wzck73iogdl6e";
string constant SoilUVWrap = "bafkreiaur4pmmnh3dts6rjtfl5f2z6ykazyuu4e2cbno6drslfelkga3yy";

contract SoilVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory soilVariant;
    soilVariant.blockType = NoaBlockType.BLOCK;
    soilVariant.opaque = true;
    soilVariant.solid = true;
    string[] memory soilMaterials = new string[](1);
    soilMaterials[0] = SoilTexture;
    soilVariant.materials = abi.encode(soilMaterials);
    soilVariant.uvWrap = SoilUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, SoilVoxelVariantID, soilVariant);

    bytes32[] memory soilChildVoxelTypes = new bytes32[](1);
    soilChildVoxelTypes[0] = SoilVoxelID;
    bytes32 baseVoxelTypeId = SoilVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Soil",
      SoilVoxelID,
      baseVoxelTypeId,
      soilChildVoxelTypes,
      soilChildVoxelTypes,
      SoilVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pokemon_SoilVoxelSystem_enterWorld.selector,
        IWorld(world).pokemon_SoilVoxelSystem_exitWorld.selector,
        IWorld(world).pokemon_SoilVoxelSystem_variantSelector.selector,
        IWorld(world).pokemon_SoilVoxelSystem_activate.selector,
        IWorld(world).pokemon_SoilVoxelSystem_eventHandler.selector,
        IWorld(world).pokemon_SoilVoxelSystem_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, SoilVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    bool hasValue = true;
    Soil.set(callerAddress, entity, EventType.None, 0, SoilType.ProteinSoil, hasValue);
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
    return SoilVoxelVariantID;
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
