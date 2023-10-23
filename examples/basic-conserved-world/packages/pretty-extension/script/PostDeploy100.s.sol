// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { InteractionSelector, VoxelSelectors, ComponentDef } from "@tenet-utils/src/Types.sol";

contract PostDeploy100 is Script {
  function getEmptyVariantsRegistryData() internal returns (VoxelVariantsRegistryData memory){
    VoxelVariantsRegistryData memory data;
    return data;
  }

  function getChildVoxelTypes(bytes32 voxelTypeId) internal returns (bytes32[] memory childVoxelTypes) {
    bytes32[] memory childVoxelTypes = new bytes32[](1);
    childVoxelTypes[0] = voxelTypeId;
    return childVoxelTypes;
  }

  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // Register the voxel types
        registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone",
        bytes32(keccak256("cobblestone")),
        bytes32(keccak256("cobblestone")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone"))),
        bytes32(keccak256("cobblestone")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_169_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab169 Black",
        bytes32(keccak256("oak_lumber_slab_169_black")),
        bytes32(keccak256("oak_lumber_slab_169_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_169_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_169_black"))),
        bytes32(keccak256("oak_lumber_slab_169_black")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_169_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_brightgreen")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Brightgreen",
        bytes32(keccak256("oak_lumber_brightgreen")),
        bytes32(keccak256("oak_lumber_brightgreen")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_brightgreen"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_brightgreen"))),
        bytes32(keccak256("oak_lumber_brightgreen")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_brightgreen")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Green",
        bytes32(keccak256("oak_lumber_green")),
        bytes32(keccak256("oak_lumber_green")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_green"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_green"))),
        bytes32(keccak256("oak_lumber_green")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber",
        bytes32(keccak256("birch_lumber")),
        bytes32(keccak256("birch_lumber")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber"))),
        bytes32(keccak256("birch_lumber")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Red",
        bytes32(keccak256("oak_lumber_red")),
        bytes32(keccak256("oak_lumber_red")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_red"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_red"))),
        bytes32(keccak256("oak_lumber_red")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric",
        bytes32(keccak256("cotton_fabric")),
        bytes32(keccak256("cotton_fabric")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric"))),
        bytes32(keccak256("cotton_fabric")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_192")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step192",
        bytes32(keccak256("cotton_fabric_step_192")),
        bytes32(keccak256("cotton_fabric_step_192")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_192"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_192"))),
        bytes32(keccak256("cotton_fabric_step_192")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_192")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_320_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence320 Black",
        bytes32(keccak256("oak_lumber_fence_320_black")),
        bytes32(keccak256("oak_lumber_fence_320_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_320_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_320_black"))),
        bytes32(keccak256("oak_lumber_fence_320_black")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_320_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_full_64")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Full64",
        bytes32(keccak256("cotton_fabric_full_64")),
        bytes32(keccak256("cotton_fabric_full_64")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_full_64"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_full_64"))),
        bytes32(keccak256("cotton_fabric_full_64")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_full_64")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_brightgreen")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Brightgreen",
        bytes32(keccak256("led_brightgreen")),
        bytes32(keccak256("led_brightgreen")),
        getChildVoxelTypes(bytes32(keccak256("led_brightgreen"))),
        getChildVoxelTypes(bytes32(keccak256("led_brightgreen"))),
        bytes32(keccak256("led_brightgreen")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_brightgreen")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_169_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab169 Red",
        bytes32(keccak256("oak_lumber_slab_169_red")),
        bytes32(keccak256("oak_lumber_slab_169_red")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_169_red"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_169_red"))),
        bytes32(keccak256("oak_lumber_slab_169_red")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_169_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("daylily_flower")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Daylily Flower",
        bytes32(keccak256("daylily_flower")),
        bytes32(keccak256("daylily_flower")),
        getChildVoxelTypes(bytes32(keccak256("daylily_flower"))),
        getChildVoxelTypes(bytes32(keccak256("daylily_flower"))),
        bytes32(keccak256("daylily_flower")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("daylily_flower")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rose_flower")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rose Flower",
        bytes32(keccak256("rose_flower")),
        bytes32(keccak256("rose_flower")),
        getChildVoxelTypes(bytes32(keccak256("rose_flower"))),
        getChildVoxelTypes(bytes32(keccak256("rose_flower"))),
        bytes32(keccak256("rose_flower")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rose_flower")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_leaf")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Leaf",
        bytes32(keccak256("oak_leaf")),
        bytes32(keccak256("oak_leaf")),
        getChildVoxelTypes(bytes32(keccak256("oak_leaf"))),
        getChildVoxelTypes(bytes32(keccak256("oak_leaf"))),
        bytes32(keccak256("oak_leaf")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_leaf")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass",
        bytes32(keccak256("simple_glass")),
        bytes32(keccak256("simple_glass")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass"))),
        bytes32(keccak256("simple_glass")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Slab169",
        bytes32(keccak256("birch_lumber_slab_169")),
        bytes32(keccak256("birch_lumber_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slab_169"))),
        bytes32(keccak256("birch_lumber_slab_169")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Slab128",
        bytes32(keccak256("birch_lumber_slab_128")),
        bytes32(keccak256("birch_lumber_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slab_128"))),
        bytes32(keccak256("birch_lumber_slab_128")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Slab133",
        bytes32(keccak256("birch_lumber_slab_133")),
        bytes32(keccak256("birch_lumber_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slab_133"))),
        bytes32(keccak256("birch_lumber_slab_133")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("mushroom_leather_slice_748")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Mushroom Leather Slice748",
        bytes32(keccak256("mushroom_leather_slice_748")),
        bytes32(keccak256("mushroom_leather_slice_748")),
        getChildVoxelTypes(bytes32(keccak256("mushroom_leather_slice_748"))),
        getChildVoxelTypes(bytes32(keccak256("mushroom_leather_slice_748"))),
        bytes32(keccak256("mushroom_leather_slice_748")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("mushroom_leather_slice_748")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("mushroom_leather_slice_709")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Mushroom Leather Slice709",
        bytes32(keccak256("mushroom_leather_slice_709")),
        bytes32(keccak256("mushroom_leather_slice_709")),
        getChildVoxelTypes(bytes32(keccak256("mushroom_leather_slice_709"))),
        getChildVoxelTypes(bytes32(keccak256("mushroom_leather_slice_709"))),
        bytes32(keccak256("mushroom_leather_slice_709")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("mushroom_leather_slice_709")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("mushroom_leather_slice_704")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Mushroom Leather Slice704",
        bytes32(keccak256("mushroom_leather_slice_704")),
        bytes32(keccak256("mushroom_leather_slice_704")),
        getChildVoxelTypes(bytes32(keccak256("mushroom_leather_slice_704"))),
        getChildVoxelTypes(bytes32(keccak256("mushroom_leather_slice_704"))),
        bytes32(keccak256("mushroom_leather_slice_704")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("mushroom_leather_slice_704")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("wood_crate")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Wood Crate",
        bytes32(keccak256("wood_crate")),
        bytes32(keccak256("wood_crate")),
        getChildVoxelTypes(bytes32(keccak256("wood_crate"))),
        getChildVoxelTypes(bytes32(keccak256("wood_crate"))),
        bytes32(keccak256("wood_crate")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("wood_crate")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_log_256")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Log256",
        bytes32(keccak256("birch_stripped_log_256")),
        bytes32(keccak256("birch_stripped_log_256")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_log_256"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_log_256"))),
        bytes32(keccak256("birch_stripped_log_256")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_log_256")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_log_302")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Log302",
        bytes32(keccak256("birch_stripped_log_302")),
        bytes32(keccak256("birch_stripped_log_302")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_log_302"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_log_302"))),
        bytes32(keccak256("birch_stripped_log_302")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_log_302")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_log_300")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Log300",
        bytes32(keccak256("birch_stripped_log_300")),
        bytes32(keccak256("birch_stripped_log_300")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_log_300"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_log_300"))),
        bytes32(keccak256("birch_stripped_log_300")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_log_300")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_log_261")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Log261",
        bytes32(keccak256("birch_stripped_log_261")),
        bytes32(keccak256("birch_stripped_log_261")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_log_261"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_log_261"))),
        bytes32(keccak256("birch_stripped_log_261")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_log_261")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped",
        bytes32(keccak256("oak_stripped")),
        bytes32(keccak256("oak_stripped")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped"))),
        bytes32(keccak256("oak_stripped")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_log_297")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Log297",
        bytes32(keccak256("oak_stripped_log_297")),
        bytes32(keccak256("oak_stripped_log_297")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_log_297"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_log_297"))),
        bytes32(keccak256("oak_stripped_log_297")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_log_297")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("thatch_beam_1280")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Thatch Beam1280",
        bytes32(keccak256("thatch_beam_1280")),
        bytes32(keccak256("thatch_beam_1280")),
        getChildVoxelTypes(bytes32(keccak256("thatch_beam_1280"))),
        getChildVoxelTypes(bytes32(keccak256("thatch_beam_1280"))),
        bytes32(keccak256("thatch_beam_1280")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("thatch_beam_1280")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_stool_1067")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Stool1067",
        bytes32(keccak256("oak_stripped_stool_1067")),
        bytes32(keccak256("oak_stripped_stool_1067")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_stool_1067"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_stool_1067"))),
        bytes32(keccak256("oak_stripped_stool_1067")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_stool_1067")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Wall489",
        bytes32(keccak256("oak_stripped_wall_489")),
        bytes32(keccak256("oak_stripped_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_wall_489"))),
        bytes32(keccak256("oak_stripped_wall_489")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_log_261")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Log261",
        bytes32(keccak256("oak_stripped_log_261")),
        bytes32(keccak256("oak_stripped_log_261")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_log_261"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_log_261"))),
        bytes32(keccak256("oak_stripped_log_261")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_log_261")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_stool_1070")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Stool1070",
        bytes32(keccak256("oak_stripped_stool_1070")),
        bytes32(keccak256("oak_stripped_stool_1070")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_stool_1070"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_stool_1070"))),
        bytes32(keccak256("oak_stripped_stool_1070")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_stool_1070")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_wall_448")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Wall448",
        bytes32(keccak256("rubber_stripped_wall_448")),
        bytes32(keccak256("rubber_stripped_wall_448")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_wall_448"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_wall_448"))),
        bytes32(keccak256("rubber_stripped_wall_448")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_wall_448")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("thatch_beam_1285")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Thatch Beam1285",
        bytes32(keccak256("thatch_beam_1285")),
        bytes32(keccak256("thatch_beam_1285")),
        getChildVoxelTypes(bytes32(keccak256("thatch_beam_1285"))),
        getChildVoxelTypes(bytes32(keccak256("thatch_beam_1285"))),
        bytes32(keccak256("thatch_beam_1285")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("thatch_beam_1285")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped",
        bytes32(keccak256("birch_stripped")),
        bytes32(keccak256("birch_stripped")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped"))),
        bytes32(keccak256("birch_stripped")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_wall_453")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Wall453",
        bytes32(keccak256("rubber_stripped_wall_453")),
        bytes32(keccak256("rubber_stripped_wall_453")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_wall_453"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_wall_453"))),
        bytes32(keccak256("rubber_stripped_wall_453")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_wall_453")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_peg_812")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Peg812",
        bytes32(keccak256("oak_stripped_peg_812")),
        bytes32(keccak256("oak_stripped_peg_812")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_peg_812"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_peg_812"))),
        bytes32(keccak256("oak_stripped_peg_812")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_peg_812")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_peg_809")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Peg809",
        bytes32(keccak256("oak_stripped_peg_809")),
        bytes32(keccak256("oak_stripped_peg_809")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_peg_809"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_peg_809"))),
        bytes32(keccak256("oak_stripped_peg_809")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_peg_809")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay",
        bytes32(keccak256("hay")),
        bytes32(keccak256("hay")),
        getChildVoxelTypes(bytes32(keccak256("hay"))),
        getChildVoxelTypes(bytes32(keccak256("hay"))),
        bytes32(keccak256("hay")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_reinforced_stool_1024")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Reinforced Stool1024",
        bytes32(keccak256("oak_reinforced_stool_1024")),
        bytes32(keccak256("oak_reinforced_stool_1024")),
        getChildVoxelTypes(bytes32(keccak256("oak_reinforced_stool_1024"))),
        getChildVoxelTypes(bytes32(keccak256("oak_reinforced_stool_1024"))),
        bytes32(keccak256("oak_reinforced_stool_1024")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_reinforced_stool_1024")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_log_300")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Log300",
        bytes32(keccak256("oak_stripped_log_300")),
        bytes32(keccak256("oak_stripped_log_300")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_log_300"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_log_300"))),
        bytes32(keccak256("oak_stripped_log_300")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_log_300")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("thatch_beam_1324")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Thatch Beam1324",
        bytes32(keccak256("thatch_beam_1324")),
        bytes32(keccak256("thatch_beam_1324")),
        getChildVoxelTypes(bytes32(keccak256("thatch_beam_1324"))),
        getChildVoxelTypes(bytes32(keccak256("thatch_beam_1324"))),
        bytes32(keccak256("thatch_beam_1324")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("thatch_beam_1324")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step197",
        bytes32(keccak256("cotton_fabric_step_197")),
        bytes32(keccak256("cotton_fabric_step_197")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_197"))),
        bytes32(keccak256("cotton_fabric_step_197")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_step_192")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Step192",
        bytes32(keccak256("clay_polished_step_192")),
        bytes32(keccak256("clay_polished_step_192")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_step_192"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_step_192"))),
        bytes32(keccak256("clay_polished_step_192")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_step_192")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_window_620")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Window620",
        bytes32(keccak256("rubber_stripped_window_620")),
        bytes32(keccak256("rubber_stripped_window_620")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_window_620"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_window_620"))),
        bytes32(keccak256("rubber_stripped_window_620")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_window_620")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_peg_773")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Peg773",
        bytes32(keccak256("oak_stripped_peg_773")),
        bytes32(keccak256("oak_stripped_peg_773")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_peg_773"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_peg_773"))),
        bytes32(keccak256("oak_stripped_peg_773")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_peg_773")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_window_576")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Window576",
        bytes32(keccak256("rubber_stripped_window_576")),
        bytes32(keccak256("rubber_stripped_window_576")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_window_576"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_window_576"))),
        bytes32(keccak256("rubber_stripped_window_576")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_window_576")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_fence_327")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Fence327",
        bytes32(keccak256("cotton_fabric_fence_327")),
        bytes32(keccak256("cotton_fabric_fence_327")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_fence_327"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_fence_327"))),
        bytes32(keccak256("cotton_fabric_fence_327")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_fence_327")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_fence_325")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Fence325",
        bytes32(keccak256("cotton_fabric_fence_325")),
        bytes32(keccak256("cotton_fabric_fence_325")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_fence_325"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_fence_325"))),
        bytes32(keccak256("cotton_fabric_fence_325")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_fence_325")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_log_258")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Log258",
        bytes32(keccak256("birch_stripped_log_258")),
        bytes32(keccak256("birch_stripped_log_258")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_log_258"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_log_258"))),
        bytes32(keccak256("birch_stripped_log_258")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_log_258")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Step199",
        bytes32(keccak256("clay_polished_step_199")),
        bytes32(keccak256("clay_polished_step_199")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_step_199"))),
        bytes32(keccak256("clay_polished_step_199")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_194")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step194",
        bytes32(keccak256("cotton_fabric_step_194")),
        bytes32(keccak256("cotton_fabric_step_194")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_194"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_194"))),
        bytes32(keccak256("cotton_fabric_step_194")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_194")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_log_297")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Log297",
        bytes32(keccak256("birch_stripped_log_297")),
        bytes32(keccak256("birch_stripped_log_297")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_log_297"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_log_297"))),
        bytes32(keccak256("birch_stripped_log_297")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_log_297")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_beam_1324")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Beam1324",
        bytes32(keccak256("led_beam_1324")),
        bytes32(keccak256("led_beam_1324")),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1324"))),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1324"))),
        bytes32(keccak256("led_beam_1324")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_beam_1324")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_step_238")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Step238",
        bytes32(keccak256("rubber_stripped_step_238")),
        bytes32(keccak256("rubber_stripped_step_238")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_step_238"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_step_238"))),
        bytes32(keccak256("rubber_stripped_step_238")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_step_238")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Slab130",
        bytes32(keccak256("rubber_stripped_slab_130")),
        bytes32(keccak256("rubber_stripped_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_slab_130"))),
        bytes32(keccak256("rubber_stripped_slab_130")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_step_235")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Step235",
        bytes32(keccak256("rubber_stripped_step_235")),
        bytes32(keccak256("rubber_stripped_step_235")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_step_235"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_step_235"))),
        bytes32(keccak256("rubber_stripped_step_235")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_step_235")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_beam_1280")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Beam1280",
        bytes32(keccak256("led_beam_1280")),
        bytes32(keccak256("led_beam_1280")),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1280"))),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1280"))),
        bytes32(keccak256("led_beam_1280")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_beam_1280")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_beam_1321")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Beam1321",
        bytes32(keccak256("led_beam_1321")),
        bytes32(keccak256("led_beam_1321")),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1321"))),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1321"))),
        bytes32(keccak256("led_beam_1321")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_beam_1321")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_knob_901")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Knob901",
        bytes32(keccak256("oak_stripped_knob_901")),
        bytes32(keccak256("oak_stripped_knob_901")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_knob_901"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_knob_901"))),
        bytes32(keccak256("oak_stripped_knob_901")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_knob_901")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Step233",
        bytes32(keccak256("oak_stripped_step_233")),
        bytes32(keccak256("oak_stripped_step_233")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_step_233"))),
        bytes32(keccak256("oak_stripped_step_233")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_knob_940")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Knob940",
        bytes32(keccak256("oak_stripped_knob_940")),
        bytes32(keccak256("oak_stripped_knob_940")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_knob_940"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_knob_940"))),
        bytes32(keccak256("oak_stripped_knob_940")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_knob_940")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_step_192")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Step192",
        bytes32(keccak256("oak_stripped_step_192")),
        bytes32(keccak256("oak_stripped_step_192")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_step_192"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_step_192"))),
        bytes32(keccak256("oak_stripped_step_192")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_step_192")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_slice_706")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Slice706",
        bytes32(keccak256("oak_stripped_slice_706")),
        bytes32(keccak256("oak_stripped_slice_706")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slice_706"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slice_706"))),
        bytes32(keccak256("oak_stripped_slice_706")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_slice_706")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_slice_750")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Slice750",
        bytes32(keccak256("oak_stripped_slice_750")),
        bytes32(keccak256("oak_stripped_slice_750")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slice_750"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slice_750"))),
        bytes32(keccak256("oak_stripped_slice_750")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_slice_750")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_slice_711")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Slice711",
        bytes32(keccak256("oak_stripped_slice_711")),
        bytes32(keccak256("oak_stripped_slice_711")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slice_711"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slice_711"))),
        bytes32(keccak256("oak_stripped_slice_711")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_slice_711")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Step197",
        bytes32(keccak256("oak_stripped_step_197")),
        bytes32(keccak256("oak_stripped_step_197")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_step_197"))),
        bytes32(keccak256("oak_stripped_step_197")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_track_1385")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Track1385",
        bytes32(keccak256("rubber_lumber_track_1385")),
        bytes32(keccak256("rubber_lumber_track_1385")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_track_1385"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_track_1385"))),
        bytes32(keccak256("rubber_lumber_track_1385")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_track_1385")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_slab_135")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Slab135",
        bytes32(keccak256("oak_stripped_slab_135")),
        bytes32(keccak256("oak_stripped_slab_135")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slab_135"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slab_135"))),
        bytes32(keccak256("oak_stripped_slab_135")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_slab_135")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_slab_171")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Slab171",
        bytes32(keccak256("oak_stripped_slab_171")),
        bytes32(keccak256("oak_stripped_slab_171")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slab_171"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slab_171"))),
        bytes32(keccak256("oak_stripped_slab_171")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_slab_171")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_step_194")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Step194",
        bytes32(keccak256("oak_stripped_step_194")),
        bytes32(keccak256("oak_stripped_step_194")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_step_194"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_step_194"))),
        bytes32(keccak256("oak_stripped_step_194")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_step_194")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_slice_747")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Slice747",
        bytes32(keccak256("oak_stripped_slice_747")),
        bytes32(keccak256("oak_stripped_slice_747")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slice_747"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slice_747"))),
        bytes32(keccak256("oak_stripped_slice_747")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_slice_747")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_corner_837")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Corner837",
        bytes32(keccak256("oak_stripped_corner_837")),
        bytes32(keccak256("oak_stripped_corner_837")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_corner_837"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_corner_837"))),
        bytes32(keccak256("oak_stripped_corner_837")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_corner_837")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Slab130",
        bytes32(keccak256("oak_stripped_slab_130")),
        bytes32(keccak256("oak_stripped_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slab_130"))),
        bytes32(keccak256("oak_stripped_slab_130")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_wall_448")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Wall448",
        bytes32(keccak256("birch_stripped_wall_448")),
        bytes32(keccak256("birch_stripped_wall_448")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_wall_448"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_wall_448"))),
        bytes32(keccak256("birch_stripped_wall_448")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_wall_448")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_beam_1321")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Beam1321",
        bytes32(keccak256("birch_stripped_beam_1321")),
        bytes32(keccak256("birch_stripped_beam_1321")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_beam_1321"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_beam_1321"))),
        bytes32(keccak256("birch_stripped_beam_1321")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_beam_1321")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_slab_174")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Slab174",
        bytes32(keccak256("oak_stripped_slab_174")),
        bytes32(keccak256("oak_stripped_slab_174")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slab_174"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slab_174"))),
        bytes32(keccak256("oak_stripped_slab_174")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_slab_174")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_knob_937")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Knob937",
        bytes32(keccak256("oak_stripped_knob_937")),
        bytes32(keccak256("oak_stripped_knob_937")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_knob_937"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_knob_937"))),
        bytes32(keccak256("oak_stripped_knob_937")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_knob_937")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Step236",
        bytes32(keccak256("oak_stripped_step_236")),
        bytes32(keccak256("oak_stripped_step_236")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_step_236"))),
        bytes32(keccak256("oak_stripped_step_236")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_knob_896")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Knob896",
        bytes32(keccak256("oak_stripped_knob_896")),
        bytes32(keccak256("oak_stripped_knob_896")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_knob_896"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_knob_896"))),
        bytes32(keccak256("oak_stripped_knob_896")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_knob_896")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Slab130",
        bytes32(keccak256("silver_slab_130")),
        bytes32(keccak256("silver_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("silver_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("silver_slab_130"))),
        bytes32(keccak256("silver_slab_130")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver",
        bytes32(keccak256("silver")),
        bytes32(keccak256("silver")),
        getChildVoxelTypes(bytes32(keccak256("silver"))),
        getChildVoxelTypes(bytes32(keccak256("silver"))),
        bytes32(keccak256("silver")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Step236",
        bytes32(keccak256("silver_step_236")),
        bytes32(keccak256("silver_step_236")),
        getChildVoxelTypes(bytes32(keccak256("silver_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("silver_step_236"))),
        bytes32(keccak256("silver_step_236")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_stool_1026")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Stool1026",
        bytes32(keccak256("silver_stool_1026")),
        bytes32(keccak256("silver_stool_1026")),
        getChildVoxelTypes(bytes32(keccak256("silver_stool_1026"))),
        getChildVoxelTypes(bytes32(keccak256("silver_stool_1026"))),
        bytes32(keccak256("silver_stool_1026")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_stool_1026")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Step233",
        bytes32(keccak256("silver_step_233")),
        bytes32(keccak256("silver_step_233")),
        getChildVoxelTypes(bytes32(keccak256("silver_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("silver_step_233"))),
        bytes32(keccak256("silver_step_233")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_peg_768")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Peg768",
        bytes32(keccak256("silver_peg_768")),
        bytes32(keccak256("silver_peg_768")),
        getChildVoxelTypes(bytes32(keccak256("silver_peg_768"))),
        getChildVoxelTypes(bytes32(keccak256("silver_peg_768"))),
        bytes32(keccak256("silver_peg_768")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_peg_768")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Slab128",
        bytes32(keccak256("silver_slab_128")),
        bytes32(keccak256("silver_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("silver_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("silver_slab_128"))),
        bytes32(keccak256("silver_slab_128")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber",
        bytes32(keccak256("oak_lumber")),
        bytes32(keccak256("oak_lumber")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber"))),
        bytes32(keccak256("oak_lumber")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_364")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence364",
        bytes32(keccak256("oak_lumber_fence_364")),
        bytes32(keccak256("oak_lumber_fence_364")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_364"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_364"))),
        bytes32(keccak256("oak_lumber_fence_364")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_364")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1026")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Stool1026",
        bytes32(keccak256("rubber_stripped_stool_1026")),
        bytes32(keccak256("rubber_stripped_stool_1026")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1026"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1026"))),
        bytes32(keccak256("rubber_stripped_stool_1026")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1026")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall489",
        bytes32(keccak256("oak_lumber_wall_489")),
        bytes32(keccak256("oak_lumber_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_489"))),
        bytes32(keccak256("oak_lumber_wall_489")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_full_64")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Full64",
        bytes32(keccak256("hay_full_64")),
        bytes32(keccak256("hay_full_64")),
        getChildVoxelTypes(bytes32(keccak256("hay_full_64"))),
        getChildVoxelTypes(bytes32(keccak256("hay_full_64"))),
        bytes32(keccak256("hay_full_64")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_full_64")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall492",
        bytes32(keccak256("oak_lumber_wall_492")),
        bytes32(keccak256("oak_lumber_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_492"))),
        bytes32(keccak256("oak_lumber_wall_492")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_492")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("wood_crate_outset_1157")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Wood Crate Outset1157",
        bytes32(keccak256("wood_crate_outset_1157")),
        bytes32(keccak256("wood_crate_outset_1157")),
        getChildVoxelTypes(bytes32(keccak256("wood_crate_outset_1157"))),
        getChildVoxelTypes(bytes32(keccak256("wood_crate_outset_1157"))),
        bytes32(keccak256("wood_crate_outset_1157")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("wood_crate_outset_1157")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Slab133",
        bytes32(keccak256("hay_slab_133")),
        bytes32(keccak256("hay_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("hay_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("hay_slab_133"))),
        bytes32(keccak256("hay_slab_133")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step199",
        bytes32(keccak256("oak_lumber_step_199")),
        bytes32(keccak256("oak_lumber_step_199")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_199"))),
        bytes32(keccak256("oak_lumber_step_199")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("wood_crate_outset_1196")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Wood Crate Outset1196",
        bytes32(keccak256("wood_crate_outset_1196")),
        bytes32(keccak256("wood_crate_outset_1196")),
        getChildVoxelTypes(bytes32(keccak256("wood_crate_outset_1196"))),
        getChildVoxelTypes(bytes32(keccak256("wood_crate_outset_1196"))),
        bytes32(keccak256("wood_crate_outset_1196")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("wood_crate_outset_1196")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("wood_crate_outset_1152")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Wood Crate Outset1152",
        bytes32(keccak256("wood_crate_outset_1152")),
        bytes32(keccak256("wood_crate_outset_1152")),
        getChildVoxelTypes(bytes32(keccak256("wood_crate_outset_1152"))),
        getChildVoxelTypes(bytes32(keccak256("wood_crate_outset_1152"))),
        bytes32(keccak256("wood_crate_outset_1152")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        1
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("wood_crate_outset_1152")));

    vm.stopBroadcast();
  }
}
