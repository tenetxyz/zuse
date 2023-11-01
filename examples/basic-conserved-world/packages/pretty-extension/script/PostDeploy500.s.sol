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

contract PostDeploy500 is Script {
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
        registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_174")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Slab174",
        bytes32(keccak256("cobblestone_brick_slab_174")),
        bytes32(keccak256("cobblestone_brick_slab_174")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_174"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_174"))),
        bytes32(keccak256("cobblestone_brick_slab_174")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_174")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_corner_876")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Corner876",
        bytes32(keccak256("oak_lumber_corner_876")),
        bytes32(keccak256("oak_lumber_corner_876")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_corner_876"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_corner_876"))),
        bytes32(keccak256("oak_lumber_corner_876")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_corner_876")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_full_64_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Full64 Orange",
        bytes32(keccak256("oak_lumber_full_64_orange")),
        bytes32(keccak256("oak_lumber_full_64_orange")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_64_orange"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_64_orange"))),
        bytes32(keccak256("oak_lumber_full_64_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_full_64_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_233_yellow")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step233 Yellow",
        bytes32(keccak256("cotton_fabric_step_233_yellow")),
        bytes32(keccak256("cotton_fabric_step_233_yellow")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_233_yellow"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_233_yellow"))),
        bytes32(keccak256("cotton_fabric_step_233_yellow")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_233_yellow")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_frame_684_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Frame684 Orange",
        bytes32(keccak256("oak_lumber_frame_684_orange")),
        bytes32(keccak256("oak_lumber_frame_684_orange")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_684_orange"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_684_orange"))),
        bytes32(keccak256("oak_lumber_frame_684_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_frame_684_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("stone")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Stone",
        bytes32(keccak256("stone")),
        bytes32(keccak256("stone")),
        getChildVoxelTypes(bytes32(keccak256("stone"))),
        getChildVoxelTypes(bytes32(keccak256("stone"))),
        bytes32(keccak256("stone")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("stone")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_325")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence325",
        bytes32(keccak256("oak_lumber_fence_325")),
        bytes32(keccak256("oak_lumber_fence_325")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_325"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_325"))),
        bytes32(keccak256("oak_lumber_fence_325")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_325")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_320")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence320",
        bytes32(keccak256("oak_lumber_fence_320")),
        bytes32(keccak256("oak_lumber_fence_320")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_320"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_320"))),
        bytes32(keccak256("oak_lumber_fence_320")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_320")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_361")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence361",
        bytes32(keccak256("oak_lumber_fence_361")),
        bytes32(keccak256("oak_lumber_fence_361")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_361"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_361"))),
        bytes32(keccak256("oak_lumber_fence_361")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_361")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_363")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence363",
        bytes32(keccak256("oak_lumber_fence_363")),
        bytes32(keccak256("oak_lumber_fence_363")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_363"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_363"))),
        bytes32(keccak256("oak_lumber_fence_363")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_363")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_366")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence366",
        bytes32(keccak256("oak_lumber_fence_366")),
        bytes32(keccak256("oak_lumber_fence_366")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_366"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_366"))),
        bytes32(keccak256("oak_lumber_fence_366")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_366")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt",
        bytes32(keccak256("basalt")),
        bytes32(keccak256("basalt")),
        getChildVoxelTypes(bytes32(keccak256("basalt"))),
        getChildVoxelTypes(bytes32(keccak256("basalt"))),
        bytes32(keccak256("basalt")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("muckwad_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Muckwad Step236",
        bytes32(keccak256("muckwad_step_236")),
        bytes32(keccak256("muckwad_step_236")),
        getChildVoxelTypes(bytes32(keccak256("muckwad_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("muckwad_step_236"))),
        bytes32(keccak256("muckwad_step_236")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("muckwad_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_fence_364")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Fence364",
        bytes32(keccak256("basalt_fence_364")),
        bytes32(keccak256("basalt_fence_364")),
        getChildVoxelTypes(bytes32(keccak256("basalt_fence_364"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_fence_364"))),
        bytes32(keccak256("basalt_fence_364")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_fence_364")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_fence_325")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Fence325",
        bytes32(keccak256("basalt_fence_325")),
        bytes32(keccak256("basalt_fence_325")),
        getChildVoxelTypes(bytes32(keccak256("basalt_fence_325"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_fence_325"))),
        bytes32(keccak256("basalt_fence_325")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_fence_325")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_fence_320")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Fence320",
        bytes32(keccak256("basalt_fence_320")),
        bytes32(keccak256("basalt_fence_320")),
        getChildVoxelTypes(bytes32(keccak256("basalt_fence_320"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_fence_320"))),
        bytes32(keccak256("basalt_fence_320")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_fence_320")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("stone_fence_325")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Stone Fence325",
        bytes32(keccak256("stone_fence_325")),
        bytes32(keccak256("stone_fence_325")),
        getChildVoxelTypes(bytes32(keccak256("stone_fence_325"))),
        getChildVoxelTypes(bytes32(keccak256("stone_fence_325"))),
        bytes32(keccak256("stone_fence_325")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("stone_fence_325")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_log")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Log",
        bytes32(keccak256("rubber_log")),
        bytes32(keccak256("rubber_log")),
        getChildVoxelTypes(bytes32(keccak256("rubber_log"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_log"))),
        bytes32(keccak256("rubber_log")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_log")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_log_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Log Step236",
        bytes32(keccak256("sakura_log_step_236")),
        bytes32(keccak256("sakura_log_step_236")),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_step_236"))),
        bytes32(keccak256("sakura_log_step_236")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_log_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_log_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Log Step197",
        bytes32(keccak256("sakura_log_step_197")),
        bytes32(keccak256("sakura_log_step_197")),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_step_197"))),
        bytes32(keccak256("sakura_log_step_197")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_log_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_log_step_192")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Log Step192",
        bytes32(keccak256("sakura_log_step_192")),
        bytes32(keccak256("sakura_log_step_192")),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_step_192"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_step_192"))),
        bytes32(keccak256("sakura_log_step_192")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_log_step_192")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_log_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Log Step233",
        bytes32(keccak256("sakura_log_step_233")),
        bytes32(keccak256("sakura_log_step_233")),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_step_233"))),
        bytes32(keccak256("sakura_log_step_233")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_log_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("dirt_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Dirt Step199",
        bytes32(keccak256("dirt_step_199")),
        bytes32(keccak256("dirt_step_199")),
        getChildVoxelTypes(bytes32(keccak256("dirt_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("dirt_step_199"))),
        bytes32(keccak256("dirt_step_199")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("dirt_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("stone_fence_364")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Stone Fence364",
        bytes32(keccak256("stone_fence_364")),
        bytes32(keccak256("stone_fence_364")),
        getChildVoxelTypes(bytes32(keccak256("stone_fence_364"))),
        getChildVoxelTypes(bytes32(keccak256("stone_fence_364"))),
        bytes32(keccak256("stone_fence_364")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("stone_fence_364")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("stone_fence_361")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Stone Fence361",
        bytes32(keccak256("stone_fence_361")),
        bytes32(keccak256("stone_fence_361")),
        getChildVoxelTypes(bytes32(keccak256("stone_fence_361"))),
        getChildVoxelTypes(bytes32(keccak256("stone_fence_361"))),
        bytes32(keccak256("stone_fence_361")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("stone_fence_361")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_log")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Log",
        bytes32(keccak256("sakura_log")),
        bytes32(keccak256("sakura_log")),
        getChildVoxelTypes(bytes32(keccak256("sakura_log"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_log"))),
        bytes32(keccak256("sakura_log")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_log")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_log_slab_174")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Log Slab174",
        bytes32(keccak256("sakura_log_slab_174")),
        bytes32(keccak256("sakura_log_slab_174")),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_slab_174"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_slab_174"))),
        bytes32(keccak256("sakura_log_slab_174")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_log_slab_174")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("dirt_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Dirt Step197",
        bytes32(keccak256("dirt_step_197")),
        bytes32(keccak256("dirt_step_197")),
        getChildVoxelTypes(bytes32(keccak256("dirt_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("dirt_step_197"))),
        bytes32(keccak256("dirt_step_197")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("dirt_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_log_slab_171")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Log Slab171",
        bytes32(keccak256("sakura_log_slab_171")),
        bytes32(keccak256("sakura_log_slab_171")),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_slab_171"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_slab_171"))),
        bytes32(keccak256("sakura_log_slab_171")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_log_slab_171")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("quartzite_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Quartzite Step233",
        bytes32(keccak256("quartzite_step_233")),
        bytes32(keccak256("quartzite_step_233")),
        getChildVoxelTypes(bytes32(keccak256("quartzite_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("quartzite_step_233"))),
        bytes32(keccak256("quartzite_step_233")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("quartzite_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("quartzite_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Quartzite Step236",
        bytes32(keccak256("quartzite_step_236")),
        bytes32(keccak256("quartzite_step_236")),
        getChildVoxelTypes(bytes32(keccak256("quartzite_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("quartzite_step_236"))),
        bytes32(keccak256("quartzite_step_236")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("quartzite_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_log_wall_453")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Log Wall453",
        bytes32(keccak256("rubber_log_wall_453")),
        bytes32(keccak256("rubber_log_wall_453")),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_wall_453"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_wall_453"))),
        bytes32(keccak256("rubber_log_wall_453")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_log_wall_453")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("quartzite_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Quartzite Slab133",
        bytes32(keccak256("quartzite_slab_133")),
        bytes32(keccak256("quartzite_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("quartzite_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("quartzite_slab_133"))),
        bytes32(keccak256("quartzite_slab_133")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("quartzite_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("quartzite_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Quartzite Slab128",
        bytes32(keccak256("quartzite_slab_128")),
        bytes32(keccak256("quartzite_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("quartzite_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("quartzite_slab_128"))),
        bytes32(keccak256("quartzite_slab_128")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("quartzite_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("dirt_fence_320")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Dirt Fence320",
        bytes32(keccak256("dirt_fence_320")),
        bytes32(keccak256("dirt_fence_320")),
        getChildVoxelTypes(bytes32(keccak256("dirt_fence_320"))),
        getChildVoxelTypes(bytes32(keccak256("dirt_fence_320"))),
        bytes32(keccak256("dirt_fence_320")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("dirt_fence_320")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_log_wall_448")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Log Wall448",
        bytes32(keccak256("rubber_log_wall_448")),
        bytes32(keccak256("rubber_log_wall_448")),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_wall_448"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_wall_448"))),
        bytes32(keccak256("rubber_log_wall_448")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_log_wall_448")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("dirt_fence_364")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Dirt Fence364",
        bytes32(keccak256("dirt_fence_364")),
        bytes32(keccak256("dirt_fence_364")),
        getChildVoxelTypes(bytes32(keccak256("dirt_fence_364"))),
        getChildVoxelTypes(bytes32(keccak256("dirt_fence_364"))),
        bytes32(keccak256("dirt_fence_364")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("dirt_fence_364")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_log_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Log Step199",
        bytes32(keccak256("rubber_log_step_199")),
        bytes32(keccak256("rubber_log_step_199")),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_step_199"))),
        bytes32(keccak256("rubber_log_step_199")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_log_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_log_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Log Wall489",
        bytes32(keccak256("rubber_log_wall_489")),
        bytes32(keccak256("rubber_log_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_wall_489"))),
        bytes32(keccak256("rubber_log_wall_489")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_log_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_log_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Log Wall492",
        bytes32(keccak256("rubber_log_wall_492")),
        bytes32(keccak256("rubber_log_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_wall_492"))),
        bytes32(keccak256("rubber_log_wall_492")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_log_wall_492")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("emberstone_full_64")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Emberstone Full64",
        bytes32(keccak256("emberstone_full_64")),
        bytes32(keccak256("emberstone_full_64")),
        getChildVoxelTypes(bytes32(keccak256("emberstone_full_64"))),
        getChildVoxelTypes(bytes32(keccak256("emberstone_full_64"))),
        bytes32(keccak256("emberstone_full_64")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("emberstone_full_64")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Slab128",
        bytes32(keccak256("basalt_slab_128")),
        bytes32(keccak256("basalt_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("basalt_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_slab_128"))),
        bytes32(keccak256("basalt_slab_128")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_log_step_235")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Log Step235",
        bytes32(keccak256("rubber_log_step_235")),
        bytes32(keccak256("rubber_log_step_235")),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_step_235"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_step_235"))),
        bytes32(keccak256("rubber_log_step_235")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_log_step_235")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_log_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Log Step233",
        bytes32(keccak256("rubber_log_step_233")),
        bytes32(keccak256("rubber_log_step_233")),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_step_233"))),
        bytes32(keccak256("rubber_log_step_233")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_log_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("ultraviolet")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Ultraviolet",
        bytes32(keccak256("ultraviolet")),
        bytes32(keccak256("ultraviolet")),
        getChildVoxelTypes(bytes32(keccak256("ultraviolet"))),
        getChildVoxelTypes(bytes32(keccak256("ultraviolet"))),
        bytes32(keccak256("ultraviolet")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("ultraviolet")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_leaf")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Leaf",
        bytes32(keccak256("sakura_leaf")),
        bytes32(keccak256("sakura_leaf")),
        getChildVoxelTypes(bytes32(keccak256("sakura_leaf"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_leaf"))),
        bytes32(keccak256("sakura_leaf")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_leaf")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_leaf")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Leaf",
        bytes32(keccak256("rubber_leaf")),
        bytes32(keccak256("rubber_leaf")),
        getChildVoxelTypes(bytes32(keccak256("rubber_leaf"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_leaf"))),
        bytes32(keccak256("rubber_leaf")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_leaf")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("corn")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Corn",
        bytes32(keccak256("corn")),
        bytes32(keccak256("corn")),
        getChildVoxelTypes(bytes32(keccak256("corn"))),
        getChildVoxelTypes(bytes32(keccak256("corn"))),
        bytes32(keccak256("corn")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("corn")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_log_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Log Step199",
        bytes32(keccak256("sakura_log_step_199")),
        bytes32(keccak256("sakura_log_step_199")),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_step_199"))),
        bytes32(keccak256("sakura_log_step_199")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_log_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_log_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Log Wall492",
        bytes32(keccak256("sakura_log_wall_492")),
        bytes32(keccak256("sakura_log_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_wall_492"))),
        bytes32(keccak256("sakura_log_wall_492")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_log_wall_492")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_log_slab_135")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Log Slab135",
        bytes32(keccak256("sakura_log_slab_135")),
        bytes32(keccak256("sakura_log_slab_135")),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_slab_135"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_slab_135"))),
        bytes32(keccak256("sakura_log_slab_135")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_log_slab_135")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_slab_169_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Slab169 Purple",
        bytes32(keccak256("led_slab_169_purple")),
        bytes32(keccak256("led_slab_169_purple")),
        getChildVoxelTypes(bytes32(keccak256("led_slab_169_purple"))),
        getChildVoxelTypes(bytes32(keccak256("led_slab_169_purple"))),
        bytes32(keccak256("led_slab_169_purple")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_slab_169_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_log_step_235")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Log Step235",
        bytes32(keccak256("sakura_log_step_235")),
        bytes32(keccak256("sakura_log_step_235")),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_step_235"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_step_235"))),
        bytes32(keccak256("sakura_log_step_235")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_log_step_235")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_log_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Log Slab133",
        bytes32(keccak256("sakura_log_slab_133")),
        bytes32(keccak256("sakura_log_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_slab_133"))),
        bytes32(keccak256("sakura_log_slab_133")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_log_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sakura_log_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sakura Log Slab169",
        bytes32(keccak256("sakura_log_slab_169")),
        bytes32(keccak256("sakura_log_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("sakura_log_slab_169"))),
        bytes32(keccak256("sakura_log_slab_169")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sakura_log_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_log_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Log Slab172",
        bytes32(keccak256("oak_log_slab_172")),
        bytes32(keccak256("oak_log_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("oak_log_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("oak_log_slab_172"))),
        bytes32(keccak256("oak_log_slab_172")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_log_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_log_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Log Slab128",
        bytes32(keccak256("oak_log_slab_128")),
        bytes32(keccak256("oak_log_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("oak_log_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("oak_log_slab_128"))),
        bytes32(keccak256("oak_log_slab_128")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_log_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_log_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Log Slab169",
        bytes32(keccak256("oak_log_slab_169")),
        bytes32(keccak256("oak_log_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("oak_log_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("oak_log_slab_169"))),
        bytes32(keccak256("oak_log_slab_169")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_log_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_wall_489_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Wall489 Purple",
        bytes32(keccak256("simple_glass_wall_489_purple")),
        bytes32(keccak256("simple_glass_wall_489_purple")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_wall_489_purple"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_wall_489_purple"))),
        bytes32(keccak256("simple_glass_wall_489_purple")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_wall_489_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_wall_492_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Wall492 Purple",
        bytes32(keccak256("simple_glass_wall_492_purple")),
        bytes32(keccak256("simple_glass_wall_492_purple")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_wall_492_purple"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_wall_492_purple"))),
        bytes32(keccak256("simple_glass_wall_492_purple")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_wall_492_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_wall_453_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Wall453 Purple",
        bytes32(keccak256("simple_glass_wall_453_purple")),
        bytes32(keccak256("simple_glass_wall_453_purple")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_wall_453_purple"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_wall_453_purple"))),
        bytes32(keccak256("simple_glass_wall_453_purple")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_wall_453_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_wall_491_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Wall491 Purple",
        bytes32(keccak256("simple_glass_wall_491_purple")),
        bytes32(keccak256("simple_glass_wall_491_purple")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_wall_491_purple"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_wall_491_purple"))),
        bytes32(keccak256("simple_glass_wall_491_purple")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_wall_491_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_slab_128_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Slab128 Purple",
        bytes32(keccak256("simple_glass_slab_128_purple")),
        bytes32(keccak256("simple_glass_slab_128_purple")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_slab_128_purple"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_slab_128_purple"))),
        bytes32(keccak256("simple_glass_slab_128_purple")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_slab_128_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_fence_361_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Fence361 Purple",
        bytes32(keccak256("simple_glass_fence_361_purple")),
        bytes32(keccak256("simple_glass_fence_361_purple")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_fence_361_purple"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_fence_361_purple"))),
        bytes32(keccak256("simple_glass_fence_361_purple")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_fence_361_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_wall_448_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Wall448 Purple",
        bytes32(keccak256("simple_glass_wall_448_purple")),
        bytes32(keccak256("simple_glass_wall_448_purple")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_wall_448_purple"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_wall_448_purple"))),
        bytes32(keccak256("simple_glass_wall_448_purple")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_wall_448_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Wall489",
        bytes32(keccak256("simple_glass_wall_489")),
        bytes32(keccak256("simple_glass_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_wall_489"))),
        bytes32(keccak256("simple_glass_wall_489")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("stone_brick")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Stone Brick",
        bytes32(keccak256("stone_brick")),
        bytes32(keccak256("stone_brick")),
        getChildVoxelTypes(bytes32(keccak256("stone_brick"))),
        getChildVoxelTypes(bytes32(keccak256("stone_brick"))),
        bytes32(keccak256("stone_brick")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("stone_brick")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("stone_polished_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Stone Polished Slab172",
        bytes32(keccak256("stone_polished_slab_172")),
        bytes32(keccak256("stone_polished_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("stone_polished_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("stone_polished_slab_172"))),
        bytes32(keccak256("stone_polished_slab_172")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("stone_polished_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("stone_carved")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Stone Carved",
        bytes32(keccak256("stone_carved")),
        bytes32(keccak256("stone_carved")),
        getChildVoxelTypes(bytes32(keccak256("stone_carved"))),
        getChildVoxelTypes(bytes32(keccak256("stone_carved"))),
        bytes32(keccak256("stone_carved")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("stone_carved")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("stone_polished_fence_361")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Stone Polished Fence361",
        bytes32(keccak256("stone_polished_fence_361")),
        bytes32(keccak256("stone_polished_fence_361")),
        getChildVoxelTypes(bytes32(keccak256("stone_polished_fence_361"))),
        getChildVoxelTypes(bytes32(keccak256("stone_polished_fence_361"))),
        bytes32(keccak256("stone_polished_fence_361")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("stone_polished_fence_361")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("stone_polished")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Stone Polished",
        bytes32(keccak256("stone_polished")),
        bytes32(keccak256("stone_polished")),
        getChildVoxelTypes(bytes32(keccak256("stone_polished"))),
        getChildVoxelTypes(bytes32(keccak256("stone_polished"))),
        bytes32(keccak256("stone_polished")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("stone_polished")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("stone_polished_fence_325")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Stone Polished Fence325",
        bytes32(keccak256("stone_polished_fence_325")),
        bytes32(keccak256("stone_polished_fence_325")),
        getChildVoxelTypes(bytes32(keccak256("stone_polished_fence_325"))),
        getChildVoxelTypes(bytes32(keccak256("stone_polished_fence_325"))),
        bytes32(keccak256("stone_polished_fence_325")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("stone_polished_fence_325")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moonstone")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moonstone",
        bytes32(keccak256("moonstone")),
        bytes32(keccak256("moonstone")),
        getChildVoxelTypes(bytes32(keccak256("moonstone"))),
        getChildVoxelTypes(bytes32(keccak256("moonstone"))),
        bytes32(keccak256("moonstone")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moonstone")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber",
        bytes32(keccak256("rubber_lumber")),
        bytes32(keccak256("rubber_lumber")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber"))),
        bytes32(keccak256("rubber_lumber")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_step_192")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Step192",
        bytes32(keccak256("rubber_lumber_step_192")),
        bytes32(keccak256("rubber_lumber_step_192")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_step_192"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_step_192"))),
        bytes32(keccak256("rubber_lumber_step_192")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_step_192")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_fence_364")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Fence364",
        bytes32(keccak256("rubber_lumber_fence_364")),
        bytes32(keccak256("rubber_lumber_fence_364")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_fence_364"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_fence_364"))),
        bytes32(keccak256("rubber_lumber_fence_364")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_fence_364")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Black",
        bytes32(keccak256("oak_lumber_black")),
        bytes32(keccak256("oak_lumber_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_black"))),
        bytes32(keccak256("oak_lumber_black")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Slab128",
        bytes32(keccak256("moss_slab_128")),
        bytes32(keccak256("moss_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_128"))),
        bytes32(keccak256("moss_slab_128")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_full_64_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Full64 Green",
        bytes32(keccak256("oak_lumber_full_64_green")),
        bytes32(keccak256("oak_lumber_full_64_green")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_64_green"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_64_green"))),
        bytes32(keccak256("oak_lumber_full_64_green")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_full_64_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_log_outset_1193")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Log Outset1193",
        bytes32(keccak256("rubber_log_outset_1193")),
        bytes32(keccak256("rubber_log_outset_1193")),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_outset_1193"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_outset_1193"))),
        bytes32(keccak256("rubber_log_outset_1193")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_log_outset_1193")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_236_yellow")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step236 Yellow",
        bytes32(keccak256("cotton_fabric_step_236_yellow")),
        bytes32(keccak256("cotton_fabric_step_236_yellow")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_236_yellow"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_236_yellow"))),
        bytes32(keccak256("cotton_fabric_step_236_yellow")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_236_yellow")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_log_outset_1196")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Log Outset1196",
        bytes32(keccak256("rubber_log_outset_1196")),
        bytes32(keccak256("rubber_log_outset_1196")),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_outset_1196"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_log_outset_1196"))),
        bytes32(keccak256("rubber_log_outset_1196")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_log_outset_1196")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_236_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step236 Orange",
        bytes32(keccak256("cotton_fabric_step_236_orange")),
        bytes32(keccak256("cotton_fabric_step_236_orange")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_236_orange"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_236_orange"))),
        bytes32(keccak256("cotton_fabric_step_236_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_236_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_197_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step197 Orange",
        bytes32(keccak256("cotton_fabric_step_197_orange")),
        bytes32(keccak256("cotton_fabric_step_197_orange")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_197_orange"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_197_orange"))),
        bytes32(keccak256("cotton_fabric_step_197_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_197_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_reinforced_table_425")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Reinforced Table425",
        bytes32(keccak256("rubber_reinforced_table_425")),
        bytes32(keccak256("rubber_reinforced_table_425")),
        getChildVoxelTypes(bytes32(keccak256("rubber_reinforced_table_425"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_reinforced_table_425"))),
        bytes32(keccak256("rubber_reinforced_table_425")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_reinforced_table_425")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_192_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step192 Orange",
        bytes32(keccak256("cotton_fabric_step_192_orange")),
        bytes32(keccak256("cotton_fabric_step_192_orange")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_192_orange"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_192_orange"))),
        bytes32(keccak256("cotton_fabric_step_192_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_192_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_stool_1024")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Stool1024",
        bytes32(keccak256("clay_polished_stool_1024")),
        bytes32(keccak256("clay_polished_stool_1024")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stool_1024"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stool_1024"))),
        bytes32(keccak256("clay_polished_stool_1024")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_stool_1024")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_frame_640_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Frame640 White",
        bytes32(keccak256("oak_lumber_frame_640_white")),
        bytes32(keccak256("oak_lumber_frame_640_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_640_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_640_white"))),
        bytes32(keccak256("oak_lumber_frame_640_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_frame_640_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sunstone_log_256")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sunstone Log256",
        bytes32(keccak256("sunstone_log_256")),
        bytes32(keccak256("sunstone_log_256")),
        getChildVoxelTypes(bytes32(keccak256("sunstone_log_256"))),
        getChildVoxelTypes(bytes32(keccak256("sunstone_log_256"))),
        bytes32(keccak256("sunstone_log_256")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sunstone_log_256")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_199_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step199 Green",
        bytes32(keccak256("oak_lumber_step_199_green")),
        bytes32(keccak256("oak_lumber_step_199_green")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_199_green"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_199_green"))),
        bytes32(keccak256("oak_lumber_step_199_green")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_199_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_194_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step194 Green",
        bytes32(keccak256("oak_lumber_step_194_green")),
        bytes32(keccak256("oak_lumber_step_194_green")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_194_green"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_194_green"))),
        bytes32(keccak256("oak_lumber_step_194_green")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_194_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Slab172",
        bytes32(keccak256("cobblestone_brick_slab_172")),
        bytes32(keccak256("cobblestone_brick_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_172"))),
        bytes32(keccak256("cobblestone_brick_slab_172")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_133_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab133 Orange",
        bytes32(keccak256("cotton_fabric_slab_133_orange")),
        bytes32(keccak256("cotton_fabric_slab_133_orange")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_133_orange"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_133_orange"))),
        bytes32(keccak256("cotton_fabric_slab_133_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_133_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_325_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence325 Green",
        bytes32(keccak256("oak_lumber_fence_325_green")),
        bytes32(keccak256("oak_lumber_fence_325_green")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_325_green"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_325_green"))),
        bytes32(keccak256("oak_lumber_fence_325_green")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_325_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab169 Orange",
        bytes32(keccak256("cotton_fabric_slab_169_orange")),
        bytes32(keccak256("cotton_fabric_slab_169_orange")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169_orange"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169_orange"))),
        bytes32(keccak256("cotton_fabric_slab_169_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_233_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step233 Orange",
        bytes32(keccak256("cotton_fabric_step_233_orange")),
        bytes32(keccak256("cotton_fabric_step_233_orange")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_233_orange"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_233_orange"))),
        bytes32(keccak256("cotton_fabric_step_233_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_233_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_773_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg773 Green",
        bytes32(keccak256("oak_lumber_peg_773_green")),
        bytes32(keccak256("oak_lumber_peg_773_green")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_773_green"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_773_green"))),
        bytes32(keccak256("oak_lumber_peg_773_green")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_773_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1152_yellow")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1152 Yellow",
        bytes32(keccak256("cotton_fabric_outset_1152_yellow")),
        bytes32(keccak256("cotton_fabric_outset_1152_yellow")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1152_yellow"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1152_yellow"))),
        bytes32(keccak256("cotton_fabric_outset_1152_yellow")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1152_yellow")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1157_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1157 Blue",
        bytes32(keccak256("cotton_fabric_outset_1157_blue")),
        bytes32(keccak256("cotton_fabric_outset_1157_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1157_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1157_blue"))),
        bytes32(keccak256("cotton_fabric_outset_1157_blue")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1157_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_709_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice709 Black",
        bytes32(keccak256("cotton_fabric_slice_709_black")),
        bytes32(keccak256("cotton_fabric_slice_709_black")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_709_black"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_709_black"))),
        bytes32(keccak256("cotton_fabric_slice_709_black")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        7
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_709_black")));

    vm.stopBroadcast();
  }
}
