// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, OrangeFlowerVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant OrangeFlowerVoxelVariantID = bytes32(keccak256("orangeflower"));

string constant OrangeFlowerTexture = "bafkreicins36cmwliwf7ryrlcs32khvi6kleof6buiirlvgv2w6cejpg54";

contract FlowerVoxelSystem is System {
  function registerVoxelFlower() public {
    address world = _world();
    VoxelVariantsRegistryData memory orangeFlowerVariant;
    orangeFlowerVariant.blockType = NoaBlockType.MESH;
    orangeFlowerVariant.opaque = false;
    orangeFlowerVariant.solid = false;
    orangeFlowerVariant.frames = 1;
    string[] memory orangeFlowerMaterials = new string[](1);
    orangeFlowerMaterials[0] = OrangeFlowerTexture;
    orangeFlowerVariant.materials = abi.encode(orangeFlowerMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, OrangeFlowerVoxelVariantID, orangeFlowerVariant);

    bytes32[] memory flowerChildVoxelTypes = VoxelTypeRegistry.getChildVoxelTypeIds(
      IStore(REGISTRY_ADDRESS),
      Level2AirVoxelID
    );
    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Orange Flower",
      OrangeFlowerVoxelID,
      baseVoxelTypeId,
      flowerChildVoxelTypes,
      flowerChildVoxelTypes,
      OrangeFlowerVoxelVariantID
    );

    registerCAVoxelType(
      CA_ADDRESS,
      OrangeFlowerVoxelID,
      IWorld(world).enterWorldFlower.selector,
      IWorld(world).exitWorldFlower.selector,
      IWorld(world).variantSelectorFlower.selector,
      IWorld(world).activateSelectorFlower.selector,
      IWorld(world).eventHandlerFlower.selector
    );
  }

  function enterWorldFlower(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function exitWorldFlower(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function variantSelectorFlower(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    return OrangeFlowerVoxelVariantID;
  }

  function activateSelectorFlower(address callerAddress, bytes32 entity) public view returns (string memory) {}

  function eventHandlerFlower(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {}
}
