// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level3-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, RoadVoxelID } from "@tenet-level3-ca/src/Constants.sol";
import { DirtVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RoadVoxelVariantID = bytes32(keccak256("road"));

string constant RoadTexture = "bafkreiaavptzcmkl6xdyqk6ivp75ehsx45yl6kgxnahumozfbur6z6xcni";
string constant RoadUVWrap = "bafkreihibx43dpw57halle4yfzidfrclm35xlyoiko3kq3m2uh5mewnmyu";

contract RoadVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory roadVariant;
    roadVariant.blockType = NoaBlockType.BLOCK;
    roadVariant.opaque = true;
    roadVariant.solid = true;
    string[] memory roadMaterials = new string[](1);
    roadMaterials[0] = RoadTexture;
    roadVariant.materials = abi.encode(roadMaterials);
    roadVariant.uvWrap = RoadUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, RoadVoxelVariantID, roadVariant);

    bytes32[] memory roadChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      roadChildVoxelTypes[i] = DirtVoxelID;
    }
    bytes32 baseVoxelTypeId = RoadVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Road",
      RoadVoxelID,
      baseVoxelTypeId,
      roadChildVoxelTypes,
      roadChildVoxelTypes,
      RoadVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).ca_RoadVoxelSystem_enterWorld.selector,
        IWorld(world).ca_RoadVoxelSystem_exitWorld.selector,
        IWorld(world).ca_RoadVoxelSystem_variantSelector.selector,
        IWorld(world).ca_RoadVoxelSystem_activate.selector,
        IWorld(world).ca_RoadVoxelSystem_eventHandler.selector
      ),
      abi.encode(componentDefs)
    );
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RoadVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory, bytes[] memory) {}
}
