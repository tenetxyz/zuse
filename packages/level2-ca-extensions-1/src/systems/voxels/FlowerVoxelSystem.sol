// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { BodyTypeRegistry } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { BodyVariantsRegistryData } from "@tenet-registry/src/codegen/tables/BodyVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerBodyVariant, registerBodyType, bodySelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, OrangeFlowerVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { registerCABodyType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant OrangeFlowerVoxelVariantID = bytes32(keccak256("orangeflower"));

string constant OrangeFlowerTexture = "bafkreicins36cmwliwf7ryrlcs32khvi6kleof6buiirlvgv2w6cejpg54";

contract FlowerVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();
    BodyVariantsRegistryData memory orangeFlowerVariant;
    orangeFlowerVariant.blockType = NoaBlockType.MESH;
    orangeFlowerVariant.opaque = false;
    orangeFlowerVariant.solid = false;
    orangeFlowerVariant.frames = 1;
    string[] memory orangeFlowerMaterials = new string[](1);
    orangeFlowerMaterials[0] = OrangeFlowerTexture;
    orangeFlowerVariant.materials = abi.encode(orangeFlowerMaterials);
    registerBodyVariant(REGISTRY_ADDRESS, OrangeFlowerVoxelVariantID, orangeFlowerVariant);

    bytes32[] memory flowerChildBodyTypes = BodyTypeRegistry.getChildBodyTypeIds(
      IStore(REGISTRY_ADDRESS),
      Level2AirVoxelID
    );
    bytes32 baseBodyTypeId = Level2AirVoxelID;
    registerBodyType(
      REGISTRY_ADDRESS,
      "Orange Flower",
      OrangeFlowerVoxelID,
      baseBodyTypeId,
      flowerChildBodyTypes,
      flowerChildBodyTypes,
      OrangeFlowerVoxelVariantID,
      bodySelectorsForVoxel(
        IWorld(world).extension1_FlowerVoxelSyste_enterWorld.selector,
        IWorld(world).extension1_FlowerVoxelSyste_exitWorld.selector,
        IWorld(world).extension1_FlowerVoxelSyste_variantSelector.selector,
        IWorld(world).extension1_FlowerVoxelSyste_activate.selector,
        IWorld(world).extension1_FlowerVoxelSyste_eventHandler.selector
      )
    );

    registerCABodyType(CA_ADDRESS, OrangeFlowerVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OrangeFlowerVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory) {}
}
