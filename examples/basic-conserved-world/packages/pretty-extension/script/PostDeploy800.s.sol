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

contract PostDeploy800 is Script {
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
        registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_stub_1260")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Stub1260",
        bytes32(keccak256("led_stub_1260")),
        bytes32(keccak256("led_stub_1260")),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1260"))),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1260"))),
        bytes32(keccak256("led_stub_1260")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_stub_1260")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_frame_684_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Frame684 Black",
        bytes32(keccak256("oak_lumber_frame_684_black")),
        bytes32(keccak256("oak_lumber_frame_684_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_684_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_684_black"))),
        bytes32(keccak256("oak_lumber_frame_684_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_frame_684_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Slab133",
        bytes32(keccak256("rubber_stripped_slab_133")),
        bytes32(keccak256("rubber_stripped_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_slab_133"))),
        bytes32(keccak256("rubber_stripped_slab_133")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_frame_681_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Frame681 Black",
        bytes32(keccak256("oak_lumber_frame_681_black")),
        bytes32(keccak256("oak_lumber_frame_681_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_681_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_681_black"))),
        bytes32(keccak256("oak_lumber_frame_681_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_frame_681_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Slab169",
        bytes32(keccak256("rubber_stripped_slab_169")),
        bytes32(keccak256("rubber_stripped_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_slab_169"))),
        bytes32(keccak256("rubber_stripped_slab_169")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_polished_slice_706")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Polished Slice706",
        bytes32(keccak256("granite_polished_slice_706")),
        bytes32(keccak256("granite_polished_slice_706")),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_slice_706"))),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_slice_706"))),
        bytes32(keccak256("granite_polished_slice_706")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_polished_slice_706")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_frame_647_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Frame647 Black",
        bytes32(keccak256("oak_lumber_frame_647_black")),
        bytes32(keccak256("oak_lumber_frame_647_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_647_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_647_black"))),
        bytes32(keccak256("oak_lumber_frame_647_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_frame_647_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_709_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice709 Pink",
        bytes32(keccak256("cotton_fabric_slice_709_pink")),
        bytes32(keccak256("cotton_fabric_slice_709_pink")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_709_pink"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_709_pink"))),
        bytes32(keccak256("cotton_fabric_slice_709_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_709_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1257_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Stub1257 Purple",
        bytes32(keccak256("cotton_fabric_stub_1257_purple")),
        bytes32(keccak256("cotton_fabric_stub_1257_purple")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1257_purple"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1257_purple"))),
        bytes32(keccak256("cotton_fabric_stub_1257_purple")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1257_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_455")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall455",
        bytes32(keccak256("cotton_fabric_wall_455")),
        bytes32(keccak256("cotton_fabric_wall_455")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_455"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_455"))),
        bytes32(keccak256("cotton_fabric_wall_455")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_455")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_beam_1324")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Beam1324",
        bytes32(keccak256("rubber_stripped_beam_1324")),
        bytes32(keccak256("rubber_stripped_beam_1324")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_beam_1324"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_beam_1324"))),
        bytes32(keccak256("rubber_stripped_beam_1324")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_beam_1324")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_beam_1321")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Beam1321",
        bytes32(keccak256("rubber_stripped_beam_1321")),
        bytes32(keccak256("rubber_stripped_beam_1321")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_beam_1321"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_beam_1321"))),
        bytes32(keccak256("rubber_stripped_beam_1321")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_beam_1321")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Slab169",
        bytes32(keccak256("birch_stripped_slab_169")),
        bytes32(keccak256("birch_stripped_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_slab_169"))),
        bytes32(keccak256("birch_stripped_slab_169")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_stool_1067")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Stool1067",
        bytes32(keccak256("birch_stripped_stool_1067")),
        bytes32(keccak256("birch_stripped_stool_1067")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_stool_1067"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_stool_1067"))),
        bytes32(keccak256("birch_stripped_stool_1067")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_stool_1067")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_shingles_slab_171")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Shingles Slab171",
        bytes32(keccak256("clay_shingles_slab_171")),
        bytes32(keccak256("clay_shingles_slab_171")),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_171"))),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_171"))),
        bytes32(keccak256("clay_shingles_slab_171")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_shingles_slab_171")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_shingles_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Shingles Slab130",
        bytes32(keccak256("clay_shingles_slab_130")),
        bytes32(keccak256("clay_shingles_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_130"))),
        bytes32(keccak256("clay_shingles_slab_130")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_shingles_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("thatch_peg_768")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Thatch Peg768",
        bytes32(keccak256("thatch_peg_768")),
        bytes32(keccak256("thatch_peg_768")),
        getChildVoxelTypes(bytes32(keccak256("thatch_peg_768"))),
        getChildVoxelTypes(bytes32(keccak256("thatch_peg_768"))),
        bytes32(keccak256("thatch_peg_768")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("thatch_peg_768")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sunstone_stub_1257")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sunstone Stub1257",
        bytes32(keccak256("sunstone_stub_1257")),
        bytes32(keccak256("sunstone_stub_1257")),
        getChildVoxelTypes(bytes32(keccak256("sunstone_stub_1257"))),
        getChildVoxelTypes(bytes32(keccak256("sunstone_stub_1257"))),
        bytes32(keccak256("sunstone_stub_1257")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sunstone_stub_1257")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("thatch_peg_809")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Thatch Peg809",
        bytes32(keccak256("thatch_peg_809")),
        bytes32(keccak256("thatch_peg_809")),
        getChildVoxelTypes(bytes32(keccak256("thatch_peg_809"))),
        getChildVoxelTypes(bytes32(keccak256("thatch_peg_809"))),
        bytes32(keccak256("thatch_peg_809")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("thatch_peg_809")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_peg_809")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Peg809",
        bytes32(keccak256("birch_stripped_peg_809")),
        bytes32(keccak256("birch_stripped_peg_809")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_peg_809"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_peg_809"))),
        bytes32(keccak256("birch_stripped_peg_809")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_peg_809")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_361_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence361 Black",
        bytes32(keccak256("oak_lumber_fence_361_black")),
        bytes32(keccak256("oak_lumber_fence_361_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_361_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_361_black"))),
        bytes32(keccak256("oak_lumber_fence_361_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_361_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_shingles_slab_174")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Shingles Slab174",
        bytes32(keccak256("clay_shingles_slab_174")),
        bytes32(keccak256("clay_shingles_slab_174")),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_174"))),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_174"))),
        bytes32(keccak256("clay_shingles_slab_174")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_shingles_slab_174")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_shingles_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Shingles Slab169",
        bytes32(keccak256("clay_shingles_slab_169")),
        bytes32(keccak256("clay_shingles_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_169"))),
        bytes32(keccak256("clay_shingles_slab_169")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_shingles_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_shingles_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Shingles Slab128",
        bytes32(keccak256("clay_shingles_slab_128")),
        bytes32(keccak256("clay_shingles_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_128"))),
        bytes32(keccak256("clay_shingles_slab_128")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_shingles_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_shingles_step_192")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Shingles Step192",
        bytes32(keccak256("clay_shingles_step_192")),
        bytes32(keccak256("clay_shingles_step_192")),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_step_192"))),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_step_192"))),
        bytes32(keccak256("clay_shingles_step_192")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_shingles_step_192")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_shingles")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Shingles",
        bytes32(keccak256("clay_shingles")),
        bytes32(keccak256("clay_shingles")),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles"))),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles"))),
        bytes32(keccak256("clay_shingles")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_shingles")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_slab_174")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Slab174",
        bytes32(keccak256("rubber_lumber_slab_174")),
        bytes32(keccak256("rubber_lumber_slab_174")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_slab_174"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_slab_174"))),
        bytes32(keccak256("rubber_lumber_slab_174")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_slab_174")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Slab130",
        bytes32(keccak256("rubber_lumber_slab_130")),
        bytes32(keccak256("rubber_lumber_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_slab_130"))),
        bytes32(keccak256("rubber_lumber_slab_130")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_slab_171")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Slab171",
        bytes32(keccak256("rubber_lumber_slab_171")),
        bytes32(keccak256("rubber_lumber_slab_171")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_slab_171"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_slab_171"))),
        bytes32(keccak256("rubber_lumber_slab_171")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_slab_171")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_shingles_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Shingles Step197",
        bytes32(keccak256("clay_shingles_step_197")),
        bytes32(keccak256("clay_shingles_step_197")),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_step_197"))),
        bytes32(keccak256("clay_shingles_step_197")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_shingles_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_shingles_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Shingles Step199",
        bytes32(keccak256("clay_shingles_step_199")),
        bytes32(keccak256("clay_shingles_step_199")),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_step_199"))),
        bytes32(keccak256("clay_shingles_step_199")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_shingles_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_shingles_step_194")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Shingles Step194",
        bytes32(keccak256("clay_shingles_step_194")),
        bytes32(keccak256("clay_shingles_step_194")),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_step_194"))),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_step_194"))),
        bytes32(keccak256("clay_shingles_step_194")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_shingles_step_194")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_shingles_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Shingles Slab172",
        bytes32(keccak256("clay_shingles_slab_172")),
        bytes32(keccak256("clay_shingles_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_172"))),
        bytes32(keccak256("clay_shingles_slab_172")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_shingles_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_shingles_slab_135")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Shingles Slab135",
        bytes32(keccak256("clay_shingles_slab_135")),
        bytes32(keccak256("clay_shingles_slab_135")),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_135"))),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_135"))),
        bytes32(keccak256("clay_shingles_slab_135")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_shingles_slab_135")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_stub_1257")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Stub1257",
        bytes32(keccak256("simple_glass_stub_1257")),
        bytes32(keccak256("simple_glass_stub_1257")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_stub_1257"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_stub_1257"))),
        bytes32(keccak256("simple_glass_stub_1257")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_stub_1257")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_outset_1193_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Outset1193 Purple",
        bytes32(keccak256("oak_lumber_outset_1193_purple")),
        bytes32(keccak256("oak_lumber_outset_1193_purple")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1193_purple"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1193_purple"))),
        bytes32(keccak256("oak_lumber_outset_1193_purple")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_outset_1193_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_corner_873")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Corner873",
        bytes32(keccak256("cotton_fabric_corner_873")),
        bytes32(keccak256("cotton_fabric_corner_873")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_corner_873"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_corner_873"))),
        bytes32(keccak256("cotton_fabric_corner_873")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_corner_873")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_448_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall448 Pink",
        bytes32(keccak256("oak_lumber_wall_448_pink")),
        bytes32(keccak256("oak_lumber_wall_448_pink")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_448_pink"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_448_pink"))),
        bytes32(keccak256("oak_lumber_wall_448_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_448_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_step_235")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Step235",
        bytes32(keccak256("birch_stripped_step_235")),
        bytes32(keccak256("birch_stripped_step_235")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_step_235"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_step_235"))),
        bytes32(keccak256("birch_stripped_step_235")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_step_235")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_453_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall453 Pink",
        bytes32(keccak256("oak_lumber_wall_453_pink")),
        bytes32(keccak256("oak_lumber_wall_453_pink")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_453_pink"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_453_pink"))),
        bytes32(keccak256("oak_lumber_wall_453_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_453_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step233",
        bytes32(keccak256("cotton_fabric_step_233")),
        bytes32(keccak256("cotton_fabric_step_233")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_233"))),
        bytes32(keccak256("cotton_fabric_step_233")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_outset_1152_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Outset1152 Purple",
        bytes32(keccak256("oak_lumber_outset_1152_purple")),
        bytes32(keccak256("oak_lumber_outset_1152_purple")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1152_purple"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1152_purple"))),
        bytes32(keccak256("oak_lumber_outset_1152_purple")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_outset_1152_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_table_389")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Table389",
        bytes32(keccak256("birch_stripped_table_389")),
        bytes32(keccak256("birch_stripped_table_389")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_table_389"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_table_389"))),
        bytes32(keccak256("birch_stripped_table_389")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_table_389")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_133_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab133 Pink",
        bytes32(keccak256("cotton_fabric_slab_133_pink")),
        bytes32(keccak256("cotton_fabric_slab_133_pink")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_133_pink"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_133_pink"))),
        bytes32(keccak256("cotton_fabric_slab_133_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_133_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab169 Pink",
        bytes32(keccak256("cotton_fabric_slab_169_pink")),
        bytes32(keccak256("cotton_fabric_slab_169_pink")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169_pink"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169_pink"))),
        bytes32(keccak256("cotton_fabric_slab_169_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_knob_903_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Knob903 White",
        bytes32(keccak256("oak_lumber_knob_903_white")),
        bytes32(keccak256("oak_lumber_knob_903_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_knob_903_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_knob_903_white"))),
        bytes32(keccak256("oak_lumber_knob_903_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_knob_903_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_corner_839_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Corner839 White",
        bytes32(keccak256("oak_lumber_corner_839_white")),
        bytes32(keccak256("oak_lumber_corner_839_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_corner_839_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_corner_839_white"))),
        bytes32(keccak256("oak_lumber_corner_839_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_corner_839_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_corner_878_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Corner878 White",
        bytes32(keccak256("oak_lumber_corner_878_white")),
        bytes32(keccak256("oak_lumber_corner_878_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_corner_878_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_corner_878_white"))),
        bytes32(keccak256("oak_lumber_corner_878_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_corner_878_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_knob_942_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Knob942 White",
        bytes32(keccak256("oak_lumber_knob_942_white")),
        bytes32(keccak256("oak_lumber_knob_942_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_knob_942_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_knob_942_white"))),
        bytes32(keccak256("oak_lumber_knob_942_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_knob_942_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_knob_939_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Knob939 White",
        bytes32(keccak256("oak_lumber_knob_939_white")),
        bytes32(keccak256("oak_lumber_knob_939_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_knob_939_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_knob_939_white"))),
        bytes32(keccak256("oak_lumber_knob_939_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_knob_939_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_corner_875_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Corner875 White",
        bytes32(keccak256("oak_lumber_corner_875_white")),
        bytes32(keccak256("oak_lumber_corner_875_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_corner_875_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_corner_875_white"))),
        bytes32(keccak256("oak_lumber_corner_875_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_corner_875_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1221_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Stub1221 Pink",
        bytes32(keccak256("cotton_fabric_stub_1221_pink")),
        bytes32(keccak256("cotton_fabric_stub_1221_pink")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1221_pink"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1221_pink"))),
        bytes32(keccak256("cotton_fabric_stub_1221_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1221_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1152_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1152 Pink",
        bytes32(keccak256("cotton_fabric_outset_1152_pink")),
        bytes32(keccak256("cotton_fabric_outset_1152_pink")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1152_pink"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1152_pink"))),
        bytes32(keccak256("cotton_fabric_outset_1152_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1152_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_corner_834_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Corner834 White",
        bytes32(keccak256("oak_lumber_corner_834_white")),
        bytes32(keccak256("oak_lumber_corner_834_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_corner_834_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_corner_834_white"))),
        bytes32(keccak256("oak_lumber_corner_834_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_corner_834_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_knob_898_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Knob898 White",
        bytes32(keccak256("oak_lumber_knob_898_white")),
        bytes32(keccak256("oak_lumber_knob_898_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_knob_898_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_knob_898_white"))),
        bytes32(keccak256("oak_lumber_knob_898_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_knob_898_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_brightpink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Brightpink",
        bytes32(keccak256("cotton_fabric_brightpink")),
        bytes32(keccak256("cotton_fabric_brightpink")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_brightpink"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_brightpink"))),
        bytes32(keccak256("cotton_fabric_brightpink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_brightpink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_238_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step238 Pink",
        bytes32(keccak256("oak_lumber_step_238_pink")),
        bytes32(keccak256("oak_lumber_step_238_pink")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_238_pink"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_238_pink"))),
        bytes32(keccak256("oak_lumber_step_238_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_238_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_stub_1218_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Stub1218 Pink",
        bytes32(keccak256("led_stub_1218_pink")),
        bytes32(keccak256("led_stub_1218_pink")),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1218_pink"))),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1218_pink"))),
        bytes32(keccak256("led_stub_1218_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_stub_1218_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_235_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step235 Pink",
        bytes32(keccak256("oak_lumber_step_235_pink")),
        bytes32(keccak256("oak_lumber_step_235_pink")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_235_pink"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_235_pink"))),
        bytes32(keccak256("oak_lumber_step_235_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_235_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1152_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1152 Purple",
        bytes32(keccak256("cotton_fabric_outset_1152_purple")),
        bytes32(keccak256("cotton_fabric_outset_1152_purple")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1152_purple"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1152_purple"))),
        bytes32(keccak256("cotton_fabric_outset_1152_purple")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1152_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_128_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab128 Pink",
        bytes32(keccak256("oak_lumber_slab_128_pink")),
        bytes32(keccak256("oak_lumber_slab_128_pink")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_128_pink"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_128_pink"))),
        bytes32(keccak256("oak_lumber_slab_128_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_128_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Pink",
        bytes32(keccak256("oak_lumber_pink")),
        bytes32(keccak256("oak_lumber_pink")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_pink"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_pink"))),
        bytes32(keccak256("oak_lumber_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_slab_171")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Slab171",
        bytes32(keccak256("led_slab_171")),
        bytes32(keccak256("led_slab_171")),
        getChildVoxelTypes(bytes32(keccak256("led_slab_171"))),
        getChildVoxelTypes(bytes32(keccak256("led_slab_171"))),
        bytes32(keccak256("led_slab_171")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_slab_171")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_slice_704")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Slice704",
        bytes32(keccak256("birch_stripped_slice_704")),
        bytes32(keccak256("birch_stripped_slice_704")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_slice_704"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_slice_704"))),
        bytes32(keccak256("birch_stripped_slice_704")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_slice_704")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_stool_1065")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Stool1065",
        bytes32(keccak256("birch_stripped_stool_1065")),
        bytes32(keccak256("birch_stripped_stool_1065")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_stool_1065"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_stool_1065"))),
        bytes32(keccak256("birch_stripped_stool_1065")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_stool_1065")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_shingles_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Shingles Slab133",
        bytes32(keccak256("clay_shingles_slab_133")),
        bytes32(keccak256("clay_shingles_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("clay_shingles_slab_133"))),
        bytes32(keccak256("clay_shingles_slab_133")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_shingles_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Pink",
        bytes32(keccak256("simple_glass_pink")),
        bytes32(keccak256("simple_glass_pink")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_pink"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_pink"))),
        bytes32(keccak256("simple_glass_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_stub_1216")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Stub1216",
        bytes32(keccak256("simple_glass_stub_1216")),
        bytes32(keccak256("simple_glass_stub_1216")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_stub_1216"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_stub_1216"))),
        bytes32(keccak256("simple_glass_stub_1216")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_stub_1216")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_stub_1260")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Stub1260",
        bytes32(keccak256("simple_glass_stub_1260")),
        bytes32(keccak256("simple_glass_stub_1260")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_stub_1260"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_stub_1260"))),
        bytes32(keccak256("simple_glass_stub_1260")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_stub_1260")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_slice_748")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Slice748",
        bytes32(keccak256("simple_glass_slice_748")),
        bytes32(keccak256("simple_glass_slice_748")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_slice_748"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_slice_748"))),
        bytes32(keccak256("simple_glass_slice_748")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_slice_748")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("limestone")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Limestone",
        bytes32(keccak256("limestone")),
        bytes32(keccak256("limestone")),
        getChildVoxelTypes(bytes32(keccak256("limestone"))),
        getChildVoxelTypes(bytes32(keccak256("limestone"))),
        bytes32(keccak256("limestone")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("limestone")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slice_748_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slice748 Black",
        bytes32(keccak256("oak_lumber_slice_748_black")),
        bytes32(keccak256("oak_lumber_slice_748_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_748_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_748_black"))),
        bytes32(keccak256("oak_lumber_slice_748_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slice_748_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slice_709_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slice709 Black",
        bytes32(keccak256("oak_lumber_slice_709_black")),
        bytes32(keccak256("oak_lumber_slice_709_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_709_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_709_black"))),
        bytes32(keccak256("oak_lumber_slice_709_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slice_709_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slice_704_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slice704 Black",
        bytes32(keccak256("oak_lumber_slice_704_black")),
        bytes32(keccak256("oak_lumber_slice_704_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_704_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_704_black"))),
        bytes32(keccak256("oak_lumber_slice_704_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slice_704_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slice_745_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slice745 Black",
        bytes32(keccak256("oak_lumber_slice_745_black")),
        bytes32(keccak256("oak_lumber_slice_745_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_745_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_745_black"))),
        bytes32(keccak256("oak_lumber_slice_745_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slice_745_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_174_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab174 Black",
        bytes32(keccak256("oak_lumber_slab_174_black")),
        bytes32(keccak256("oak_lumber_slab_174_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_174_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_174_black"))),
        bytes32(keccak256("oak_lumber_slab_174_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_174_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_172_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab172 Black",
        bytes32(keccak256("oak_lumber_slab_172_black")),
        bytes32(keccak256("oak_lumber_slab_172_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_172_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_172_black"))),
        bytes32(keccak256("oak_lumber_slab_172_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_172_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_frame_684")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Frame684",
        bytes32(keccak256("birch_lumber_frame_684")),
        bytes32(keccak256("birch_lumber_frame_684")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_frame_684"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_frame_684"))),
        bytes32(keccak256("birch_lumber_frame_684")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_frame_684")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_frame_645")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Frame645",
        bytes32(keccak256("birch_lumber_frame_645")),
        bytes32(keccak256("birch_lumber_frame_645")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_frame_645"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_frame_645"))),
        bytes32(keccak256("birch_lumber_frame_645")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_frame_645")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_yellow")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Yellow",
        bytes32(keccak256("led_yellow")),
        bytes32(keccak256("led_yellow")),
        getChildVoxelTypes(bytes32(keccak256("led_yellow"))),
        getChildVoxelTypes(bytes32(keccak256("led_yellow"))),
        bytes32(keccak256("led_yellow")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_yellow")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_frame_640")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Frame640",
        bytes32(keccak256("birch_lumber_frame_640")),
        bytes32(keccak256("birch_lumber_frame_640")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_frame_640"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_frame_640"))),
        bytes32(keccak256("birch_lumber_frame_640")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_frame_640")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_171_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab171 Black",
        bytes32(keccak256("oak_lumber_slab_171_black")),
        bytes32(keccak256("oak_lumber_slab_171_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_171_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_171_black"))),
        bytes32(keccak256("oak_lumber_slab_171_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_171_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_frame_681")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Frame681",
        bytes32(keccak256("birch_lumber_frame_681")),
        bytes32(keccak256("birch_lumber_frame_681")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_frame_681"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_frame_681"))),
        bytes32(keccak256("birch_lumber_frame_681")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_frame_681")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("copper_peg_773")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Copper Peg773",
        bytes32(keccak256("copper_peg_773")),
        bytes32(keccak256("copper_peg_773")),
        getChildVoxelTypes(bytes32(keccak256("copper_peg_773"))),
        getChildVoxelTypes(bytes32(keccak256("copper_peg_773"))),
        bytes32(keccak256("copper_peg_773")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("copper_peg_773")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_stool_1067")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Stool1067",
        bytes32(keccak256("birch_lumber_stool_1067")),
        bytes32(keccak256("birch_lumber_stool_1067")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_stool_1067"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_stool_1067"))),
        bytes32(keccak256("birch_lumber_stool_1067")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_stool_1067")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("copper_peg_768")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Copper Peg768",
        bytes32(keccak256("copper_peg_768")),
        bytes32(keccak256("copper_peg_768")),
        getChildVoxelTypes(bytes32(keccak256("copper_peg_768"))),
        getChildVoxelTypes(bytes32(keccak256("copper_peg_768"))),
        bytes32(keccak256("copper_peg_768")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("copper_peg_768")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_stool_1026")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Stool1026",
        bytes32(keccak256("birch_lumber_stool_1026")),
        bytes32(keccak256("birch_lumber_stool_1026")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_stool_1026"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_stool_1026"))),
        bytes32(keccak256("birch_lumber_stool_1026")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_stool_1026")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("copper_peg_809")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Copper Peg809",
        bytes32(keccak256("copper_peg_809")),
        bytes32(keccak256("copper_peg_809")),
        getChildVoxelTypes(bytes32(keccak256("copper_peg_809"))),
        getChildVoxelTypes(bytes32(keccak256("copper_peg_809"))),
        bytes32(keccak256("copper_peg_809")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("copper_peg_809")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("copper_peg_812")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Copper Peg812",
        bytes32(keccak256("copper_peg_812")),
        bytes32(keccak256("copper_peg_812")),
        getChildVoxelTypes(bytes32(keccak256("copper_peg_812"))),
        getChildVoxelTypes(bytes32(keccak256("copper_peg_812"))),
        bytes32(keccak256("copper_peg_812")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("copper_peg_812")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_wall_448")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Wall448",
        bytes32(keccak256("birch_lumber_wall_448")),
        bytes32(keccak256("birch_lumber_wall_448")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_wall_448"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_wall_448"))),
        bytes32(keccak256("birch_lumber_wall_448")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_wall_448")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_peg_768")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Peg768",
        bytes32(keccak256("birch_lumber_peg_768")),
        bytes32(keccak256("birch_lumber_peg_768")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_peg_768"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_peg_768"))),
        bytes32(keccak256("birch_lumber_peg_768")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_peg_768")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_wall_453")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Wall453",
        bytes32(keccak256("birch_lumber_wall_453")),
        bytes32(keccak256("birch_lumber_wall_453")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_wall_453"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_wall_453"))),
        bytes32(keccak256("birch_lumber_wall_453")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_wall_453")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_133_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab133 Black",
        bytes32(keccak256("oak_lumber_slab_133_black")),
        bytes32(keccak256("oak_lumber_slab_133_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_133_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_133_black"))),
        bytes32(keccak256("oak_lumber_slab_133_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_133_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("copper_stool_1024")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Copper Stool1024",
        bytes32(keccak256("copper_stool_1024")),
        bytes32(keccak256("copper_stool_1024")),
        getChildVoxelTypes(bytes32(keccak256("copper_stool_1024"))),
        getChildVoxelTypes(bytes32(keccak256("copper_stool_1024"))),
        bytes32(keccak256("copper_stool_1024")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("copper_stool_1024")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("copper_stool_1065")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Copper Stool1065",
        bytes32(keccak256("copper_stool_1065")),
        bytes32(keccak256("copper_stool_1065")),
        getChildVoxelTypes(bytes32(keccak256("copper_stool_1065"))),
        getChildVoxelTypes(bytes32(keccak256("copper_stool_1065"))),
        bytes32(keccak256("copper_stool_1065")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("copper_stool_1065")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("copper_stool_1029")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Copper Stool1029",
        bytes32(keccak256("copper_stool_1029")),
        bytes32(keccak256("copper_stool_1029")),
        getChildVoxelTypes(bytes32(keccak256("copper_stool_1029"))),
        getChildVoxelTypes(bytes32(keccak256("copper_stool_1029"))),
        bytes32(keccak256("copper_stool_1029")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("copper_stool_1029")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("copper_stool_1068")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Copper Stool1068",
        bytes32(keccak256("copper_stool_1068")),
        bytes32(keccak256("copper_stool_1068")),
        getChildVoxelTypes(bytes32(keccak256("copper_stool_1068"))),
        getChildVoxelTypes(bytes32(keccak256("copper_stool_1068"))),
        bytes32(keccak256("copper_stool_1068")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("copper_stool_1068")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_128_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab128 Black",
        bytes32(keccak256("oak_lumber_slab_128_black")),
        bytes32(keccak256("oak_lumber_slab_128_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_128_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_128_black"))),
        bytes32(keccak256("oak_lumber_slab_128_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_128_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_outset_1196")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Outset1196",
        bytes32(keccak256("neptunium_outset_1196")),
        bytes32(keccak256("neptunium_outset_1196")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_outset_1196"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_outset_1196"))),
        bytes32(keccak256("neptunium_outset_1196")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_outset_1196")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Wall492",
        bytes32(keccak256("moss_wall_492")),
        bytes32(keccak256("moss_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("moss_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("moss_wall_492"))),
        bytes32(keccak256("moss_wall_492")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_wall_492")));

    vm.stopBroadcast();
  }
}
