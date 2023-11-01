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

contract PostDeploy300 is Script {
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
        registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_wall_448")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Wall448",
        bytes32(keccak256("cobblestone_wall_448")),
        bytes32(keccak256("cobblestone_wall_448")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_wall_448"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_wall_448"))),
        bytes32(keccak256("cobblestone_wall_448")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_wall_448")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_wall_448")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Wall448",
        bytes32(keccak256("cobblestone_brick_wall_448")),
        bytes32(keccak256("cobblestone_brick_wall_448")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_wall_448"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_wall_448"))),
        bytes32(keccak256("cobblestone_brick_wall_448")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_wall_448")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_peg_809")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Peg809",
        bytes32(keccak256("rubber_lumber_peg_809")),
        bytes32(keccak256("rubber_lumber_peg_809")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_peg_809"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_peg_809"))),
        bytes32(keccak256("rubber_lumber_peg_809")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_peg_809")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_peg_773")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Peg773",
        bytes32(keccak256("rubber_lumber_peg_773")),
        bytes32(keccak256("rubber_lumber_peg_773")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_peg_773"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_peg_773"))),
        bytes32(keccak256("rubber_lumber_peg_773")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_peg_773")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Wall492",
        bytes32(keccak256("rubber_stripped_wall_492")),
        bytes32(keccak256("rubber_stripped_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_wall_492"))),
        bytes32(keccak256("rubber_stripped_wall_492")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_wall_492")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Wall489",
        bytes32(keccak256("rubber_lumber_wall_489")),
        bytes32(keccak256("rubber_lumber_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_wall_489"))),
        bytes32(keccak256("rubber_lumber_wall_489")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Wall492",
        bytes32(keccak256("cobblestone_wall_492")),
        bytes32(keccak256("cobblestone_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_wall_492"))),
        bytes32(keccak256("cobblestone_wall_492")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_wall_492")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_709")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice709",
        bytes32(keccak256("cotton_fabric_slice_709")),
        bytes32(keccak256("cotton_fabric_slice_709")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_709"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_709"))),
        bytes32(keccak256("cotton_fabric_slice_709")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_709")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_fence_320")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Fence320",
        bytes32(keccak256("rubber_lumber_fence_320")),
        bytes32(keccak256("rubber_lumber_fence_320")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_fence_320"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_fence_320"))),
        bytes32(keccak256("rubber_lumber_fence_320")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_fence_320")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_outset_1193")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Outset1193",
        bytes32(keccak256("neptunium_outset_1193")),
        bytes32(keccak256("neptunium_outset_1193")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_outset_1193"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_outset_1193"))),
        bytes32(keccak256("neptunium_outset_1193")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_outset_1193")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_outset_1157")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Outset1157",
        bytes32(keccak256("oak_stripped_outset_1157")),
        bytes32(keccak256("oak_stripped_outset_1157")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_outset_1157"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_outset_1157"))),
        bytes32(keccak256("oak_stripped_outset_1157")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_outset_1157")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1065")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Stool1065",
        bytes32(keccak256("rubber_stripped_stool_1065")),
        bytes32(keccak256("rubber_stripped_stool_1065")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1065"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1065"))),
        bytes32(keccak256("rubber_stripped_stool_1065")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1065")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Step199",
        bytes32(keccak256("rubber_lumber_step_199")),
        bytes32(keccak256("rubber_lumber_step_199")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_step_199"))),
        bytes32(keccak256("rubber_lumber_step_199")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_step_194")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Step194",
        bytes32(keccak256("rubber_stripped_step_194")),
        bytes32(keccak256("rubber_stripped_step_194")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_step_194"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_step_194"))),
        bytes32(keccak256("rubber_stripped_step_194")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_step_194")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Wall492",
        bytes32(keccak256("cobblestone_brick_wall_492")),
        bytes32(keccak256("cobblestone_brick_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_wall_492"))),
        bytes32(keccak256("cobblestone_brick_wall_492")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_wall_492")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_beam_1285_lightblue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Beam1285 Lightblue",
        bytes32(keccak256("led_beam_1285_lightblue")),
        bytes32(keccak256("led_beam_1285_lightblue")),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1285_lightblue"))),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1285_lightblue"))),
        bytes32(keccak256("led_beam_1285_lightblue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_beam_1285_lightblue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_polished_beam_1324")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Polished Beam1324",
        bytes32(keccak256("basalt_polished_beam_1324")),
        bytes32(keccak256("basalt_polished_beam_1324")),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished_beam_1324"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished_beam_1324"))),
        bytes32(keccak256("basalt_polished_beam_1324")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_polished_beam_1324")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Step236",
        bytes32(keccak256("cobblestone_brick_step_236")),
        bytes32(keccak256("cobblestone_brick_step_236")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_step_236"))),
        bytes32(keccak256("cobblestone_brick_step_236")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Step236",
        bytes32(keccak256("cobblestone_step_236")),
        bytes32(keccak256("cobblestone_step_236")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_step_236"))),
        bytes32(keccak256("cobblestone_step_236")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_slab_171")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Slab171",
        bytes32(keccak256("cobblestone_slab_171")),
        bytes32(keccak256("cobblestone_slab_171")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_171"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_171"))),
        bytes32(keccak256("cobblestone_slab_171")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_slab_171")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Slab169",
        bytes32(keccak256("cobblestone_slab_169")),
        bytes32(keccak256("cobblestone_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_169"))),
        bytes32(keccak256("cobblestone_slab_169")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_step_192")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Step192",
        bytes32(keccak256("cobblestone_step_192")),
        bytes32(keccak256("cobblestone_step_192")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_step_192"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_step_192"))),
        bytes32(keccak256("cobblestone_step_192")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_step_192")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Slab128",
        bytes32(keccak256("cobblestone_slab_128")),
        bytes32(keccak256("cobblestone_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_128"))),
        bytes32(keccak256("cobblestone_slab_128")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_slab_174")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Slab174",
        bytes32(keccak256("cobblestone_slab_174")),
        bytes32(keccak256("cobblestone_slab_174")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_174"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_174"))),
        bytes32(keccak256("cobblestone_slab_174")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_slab_174")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Slab130",
        bytes32(keccak256("cobblestone_slab_130")),
        bytes32(keccak256("cobblestone_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_130"))),
        bytes32(keccak256("cobblestone_slab_130")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_slab_135")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Slab135",
        bytes32(keccak256("cobblestone_slab_135")),
        bytes32(keccak256("cobblestone_slab_135")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_135"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_135"))),
        bytes32(keccak256("cobblestone_slab_135")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_slab_135")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_stool_1065")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Stool1065",
        bytes32(keccak256("rubber_lumber_stool_1065")),
        bytes32(keccak256("rubber_lumber_stool_1065")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_stool_1065"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_stool_1065"))),
        bytes32(keccak256("rubber_lumber_stool_1065")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_stool_1065")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_stool_1024")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Stool1024",
        bytes32(keccak256("rubber_lumber_stool_1024")),
        bytes32(keccak256("rubber_lumber_stool_1024")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_stool_1024"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_stool_1024"))),
        bytes32(keccak256("rubber_lumber_stool_1024")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_stool_1024")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_stool_1029")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Stool1029",
        bytes32(keccak256("rubber_lumber_stool_1029")),
        bytes32(keccak256("rubber_lumber_stool_1029")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_stool_1029"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_stool_1029"))),
        bytes32(keccak256("rubber_lumber_stool_1029")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_stool_1029")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1024")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Stool1024",
        bytes32(keccak256("rubber_stripped_stool_1024")),
        bytes32(keccak256("rubber_stripped_stool_1024")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1024"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1024"))),
        bytes32(keccak256("rubber_stripped_stool_1024")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1024")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_log_261")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Log261",
        bytes32(keccak256("clay_log_261")),
        bytes32(keccak256("clay_log_261")),
        getChildVoxelTypes(bytes32(keccak256("clay_log_261"))),
        getChildVoxelTypes(bytes32(keccak256("clay_log_261"))),
        bytes32(keccak256("clay_log_261")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_log_261")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step233",
        bytes32(keccak256("oak_lumber_step_233")),
        bytes32(keccak256("oak_lumber_step_233")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_233"))),
        bytes32(keccak256("oak_lumber_step_233")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Step197",
        bytes32(keccak256("cobblestone_brick_step_197")),
        bytes32(keccak256("cobblestone_brick_step_197")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_step_197"))),
        bytes32(keccak256("cobblestone_brick_step_197")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_peg_768")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Peg768",
        bytes32(keccak256("rubber_lumber_peg_768")),
        bytes32(keccak256("rubber_lumber_peg_768")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_peg_768"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_peg_768"))),
        bytes32(keccak256("rubber_lumber_peg_768")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_peg_768")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Slab169",
        bytes32(keccak256("oak_stripped_slab_169")),
        bytes32(keccak256("oak_stripped_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slab_169"))),
        bytes32(keccak256("oak_stripped_slab_169")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab169",
        bytes32(keccak256("oak_lumber_slab_169")),
        bytes32(keccak256("oak_lumber_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_169"))),
        bytes32(keccak256("oak_lumber_slab_169")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("quartzite_shingles_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Quartzite Shingles Slab169",
        bytes32(keccak256("quartzite_shingles_slab_169")),
        bytes32(keccak256("quartzite_shingles_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("quartzite_shingles_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("quartzite_shingles_slab_169"))),
        bytes32(keccak256("quartzite_shingles_slab_169")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("quartzite_shingles_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("quartzite_shingles_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Quartzite Shingles Slab133",
        bytes32(keccak256("quartzite_shingles_slab_133")),
        bytes32(keccak256("quartzite_shingles_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("quartzite_shingles_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("quartzite_shingles_slab_133"))),
        bytes32(keccak256("quartzite_shingles_slab_133")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("quartzite_shingles_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("quartzite_shingles_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Quartzite Shingles Slab128",
        bytes32(keccak256("quartzite_shingles_slab_128")),
        bytes32(keccak256("quartzite_shingles_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("quartzite_shingles_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("quartzite_shingles_slab_128"))),
        bytes32(keccak256("quartzite_shingles_slab_128")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("quartzite_shingles_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("quartzite_shingles_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Quartzite Shingles Slab172",
        bytes32(keccak256("quartzite_shingles_slab_172")),
        bytes32(keccak256("quartzite_shingles_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("quartzite_shingles_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("quartzite_shingles_slab_172"))),
        bytes32(keccak256("quartzite_shingles_slab_172")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("quartzite_shingles_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("quartzite_shingles")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Quartzite Shingles",
        bytes32(keccak256("quartzite_shingles")),
        bytes32(keccak256("quartzite_shingles")),
        getChildVoxelTypes(bytes32(keccak256("quartzite_shingles"))),
        getChildVoxelTypes(bytes32(keccak256("quartzite_shingles"))),
        bytes32(keccak256("quartzite_shingles")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("quartzite_shingles")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_fence_361")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Fence361",
        bytes32(keccak256("rubber_lumber_fence_361")),
        bytes32(keccak256("rubber_lumber_fence_361")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_fence_361"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_fence_361"))),
        bytes32(keccak256("rubber_lumber_fence_361")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_fence_361")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1152")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1152",
        bytes32(keccak256("cotton_fabric_outset_1152")),
        bytes32(keccak256("cotton_fabric_outset_1152")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1152"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1152"))),
        bytes32(keccak256("cotton_fabric_outset_1152")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1152")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_slab_135")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Slab135",
        bytes32(keccak256("rubber_lumber_slab_135")),
        bytes32(keccak256("rubber_lumber_slab_135")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_slab_135"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_slab_135"))),
        bytes32(keccak256("rubber_lumber_slab_135")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_slab_135")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_log_300")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Log300",
        bytes32(keccak256("clay_log_300")),
        bytes32(keccak256("clay_log_300")),
        getChildVoxelTypes(bytes32(keccak256("clay_log_300"))),
        getChildVoxelTypes(bytes32(keccak256("clay_log_300"))),
        bytes32(keccak256("clay_log_300")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_log_300")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_slab_135")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Slab135",
        bytes32(keccak256("rubber_stripped_slab_135")),
        bytes32(keccak256("rubber_stripped_slab_135")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_slab_135"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_slab_135"))),
        bytes32(keccak256("rubber_stripped_slab_135")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_slab_135")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_table_389")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Table389",
        bytes32(keccak256("oak_lumber_table_389")),
        bytes32(keccak256("oak_lumber_table_389")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_table_389"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_table_389"))),
        bytes32(keccak256("oak_lumber_table_389")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_table_389")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_step_235")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Step235",
        bytes32(keccak256("rubber_lumber_step_235")),
        bytes32(keccak256("rubber_lumber_step_235")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_step_235"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_step_235"))),
        bytes32(keccak256("rubber_lumber_step_235")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_step_235")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Step197",
        bytes32(keccak256("cobblestone_step_197")),
        bytes32(keccak256("cobblestone_step_197")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_step_197"))),
        bytes32(keccak256("cobblestone_step_197")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_outset_1196")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Outset1196",
        bytes32(keccak256("oak_lumber_outset_1196")),
        bytes32(keccak256("oak_lumber_outset_1196")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1196"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1196"))),
        bytes32(keccak256("oak_lumber_outset_1196")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_outset_1196")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_748")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice748",
        bytes32(keccak256("cotton_fabric_slice_748")),
        bytes32(keccak256("cotton_fabric_slice_748")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_748"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_748"))),
        bytes32(keccak256("cotton_fabric_slice_748")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_748")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_fence_361")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Fence361",
        bytes32(keccak256("rubber_stripped_fence_361")),
        bytes32(keccak256("rubber_stripped_fence_361")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_fence_361"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_fence_361"))),
        bytes32(keccak256("rubber_stripped_fence_361")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_fence_361")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_outset_1196")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Outset1196",
        bytes32(keccak256("rubber_stripped_outset_1196")),
        bytes32(keccak256("rubber_stripped_outset_1196")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_outset_1196"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_outset_1196"))),
        bytes32(keccak256("rubber_stripped_outset_1196")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_outset_1196")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_outset_1196")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Outset1196",
        bytes32(keccak256("rubber_lumber_outset_1196")),
        bytes32(keccak256("rubber_lumber_outset_1196")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_outset_1196"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_outset_1196"))),
        bytes32(keccak256("rubber_lumber_outset_1196")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_outset_1196")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Step233",
        bytes32(keccak256("cobblestone_step_233")),
        bytes32(keccak256("cobblestone_step_233")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_step_233"))),
        bytes32(keccak256("cobblestone_step_233")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_outset_1195")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Outset1195",
        bytes32(keccak256("oak_stripped_outset_1195")),
        bytes32(keccak256("oak_stripped_outset_1195")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_outset_1195"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_outset_1195"))),
        bytes32(keccak256("oak_stripped_outset_1195")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_outset_1195")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_outset_1196")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Outset1196",
        bytes32(keccak256("silver_outset_1196")),
        bytes32(keccak256("silver_outset_1196")),
        getChildVoxelTypes(bytes32(keccak256("silver_outset_1196"))),
        getChildVoxelTypes(bytes32(keccak256("silver_outset_1196"))),
        bytes32(keccak256("silver_outset_1196")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_outset_1196")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_outset_1193")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Outset1193",
        bytes32(keccak256("oak_stripped_outset_1193")),
        bytes32(keccak256("oak_stripped_outset_1193")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_outset_1193"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_outset_1193"))),
        bytes32(keccak256("oak_stripped_outset_1193")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_outset_1193")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_outset_1193")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Outset1193",
        bytes32(keccak256("oak_lumber_outset_1193")),
        bytes32(keccak256("oak_lumber_outset_1193")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1193"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1193"))),
        bytes32(keccak256("oak_lumber_outset_1193")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_outset_1193")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Step199",
        bytes32(keccak256("rubber_stripped_step_199")),
        bytes32(keccak256("rubber_stripped_step_199")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_step_199"))),
        bytes32(keccak256("rubber_stripped_step_199")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_step_194")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Step194",
        bytes32(keccak256("rubber_lumber_step_194")),
        bytes32(keccak256("rubber_lumber_step_194")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_step_194"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_step_194"))),
        bytes32(keccak256("rubber_lumber_step_194")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_step_194")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_beam_1321_lightblue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Beam1321 Lightblue",
        bytes32(keccak256("led_beam_1321_lightblue")),
        bytes32(keccak256("led_beam_1321_lightblue")),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1321_lightblue"))),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1321_lightblue"))),
        bytes32(keccak256("led_beam_1321_lightblue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_beam_1321_lightblue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_wall_453")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Wall453",
        bytes32(keccak256("cobblestone_wall_453")),
        bytes32(keccak256("cobblestone_wall_453")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_wall_453"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_wall_453"))),
        bytes32(keccak256("cobblestone_wall_453")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_wall_453")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Slab172",
        bytes32(keccak256("cobblestone_slab_172")),
        bytes32(keccak256("cobblestone_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_172"))),
        bytes32(keccak256("cobblestone_slab_172")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Slab133",
        bytes32(keccak256("cobblestone_slab_133")),
        bytes32(keccak256("cobblestone_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_slab_133"))),
        bytes32(keccak256("cobblestone_slab_133")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Wall489",
        bytes32(keccak256("cobblestone_brick_wall_489")),
        bytes32(keccak256("cobblestone_brick_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_wall_489"))),
        bytes32(keccak256("cobblestone_brick_wall_489")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_wall_453")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Wall453",
        bytes32(keccak256("rubber_lumber_wall_453")),
        bytes32(keccak256("rubber_lumber_wall_453")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_wall_453"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_wall_453"))),
        bytes32(keccak256("rubber_lumber_wall_453")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_wall_453")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_wall_448")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Wall448",
        bytes32(keccak256("rubber_lumber_wall_448")),
        bytes32(keccak256("rubber_lumber_wall_448")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_wall_448"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_wall_448"))),
        bytes32(keccak256("rubber_lumber_wall_448")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_wall_448")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_bush")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Bush",
        bytes32(keccak256("cotton_bush")),
        bytes32(keccak256("cotton_bush")),
        getChildVoxelTypes(bytes32(keccak256("cotton_bush"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_bush"))),
        bytes32(keccak256("cotton_bush")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_bush")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("dandelion_flower")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Dandelion Flower",
        bytes32(keccak256("dandelion_flower")),
        bytes32(keccak256("dandelion_flower")),
        getChildVoxelTypes(bytes32(keccak256("dandelion_flower"))),
        getChildVoxelTypes(bytes32(keccak256("dandelion_flower"))),
        bytes32(keccak256("dandelion_flower")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("dandelion_flower")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped",
        bytes32(keccak256("rubber_stripped")),
        bytes32(keccak256("rubber_stripped")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped"))),
        bytes32(keccak256("rubber_stripped")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_172_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab172 White",
        bytes32(keccak256("oak_lumber_slab_172_white")),
        bytes32(keccak256("oak_lumber_slab_172_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_172_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_172_white"))),
        bytes32(keccak256("oak_lumber_slab_172_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_172_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Blue",
        bytes32(keccak256("oak_lumber_blue")),
        bytes32(keccak256("oak_lumber_blue")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_blue"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_blue"))),
        bytes32(keccak256("oak_lumber_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_448_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall448 Blue",
        bytes32(keccak256("oak_lumber_wall_448_blue")),
        bytes32(keccak256("oak_lumber_wall_448_blue")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_448_blue"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_448_blue"))),
        bytes32(keccak256("oak_lumber_wall_448_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_448_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_773_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg773 White",
        bytes32(keccak256("oak_lumber_peg_773_white")),
        bytes32(keccak256("oak_lumber_peg_773_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_773_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_773_white"))),
        bytes32(keccak256("oak_lumber_peg_773_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_773_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_745_yellow")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice745 Yellow",
        bytes32(keccak256("cotton_fabric_slice_745_yellow")),
        bytes32(keccak256("cotton_fabric_slice_745_yellow")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_745_yellow"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_745_yellow"))),
        bytes32(keccak256("cotton_fabric_slice_745_yellow")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_745_yellow")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_704_yellow")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice704 Yellow",
        bytes32(keccak256("cotton_fabric_slice_704_yellow")),
        bytes32(keccak256("cotton_fabric_slice_704_yellow")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_704_yellow"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_704_yellow"))),
        bytes32(keccak256("cotton_fabric_slice_704_yellow")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_704_yellow")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_log_frame_645")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Log Frame645",
        bytes32(keccak256("birch_log_frame_645")),
        bytes32(keccak256("birch_log_frame_645")),
        getChildVoxelTypes(bytes32(keccak256("birch_log_frame_645"))),
        getChildVoxelTypes(bytes32(keccak256("birch_log_frame_645"))),
        bytes32(keccak256("birch_log_frame_645")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_log_frame_645")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_453_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall453 Blue",
        bytes32(keccak256("oak_lumber_wall_453_blue")),
        bytes32(keccak256("oak_lumber_wall_453_blue")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_453_blue"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_453_blue"))),
        bytes32(keccak256("oak_lumber_wall_453_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_453_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169_yellow")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab169 Yellow",
        bytes32(keccak256("cotton_fabric_slab_169_yellow")),
        bytes32(keccak256("cotton_fabric_slab_169_yellow")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169_yellow"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169_yellow"))),
        bytes32(keccak256("cotton_fabric_slab_169_yellow")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169_yellow")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("thatch_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Thatch Step233",
        bytes32(keccak256("thatch_step_233")),
        bytes32(keccak256("thatch_step_233")),
        getChildVoxelTypes(bytes32(keccak256("thatch_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("thatch_step_233"))),
        bytes32(keccak256("thatch_step_233")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("thatch_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_812_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg812 White",
        bytes32(keccak256("oak_lumber_peg_812_white")),
        bytes32(keccak256("oak_lumber_peg_812_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_812_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_812_white"))),
        bytes32(keccak256("oak_lumber_peg_812_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_812_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_wall_453")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Wall453",
        bytes32(keccak256("cobblestone_brick_wall_453")),
        bytes32(keccak256("cobblestone_brick_wall_453")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_wall_453"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_wall_453"))),
        bytes32(keccak256("cobblestone_brick_wall_453")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_wall_453")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_320_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence320 White",
        bytes32(keccak256("oak_lumber_fence_320_white")),
        bytes32(keccak256("oak_lumber_fence_320_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_320_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_320_white"))),
        bytes32(keccak256("oak_lumber_fence_320_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_320_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_364_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence364 White",
        bytes32(keccak256("oak_lumber_fence_364_white")),
        bytes32(keccak256("oak_lumber_fence_364_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_364_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_364_white"))),
        bytes32(keccak256("oak_lumber_fence_364_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_364_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_fence_364")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Fence364",
        bytes32(keccak256("cotton_fabric_fence_364")),
        bytes32(keccak256("cotton_fabric_fence_364")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_fence_364"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_fence_364"))),
        bytes32(keccak256("cotton_fabric_fence_364")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_fence_364")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_768_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg768 White",
        bytes32(keccak256("oak_lumber_peg_768_white")),
        bytes32(keccak256("oak_lumber_peg_768_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_768_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_768_white"))),
        bytes32(keccak256("oak_lumber_peg_768_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_768_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_135_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab135 Blue",
        bytes32(keccak256("oak_lumber_slab_135_blue")),
        bytes32(keccak256("oak_lumber_slab_135_blue")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_135_blue"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_135_blue"))),
        bytes32(keccak256("oak_lumber_slab_135_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_135_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_197_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step197 White",
        bytes32(keccak256("oak_lumber_step_197_white")),
        bytes32(keccak256("oak_lumber_step_197_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_197_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_197_white"))),
        bytes32(keccak256("oak_lumber_step_197_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_197_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_192_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step192 White",
        bytes32(keccak256("oak_lumber_step_192_white")),
        bytes32(keccak256("oak_lumber_step_192_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_192_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_192_white"))),
        bytes32(keccak256("oak_lumber_step_192_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_192_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Step233",
        bytes32(keccak256("cobblestone_brick_step_233")),
        bytes32(keccak256("cobblestone_brick_step_233")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_step_233"))),
        bytes32(keccak256("cobblestone_brick_step_233")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_135")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Slab135",
        bytes32(keccak256("cobblestone_brick_slab_135")),
        bytes32(keccak256("cobblestone_brick_slab_135")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_135"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_135"))),
        bytes32(keccak256("cobblestone_brick_slab_135")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_135")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1157")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1157",
        bytes32(keccak256("cotton_fabric_outset_1157")),
        bytes32(keccak256("cotton_fabric_outset_1157")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1157"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1157"))),
        bytes32(keccak256("cotton_fabric_outset_1157")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1157")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step199",
        bytes32(keccak256("cotton_fabric_step_199")),
        bytes32(keccak256("cotton_fabric_step_199")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_199"))),
        bytes32(keccak256("cotton_fabric_step_199")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_log_frame_684")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Log Frame684",
        bytes32(keccak256("birch_log_frame_684")),
        bytes32(keccak256("birch_log_frame_684")),
        getChildVoxelTypes(bytes32(keccak256("birch_log_frame_684"))),
        getChildVoxelTypes(bytes32(keccak256("birch_log_frame_684"))),
        bytes32(keccak256("birch_log_frame_684")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_log_frame_684")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sunstone")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sunstone",
        bytes32(keccak256("sunstone")),
        bytes32(keccak256("sunstone")),
        getChildVoxelTypes(bytes32(keccak256("sunstone"))),
        getChildVoxelTypes(bytes32(keccak256("sunstone"))),
        bytes32(keccak256("sunstone")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sunstone")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_log_frame_640")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Log Frame640",
        bytes32(keccak256("birch_log_frame_640")),
        bytes32(keccak256("birch_log_frame_640")),
        getChildVoxelTypes(bytes32(keccak256("birch_log_frame_640"))),
        getChildVoxelTypes(bytes32(keccak256("birch_log_frame_640"))),
        bytes32(keccak256("birch_log_frame_640")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_log_frame_640")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_log_frame_681")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Log Frame681",
        bytes32(keccak256("birch_log_frame_681")),
        bytes32(keccak256("birch_log_frame_681")),
        getChildVoxelTypes(bytes32(keccak256("birch_log_frame_681"))),
        getChildVoxelTypes(bytes32(keccak256("birch_log_frame_681"))),
        bytes32(keccak256("birch_log_frame_681")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_log_frame_681")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_step_194")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Step194",
        bytes32(keccak256("basalt_shingles_step_194")),
        bytes32(keccak256("basalt_shingles_step_194")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_194"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_194"))),
        bytes32(keccak256("basalt_shingles_step_194")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_step_194")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles",
        bytes32(keccak256("basalt_shingles")),
        bytes32(keccak256("basalt_shingles")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles"))),
        bytes32(keccak256("basalt_shingles")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles")));

    vm.stopBroadcast();
  }
}
