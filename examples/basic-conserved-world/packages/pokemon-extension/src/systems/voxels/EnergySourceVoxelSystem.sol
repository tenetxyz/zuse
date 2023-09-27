// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, EnergySourceVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { EnergySource } from "@tenet-pokemon-extension/src/codegen/tables/EnergySource.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant EnergySourceVoxelVariantID = bytes32(keccak256("energysource"));
string constant EnergySourceTexture = "bafkreidtk7vevmnzt6is5dreyoocjkyy56bk66zbm5bx6wzck73iogdl6e";
string constant EnergySourceUVWrap = "bafkreiaur4pmmnh3dts6rjtfl5f2z6ykazyuu4e2cbno6drslfelkga3yy";

contract EnergySourceVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory energySourceVariant;
    energySourceVariant.blockType = NoaBlockType.BLOCK;
    energySourceVariant.opaque = true;
    energySourceVariant.solid = true;
    string[] memory energySourceMaterials = new string[](1);
    energySourceMaterials[0] = EnergySourceTexture;
    energySourceVariant.materials = abi.encode(energySourceMaterials);
    energySourceVariant.uvWrap = EnergySourceUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, EnergySourceVoxelVariantID, energySourceVariant);

    bytes32[] memory energySourceChildVoxelTypes = new bytes32[](1);
    energySourceChildVoxelTypes[0] = EnergySourceVoxelID;
    bytes32 baseVoxelTypeId = EnergySourceVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Energy Source",
      EnergySourceVoxelID,
      baseVoxelTypeId,
      energySourceChildVoxelTypes,
      energySourceChildVoxelTypes,
      EnergySourceVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pokemon_EnergySourceVoxe_enterWorld.selector,
        IWorld(world).pokemon_EnergySourceVoxe_exitWorld.selector,
        IWorld(world).pokemon_EnergySourceVoxe_variantSelector.selector,
        IWorld(world).pokemon_EnergySourceVoxe_activate.selector,
        IWorld(world).pokemon_EnergySourceVoxe_eventHandler.selector
      ),
      abi.encode(componentDefs)
    );

    registerCAVoxelType(CA_ADDRESS, EnergySourceVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    bool hasValue = true;
    EnergySource.set(callerAddress, entity, 0, 0, hasValue);
  }

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    EnergySource.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return EnergySourceVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory, bytes[] memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_EnergySourceSyst_eventHandlerEnergySource(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }
}
