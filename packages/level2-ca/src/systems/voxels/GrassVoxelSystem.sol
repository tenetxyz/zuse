// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, GrassVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { DirtTexture } from "@tenet-level2-ca/src/systems/voxels/DirtVoxelSystem.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant GrassVoxelVariantID = bytes32(keccak256("grass"));
string constant GrassTexture = "bafkreidtk7vevmnzt6is5dreyoocjkyy56bk66zbm5bx6wzck73iogdl6e";
string constant GrassSideTexture = "bafkreien7wqwfkckd56rehamo2riwwy5jvecm5he6dmbw2lucvh3n4w6ue";
string constant GrassUVWrap = "bafkreiaur4pmmnh3dts6rjtfl5f2z6ykazyuu4e2cbno6drslfelkga3yy";

contract GrassVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();
    VoxelVariantsRegistryData memory grassVariant;
    grassVariant.blockType = NoaBlockType.BLOCK;
    grassVariant.opaque = true;
    grassVariant.solid = true;
    string[] memory grassMaterials = new string[](3);
    grassMaterials[0] = GrassTexture;
    grassMaterials[1] = DirtTexture;
    grassMaterials[2] = GrassSideTexture;
    grassVariant.materials = abi.encode(grassMaterials);
    grassVariant.uvWrap = GrassUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, GrassVoxelVariantID, grassVariant);

    bytes32[] memory grassChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      grassChildVoxelTypes[i] = AirVoxelID;
    }
    bytes32 baseVoxelTypeId = GrassVoxelID;
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Grass",
      GrassVoxelID,
      baseVoxelTypeId,
      grassChildVoxelTypes,
      grassChildVoxelTypes,
      GrassVoxelVariantID,
      IWorld(world).ca_GrassVoxelSystem_enterWorld.selector,
      IWorld(world).ca_GrassVoxelSystem_exitWorld.selector,
      IWorld(world).ca_GrassVoxelSystem_variantSelector.selector,
      IWorld(world).ca_GrassVoxelSystem_activate.selector,
      IWorld(world).ca_GrassVoxelSystem_eventHandler.selector
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
    return GrassVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory) {}
}
