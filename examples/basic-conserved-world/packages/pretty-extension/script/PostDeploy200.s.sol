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

contract PostDeploy200 is Script {
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
        registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_peg_768")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Peg768",
        bytes32(keccak256("rubber_stripped_peg_768")),
        bytes32(keccak256("rubber_stripped_peg_768")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_peg_768"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_peg_768"))),
        bytes32(keccak256("rubber_stripped_peg_768")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_peg_768")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_wall_448")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Wall448",
        bytes32(keccak256("hay_wall_448")),
        bytes32(keccak256("hay_wall_448")),
        getChildVoxelTypes(bytes32(keccak256("hay_wall_448"))),
        getChildVoxelTypes(bytes32(keccak256("hay_wall_448"))),
        bytes32(keccak256("hay_wall_448")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_wall_448")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_full_69")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Full69",
        bytes32(keccak256("oak_lumber_full_69")),
        bytes32(keccak256("oak_lumber_full_69")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_69"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_69"))),
        bytes32(keccak256("oak_lumber_full_69")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_full_69")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("wood_crate_slice_711")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Wood Crate Slice711",
        bytes32(keccak256("wood_crate_slice_711")),
        bytes32(keccak256("wood_crate_slice_711")),
        getChildVoxelTypes(bytes32(keccak256("wood_crate_slice_711"))),
        getChildVoxelTypes(bytes32(keccak256("wood_crate_slice_711"))),
        bytes32(keccak256("wood_crate_slice_711")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("wood_crate_slice_711")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_outset_1196")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Outset1196",
        bytes32(keccak256("hay_outset_1196")),
        bytes32(keccak256("hay_outset_1196")),
        getChildVoxelTypes(bytes32(keccak256("hay_outset_1196"))),
        getChildVoxelTypes(bytes32(keccak256("hay_outset_1196"))),
        bytes32(keccak256("hay_outset_1196")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_outset_1196")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_knob_901")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Knob901",
        bytes32(keccak256("moss_knob_901")),
        bytes32(keccak256("moss_knob_901")),
        getChildVoxelTypes(bytes32(keccak256("moss_knob_901"))),
        getChildVoxelTypes(bytes32(keccak256("moss_knob_901"))),
        bytes32(keccak256("moss_knob_901")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_knob_901")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Step233",
        bytes32(keccak256("moss_step_233")),
        bytes32(keccak256("moss_step_233")),
        getChildVoxelTypes(bytes32(keccak256("moss_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("moss_step_233"))),
        bytes32(keccak256("moss_step_233")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_knob_940")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Knob940",
        bytes32(keccak256("moss_knob_940")),
        bytes32(keccak256("moss_knob_940")),
        getChildVoxelTypes(bytes32(keccak256("moss_knob_940"))),
        getChildVoxelTypes(bytes32(keccak256("moss_knob_940"))),
        bytes32(keccak256("moss_knob_940")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_knob_940")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_stub_1262_tan")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Stub1262 Tan",
        bytes32(keccak256("led_stub_1262_tan")),
        bytes32(keccak256("led_stub_1262_tan")),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1262_tan"))),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1262_tan"))),
        bytes32(keccak256("led_stub_1262_tan")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_stub_1262_tan")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_stub_1218_tan")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Stub1218 Tan",
        bytes32(keccak256("led_stub_1218_tan")),
        bytes32(keccak256("led_stub_1218_tan")),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1218_tan"))),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1218_tan"))),
        bytes32(keccak256("led_stub_1218_tan")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_stub_1218_tan")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_slice_709")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Slice709",
        bytes32(keccak256("hay_slice_709")),
        bytes32(keccak256("hay_slice_709")),
        getChildVoxelTypes(bytes32(keccak256("hay_slice_709"))),
        getChildVoxelTypes(bytes32(keccak256("hay_slice_709"))),
        bytes32(keccak256("hay_slice_709")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_slice_709")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_stub_1223_tan")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Stub1223 Tan",
        bytes32(keccak256("led_stub_1223_tan")),
        bytes32(keccak256("led_stub_1223_tan")),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1223_tan"))),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1223_tan"))),
        bytes32(keccak256("led_stub_1223_tan")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_stub_1223_tan")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_full_108")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Full108",
        bytes32(keccak256("oak_lumber_full_108")),
        bytes32(keccak256("oak_lumber_full_108")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_108"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_108"))),
        bytes32(keccak256("oak_lumber_full_108")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_full_108")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_knob_937")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Knob937",
        bytes32(keccak256("moss_knob_937")),
        bytes32(keccak256("moss_knob_937")),
        getChildVoxelTypes(bytes32(keccak256("moss_knob_937"))),
        getChildVoxelTypes(bytes32(keccak256("moss_knob_937"))),
        bytes32(keccak256("moss_knob_937")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_knob_937")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Step236",
        bytes32(keccak256("moss_step_236")),
        bytes32(keccak256("moss_step_236")),
        getChildVoxelTypes(bytes32(keccak256("moss_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("moss_step_236"))),
        bytes32(keccak256("moss_step_236")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_knob_896")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Knob896",
        bytes32(keccak256("moss_knob_896")),
        bytes32(keccak256("moss_knob_896")),
        getChildVoxelTypes(bytes32(keccak256("moss_knob_896"))),
        getChildVoxelTypes(bytes32(keccak256("moss_knob_896"))),
        bytes32(keccak256("moss_knob_896")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_knob_896")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss",
        bytes32(keccak256("moss")),
        bytes32(keccak256("moss")),
        getChildVoxelTypes(bytes32(keccak256("moss"))),
        getChildVoxelTypes(bytes32(keccak256("moss"))),
        bytes32(keccak256("moss")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_full_105")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Full105",
        bytes32(keccak256("moss_full_105")),
        bytes32(keccak256("moss_full_105")),
        getChildVoxelTypes(bytes32(keccak256("moss_full_105"))),
        getChildVoxelTypes(bytes32(keccak256("moss_full_105"))),
        bytes32(keccak256("moss_full_105")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_full_105")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Slab169",
        bytes32(keccak256("moss_slab_169")),
        bytes32(keccak256("moss_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_169"))),
        bytes32(keccak256("moss_slab_169")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_beam_1321_silver")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Beam1321 Silver",
        bytes32(keccak256("cotton_fabric_beam_1321_silver")),
        bytes32(keccak256("cotton_fabric_beam_1321_silver")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_beam_1321_silver"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_beam_1321_silver"))),
        bytes32(keccak256("cotton_fabric_beam_1321_silver")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_beam_1321_silver")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_fence_364_silver")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Fence364 Silver",
        bytes32(keccak256("cotton_fabric_fence_364_silver")),
        bytes32(keccak256("cotton_fabric_fence_364_silver")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_fence_364_silver"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_fence_364_silver"))),
        bytes32(keccak256("cotton_fabric_fence_364_silver")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_fence_364_silver")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_beam_1324_silver")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Beam1324 Silver",
        bytes32(keccak256("cotton_fabric_beam_1324_silver")),
        bytes32(keccak256("cotton_fabric_beam_1324_silver")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_beam_1324_silver"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_beam_1324_silver"))),
        bytes32(keccak256("cotton_fabric_beam_1324_silver")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_beam_1324_silver")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_reinforced_ellPeg_1536")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Reinforced Ell Peg1536",
        bytes32(keccak256("rubber_reinforced_ellPeg_1536")),
        bytes32(keccak256("rubber_reinforced_ellPeg_1536")),
        getChildVoxelTypes(bytes32(keccak256("rubber_reinforced_ellPeg_1536"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_reinforced_ellPeg_1536"))),
        bytes32(keccak256("rubber_reinforced_ellPeg_1536")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_reinforced_ellPeg_1536")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall489",
        bytes32(keccak256("cotton_fabric_wall_489")),
        bytes32(keccak256("cotton_fabric_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_489"))),
        bytes32(keccak256("cotton_fabric_wall_489")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_174")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab174",
        bytes32(keccak256("cotton_fabric_slab_174")),
        bytes32(keccak256("cotton_fabric_slab_174")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_174"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_174"))),
        bytes32(keccak256("cotton_fabric_slab_174")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_174")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab172",
        bytes32(keccak256("cotton_fabric_slab_172")),
        bytes32(keccak256("cotton_fabric_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_172"))),
        bytes32(keccak256("cotton_fabric_slab_172")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Wall489",
        bytes32(keccak256("moss_wall_489")),
        bytes32(keccak256("moss_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("moss_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("moss_wall_489"))),
        bytes32(keccak256("moss_wall_489")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_slab_135")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Slab135",
        bytes32(keccak256("moss_slab_135")),
        bytes32(keccak256("moss_slab_135")),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_135"))),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_135"))),
        bytes32(keccak256("moss_slab_135")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_slab_135")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Slab172",
        bytes32(keccak256("moss_slab_172")),
        bytes32(keccak256("moss_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_172"))),
        bytes32(keccak256("moss_slab_172")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab128",
        bytes32(keccak256("cotton_fabric_slab_128")),
        bytes32(keccak256("cotton_fabric_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_128"))),
        bytes32(keccak256("cotton_fabric_slab_128")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Slab133",
        bytes32(keccak256("moss_slab_133")),
        bytes32(keccak256("moss_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_133"))),
        bytes32(keccak256("moss_slab_133")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab130",
        bytes32(keccak256("cotton_fabric_slab_130")),
        bytes32(keccak256("cotton_fabric_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_130"))),
        bytes32(keccak256("cotton_fabric_slab_130")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_slab_174")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Slab174",
        bytes32(keccak256("moss_slab_174")),
        bytes32(keccak256("moss_slab_174")),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_174"))),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_174"))),
        bytes32(keccak256("moss_slab_174")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_slab_174")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab169",
        bytes32(keccak256("cotton_fabric_slab_169")),
        bytes32(keccak256("cotton_fabric_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169"))),
        bytes32(keccak256("cotton_fabric_slab_169")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hemp_bush")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hemp Bush",
        bytes32(keccak256("hemp_bush")),
        bytes32(keccak256("hemp_bush")),
        getChildVoxelTypes(bytes32(keccak256("hemp_bush"))),
        getChildVoxelTypes(bytes32(keccak256("hemp_bush"))),
        bytes32(keccak256("hemp_bush")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hemp_bush")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_full_64_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Full64 White",
        bytes32(keccak256("oak_lumber_full_64_white")),
        bytes32(keccak256("oak_lumber_full_64_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_64_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_64_white"))),
        bytes32(keccak256("oak_lumber_full_64_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_full_64_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_full_64_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Full64 Red",
        bytes32(keccak256("oak_lumber_full_64_red")),
        bytes32(keccak256("oak_lumber_full_64_red")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_64_red"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_64_red"))),
        bytes32(keccak256("oak_lumber_full_64_red")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_full_64_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber White",
        bytes32(keccak256("oak_lumber_white")),
        bytes32(keccak256("oak_lumber_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_white"))),
        bytes32(keccak256("oak_lumber_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_448_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall448 White",
        bytes32(keccak256("oak_lumber_wall_448_white")),
        bytes32(keccak256("oak_lumber_wall_448_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_448_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_448_white"))),
        bytes32(keccak256("oak_lumber_wall_448_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_448_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Slab172",
        bytes32(keccak256("hay_slab_172")),
        bytes32(keccak256("hay_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("hay_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("hay_slab_172"))),
        bytes32(keccak256("hay_slab_172")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Wall489",
        bytes32(keccak256("hay_wall_489")),
        bytes32(keccak256("hay_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("hay_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("hay_wall_489"))),
        bytes32(keccak256("hay_wall_489")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Wall492",
        bytes32(keccak256("hay_wall_492")),
        bytes32(keccak256("hay_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("hay_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("hay_wall_492"))),
        bytes32(keccak256("hay_wall_492")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_wall_492")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_slice_748")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Slice748",
        bytes32(keccak256("hay_slice_748")),
        bytes32(keccak256("hay_slice_748")),
        getChildVoxelTypes(bytes32(keccak256("hay_slice_748"))),
        getChildVoxelTypes(bytes32(keccak256("hay_slice_748"))),
        bytes32(keccak256("hay_slice_748")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_slice_748")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_453_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall453 White",
        bytes32(keccak256("oak_lumber_wall_453_white")),
        bytes32(keccak256("oak_lumber_wall_453_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_453_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_453_white"))),
        bytes32(keccak256("oak_lumber_wall_453_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_453_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("thatch_fence_364")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Thatch Fence364",
        bytes32(keccak256("thatch_fence_364")),
        bytes32(keccak256("thatch_fence_364")),
        getChildVoxelTypes(bytes32(keccak256("thatch_fence_364"))),
        getChildVoxelTypes(bytes32(keccak256("thatch_fence_364"))),
        bytes32(keccak256("thatch_fence_364")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("thatch_fence_364")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Slab128",
        bytes32(keccak256("hay_slab_128")),
        bytes32(keccak256("hay_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("hay_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("hay_slab_128"))),
        bytes32(keccak256("hay_slab_128")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_slice_745")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Slice745",
        bytes32(keccak256("hay_slice_745")),
        bytes32(keccak256("hay_slice_745")),
        getChildVoxelTypes(bytes32(keccak256("hay_slice_745"))),
        getChildVoxelTypes(bytes32(keccak256("hay_slice_745"))),
        bytes32(keccak256("hay_slice_745")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_slice_745")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_slice_704")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Slice704",
        bytes32(keccak256("hay_slice_704")),
        bytes32(keccak256("hay_slice_704")),
        getChildVoxelTypes(bytes32(keccak256("hay_slice_704"))),
        getChildVoxelTypes(bytes32(keccak256("hay_slice_704"))),
        bytes32(keccak256("hay_slice_704")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_slice_704")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_frame_681_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Frame681 White",
        bytes32(keccak256("oak_lumber_frame_681_white")),
        bytes32(keccak256("oak_lumber_frame_681_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_681_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_681_white"))),
        bytes32(keccak256("oak_lumber_frame_681_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_frame_681_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_outset_1193")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Outset1193",
        bytes32(keccak256("hay_outset_1193")),
        bytes32(keccak256("hay_outset_1193")),
        getChildVoxelTypes(bytes32(keccak256("hay_outset_1193"))),
        getChildVoxelTypes(bytes32(keccak256("hay_outset_1193"))),
        bytes32(keccak256("hay_outset_1193")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_outset_1193")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_beam_1280_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Beam1280 White",
        bytes32(keccak256("oak_lumber_beam_1280_white")),
        bytes32(keccak256("oak_lumber_beam_1280_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_beam_1280_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_beam_1280_white"))),
        bytes32(keccak256("oak_lumber_beam_1280_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_beam_1280_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_238_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step238 White",
        bytes32(keccak256("oak_lumber_step_238_white")),
        bytes32(keccak256("oak_lumber_step_238_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_238_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_238_white"))),
        bytes32(keccak256("oak_lumber_step_238_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_238_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_beam_1285_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Beam1285 White",
        bytes32(keccak256("oak_lumber_beam_1285_white")),
        bytes32(keccak256("oak_lumber_beam_1285_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_beam_1285_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_beam_1285_white"))),
        bytes32(keccak256("oak_lumber_beam_1285_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_beam_1285_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_outset_1152")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Outset1152",
        bytes32(keccak256("hay_outset_1152")),
        bytes32(keccak256("hay_outset_1152")),
        getChildVoxelTypes(bytes32(keccak256("hay_outset_1152"))),
        getChildVoxelTypes(bytes32(keccak256("hay_outset_1152"))),
        bytes32(keccak256("hay_outset_1152")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_outset_1152")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_199_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step199 White",
        bytes32(keccak256("oak_lumber_step_199_white")),
        bytes32(keccak256("oak_lumber_step_199_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_199_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_199_white"))),
        bytes32(keccak256("oak_lumber_step_199_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_199_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sunstone_stub_1260")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sunstone Stub1260",
        bytes32(keccak256("sunstone_stub_1260")),
        bytes32(keccak256("sunstone_stub_1260")),
        getChildVoxelTypes(bytes32(keccak256("sunstone_stub_1260"))),
        getChildVoxelTypes(bytes32(keccak256("sunstone_stub_1260"))),
        bytes32(keccak256("sunstone_stub_1260")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sunstone_stub_1260")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_135_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab135 White",
        bytes32(keccak256("oak_lumber_slab_135_white")),
        bytes32(keccak256("oak_lumber_slab_135_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_135_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_135_white"))),
        bytes32(keccak256("oak_lumber_slab_135_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_135_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_130_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab130 White",
        bytes32(keccak256("oak_lumber_slab_130_white")),
        bytes32(keccak256("oak_lumber_slab_130_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_130_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_130_white"))),
        bytes32(keccak256("oak_lumber_slab_130_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_130_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_235_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step235 White",
        bytes32(keccak256("oak_lumber_step_235_white")),
        bytes32(keccak256("oak_lumber_step_235_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_235_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_235_white"))),
        bytes32(keccak256("oak_lumber_step_235_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_235_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_194_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step194 White",
        bytes32(keccak256("oak_lumber_step_194_white")),
        bytes32(keccak256("oak_lumber_step_194_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_194_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_194_white"))),
        bytes32(keccak256("oak_lumber_step_194_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_194_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sunstone_stub_1221")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sunstone Stub1221",
        bytes32(keccak256("sunstone_stub_1221")),
        bytes32(keccak256("sunstone_stub_1221")),
        getChildVoxelTypes(bytes32(keccak256("sunstone_stub_1221"))),
        getChildVoxelTypes(bytes32(keccak256("sunstone_stub_1221"))),
        bytes32(keccak256("sunstone_stub_1221")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sunstone_stub_1221")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_238")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step238",
        bytes32(keccak256("oak_lumber_step_238")),
        bytes32(keccak256("oak_lumber_step_238")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_238"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_238"))),
        bytes32(keccak256("oak_lumber_step_238")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_238")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_135")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab135",
        bytes32(keccak256("oak_lumber_slab_135")),
        bytes32(keccak256("oak_lumber_slab_135")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_135"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_135"))),
        bytes32(keccak256("oak_lumber_slab_135")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_135")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_174")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab174",
        bytes32(keccak256("oak_lumber_slab_174")),
        bytes32(keccak256("oak_lumber_slab_174")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_174"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_174"))),
        bytes32(keccak256("oak_lumber_slab_174")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_174")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_171")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab171",
        bytes32(keccak256("oak_lumber_slab_171")),
        bytes32(keccak256("oak_lumber_slab_171")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_171"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_171"))),
        bytes32(keccak256("oak_lumber_slab_171")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_171")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab130",
        bytes32(keccak256("oak_lumber_slab_130")),
        bytes32(keccak256("oak_lumber_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_130"))),
        bytes32(keccak256("oak_lumber_slab_130")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_235")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step235",
        bytes32(keccak256("oak_lumber_step_235")),
        bytes32(keccak256("oak_lumber_step_235")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_235"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_235"))),
        bytes32(keccak256("oak_lumber_step_235")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_235")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sunstone_stub_1216")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sunstone Stub1216",
        bytes32(keccak256("sunstone_stub_1216")),
        bytes32(keccak256("sunstone_stub_1216")),
        getChildVoxelTypes(bytes32(keccak256("sunstone_stub_1216"))),
        getChildVoxelTypes(bytes32(keccak256("sunstone_stub_1216"))),
        bytes32(keccak256("sunstone_stub_1216")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sunstone_stub_1216")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_194")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step194",
        bytes32(keccak256("oak_lumber_step_194")),
        bytes32(keccak256("oak_lumber_step_194")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_194"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_194"))),
        bytes32(keccak256("oak_lumber_step_194")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_194")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step197",
        bytes32(keccak256("oak_lumber_step_197")),
        bytes32(keccak256("oak_lumber_step_197")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_197"))),
        bytes32(keccak256("oak_lumber_step_197")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_full_64")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Full64",
        bytes32(keccak256("oak_lumber_full_64")),
        bytes32(keccak256("oak_lumber_full_64")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_64"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_full_64"))),
        bytes32(keccak256("oak_lumber_full_64")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_full_64")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_outset_1193_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Outset1193 Black",
        bytes32(keccak256("oak_lumber_outset_1193_black")),
        bytes32(keccak256("oak_lumber_outset_1193_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1193_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1193_black"))),
        bytes32(keccak256("oak_lumber_outset_1193_black")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_outset_1193_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_outset_1196_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Outset1196 Black",
        bytes32(keccak256("oak_lumber_outset_1196_black")),
        bytes32(keccak256("oak_lumber_outset_1196_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1196_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1196_black"))),
        bytes32(keccak256("oak_lumber_outset_1196_black")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_outset_1196_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_path_512")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Path512",
        bytes32(keccak256("hay_path_512")),
        bytes32(keccak256("hay_path_512")),
        getChildVoxelTypes(bytes32(keccak256("hay_path_512"))),
        getChildVoxelTypes(bytes32(keccak256("hay_path_512"))),
        bytes32(keccak256("hay_path_512")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_path_512")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_199_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step199 Red",
        bytes32(keccak256("oak_lumber_step_199_red")),
        bytes32(keccak256("oak_lumber_step_199_red")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_199_red"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_199_red"))),
        bytes32(keccak256("oak_lumber_step_199_red")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_199_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_174_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab174 Red",
        bytes32(keccak256("oak_lumber_slab_174_red")),
        bytes32(keccak256("oak_lumber_slab_174_red")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_174_red"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_174_red"))),
        bytes32(keccak256("oak_lumber_slab_174_red")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_174_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_194_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step194 Red",
        bytes32(keccak256("oak_lumber_step_194_red")),
        bytes32(keccak256("oak_lumber_step_194_red")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_194_red"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_194_red"))),
        bytes32(keccak256("oak_lumber_step_194_red")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_194_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_knob_939")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Knob939",
        bytes32(keccak256("cotton_fabric_knob_939")),
        bytes32(keccak256("cotton_fabric_knob_939")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_939"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_939"))),
        bytes32(keccak256("cotton_fabric_knob_939")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_knob_939")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_knob_898")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Knob898",
        bytes32(keccak256("cotton_fabric_knob_898")),
        bytes32(keccak256("cotton_fabric_knob_898")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_898"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_898"))),
        bytes32(keccak256("cotton_fabric_knob_898")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_knob_898")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("hay_step_192")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Hay Step192",
        bytes32(keccak256("hay_step_192")),
        bytes32(keccak256("hay_step_192")),
        getChildVoxelTypes(bytes32(keccak256("hay_step_192"))),
        getChildVoxelTypes(bytes32(keccak256("hay_step_192"))),
        bytes32(keccak256("hay_step_192")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("hay_step_192")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_knob_937")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Knob937",
        bytes32(keccak256("cotton_fabric_knob_937")),
        bytes32(keccak256("cotton_fabric_knob_937")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_937"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_937"))),
        bytes32(keccak256("cotton_fabric_knob_937")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_knob_937")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step236",
        bytes32(keccak256("cotton_fabric_step_236")),
        bytes32(keccak256("cotton_fabric_step_236")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_236"))),
        bytes32(keccak256("cotton_fabric_step_236")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_knob_896")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Knob896",
        bytes32(keccak256("cotton_fabric_knob_896")),
        bytes32(keccak256("cotton_fabric_knob_896")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_896"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_896"))),
        bytes32(keccak256("cotton_fabric_knob_896")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_knob_896")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_494")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall494",
        bytes32(keccak256("oak_lumber_wall_494")),
        bytes32(keccak256("oak_lumber_wall_494")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_494"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_494"))),
        bytes32(keccak256("oak_lumber_wall_494")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_494")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_window_620_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Window620 White",
        bytes32(keccak256("oak_lumber_window_620_white")),
        bytes32(keccak256("oak_lumber_window_620_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_window_620_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_window_620_white"))),
        bytes32(keccak256("oak_lumber_window_620_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_window_620_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_192")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step192",
        bytes32(keccak256("oak_lumber_step_192")),
        bytes32(keccak256("oak_lumber_step_192")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_192"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_192"))),
        bytes32(keccak256("oak_lumber_step_192")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_192")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_stub_1262")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Stub1262",
        bytes32(keccak256("oak_lumber_stub_1262")),
        bytes32(keccak256("oak_lumber_stub_1262")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_stub_1262"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_stub_1262"))),
        bytes32(keccak256("oak_lumber_stub_1262")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_stub_1262")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1067")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Stool1067",
        bytes32(keccak256("rubber_stripped_stool_1067")),
        bytes32(keccak256("rubber_stripped_stool_1067")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1067"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1067"))),
        bytes32(keccak256("rubber_stripped_stool_1067")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1067")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_stool_1067")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Stool1067",
        bytes32(keccak256("rubber_lumber_stool_1067")),
        bytes32(keccak256("rubber_lumber_stool_1067")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_stool_1067"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_stool_1067"))),
        bytes32(keccak256("rubber_lumber_stool_1067")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_stool_1067")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Step199",
        bytes32(keccak256("cobblestone_step_199")),
        bytes32(keccak256("cobblestone_step_199")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_step_199"))),
        bytes32(keccak256("cobblestone_step_199")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Wall492",
        bytes32(keccak256("rubber_lumber_wall_492")),
        bytes32(keccak256("rubber_lumber_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_wall_492"))),
        bytes32(keccak256("rubber_lumber_wall_492")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_wall_492")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Wall489",
        bytes32(keccak256("rubber_stripped_wall_489")),
        bytes32(keccak256("rubber_stripped_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_wall_489"))),
        bytes32(keccak256("rubber_stripped_wall_489")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick",
        bytes32(keccak256("cobblestone_brick")),
        bytes32(keccak256("cobblestone_brick")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick"))),
        bytes32(keccak256("cobblestone_brick")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_polished")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Polished",
        bytes32(keccak256("cobblestone_polished")),
        bytes32(keccak256("cobblestone_polished")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_polished"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_polished"))),
        bytes32(keccak256("cobblestone_polished")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_polished")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Wall489",
        bytes32(keccak256("cobblestone_wall_489")),
        bytes32(keccak256("cobblestone_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_wall_489"))),
        bytes32(keccak256("cobblestone_wall_489")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1196")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1196",
        bytes32(keccak256("cotton_fabric_outset_1196")),
        bytes32(keccak256("cotton_fabric_outset_1196")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1196"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1196"))),
        bytes32(keccak256("cotton_fabric_outset_1196")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1196")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("pumpkin")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Pumpkin",
        bytes32(keccak256("pumpkin")),
        bytes32(keccak256("pumpkin")),
        getChildVoxelTypes(bytes32(keccak256("pumpkin"))),
        getChildVoxelTypes(bytes32(keccak256("pumpkin"))),
        bytes32(keccak256("pumpkin")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("pumpkin")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_fence_320")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Fence320",
        bytes32(keccak256("rubber_stripped_fence_320")),
        bytes32(keccak256("rubber_stripped_fence_320")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_fence_320"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_fence_320"))),
        bytes32(keccak256("rubber_stripped_fence_320")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_fence_320")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium",
        bytes32(keccak256("neptunium")),
        bytes32(keccak256("neptunium")),
        getChildVoxelTypes(bytes32(keccak256("neptunium"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium"))),
        bytes32(keccak256("neptunium")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_table_384")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Table384",
        bytes32(keccak256("oak_stripped_table_384")),
        bytes32(keccak256("oak_stripped_table_384")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_table_384"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_table_384"))),
        bytes32(keccak256("oak_stripped_table_384")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_table_384")));

    vm.stopBroadcast();
  }
}
