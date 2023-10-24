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

contract PostDeploy600 is Script {
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
        registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_745_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice745 Black",
        bytes32(keccak256("cotton_fabric_slice_745_black")),
        bytes32(keccak256("cotton_fabric_slice_745_black")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_745_black"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_745_black"))),
        bytes32(keccak256("cotton_fabric_slice_745_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_745_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1157_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1157 Pink",
        bytes32(keccak256("cotton_fabric_outset_1157_pink")),
        bytes32(keccak256("cotton_fabric_outset_1157_pink")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1157_pink"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1157_pink"))),
        bytes32(keccak256("cotton_fabric_outset_1157_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1157_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_outset_1152")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Outset1152",
        bytes32(keccak256("rubber_stripped_outset_1152")),
        bytes32(keccak256("rubber_stripped_outset_1152")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_outset_1152"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_outset_1152"))),
        bytes32(keccak256("rubber_stripped_outset_1152")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_outset_1152")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("limestone_polished")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Limestone Polished",
        bytes32(keccak256("limestone_polished")),
        bytes32(keccak256("limestone_polished")),
        getChildVoxelTypes(bytes32(keccak256("limestone_polished"))),
        getChildVoxelTypes(bytes32(keccak256("limestone_polished"))),
        bytes32(keccak256("limestone_polished")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("limestone_polished")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1070")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Stool1070",
        bytes32(keccak256("rubber_stripped_stool_1070")),
        bytes32(keccak256("rubber_stripped_stool_1070")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1070"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1070"))),
        bytes32(keccak256("rubber_stripped_stool_1070")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1070")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1157_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1157 Purple",
        bytes32(keccak256("cotton_fabric_outset_1157_purple")),
        bytes32(keccak256("cotton_fabric_outset_1157_purple")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1157_purple"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1157_purple"))),
        bytes32(keccak256("cotton_fabric_outset_1157_purple")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1157_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Pink",
        bytes32(keccak256("cotton_fabric_pink")),
        bytes32(keccak256("cotton_fabric_pink")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_pink"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_pink"))),
        bytes32(keccak256("cotton_fabric_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Blue",
        bytes32(keccak256("cotton_fabric_blue")),
        bytes32(keccak256("cotton_fabric_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_blue"))),
        bytes32(keccak256("cotton_fabric_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_453_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall453 White",
        bytes32(keccak256("cotton_fabric_wall_453_white")),
        bytes32(keccak256("cotton_fabric_wall_453_white")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_453_white"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_453_white"))),
        bytes32(keccak256("cotton_fabric_wall_453_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_453_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_beam_1285")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Beam1285",
        bytes32(keccak256("neptunium_beam_1285")),
        bytes32(keccak256("neptunium_beam_1285")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_beam_1285"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_beam_1285"))),
        bytes32(keccak256("neptunium_beam_1285")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_beam_1285")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_453_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall453 Purple",
        bytes32(keccak256("cotton_fabric_wall_453_purple")),
        bytes32(keccak256("cotton_fabric_wall_453_purple")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_453_purple"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_453_purple"))),
        bytes32(keccak256("cotton_fabric_wall_453_purple")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_453_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_window_581")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Window581",
        bytes32(keccak256("rubber_lumber_window_581")),
        bytes32(keccak256("rubber_lumber_window_581")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_window_581"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_window_581"))),
        bytes32(keccak256("rubber_lumber_window_581")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_window_581")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_window_576")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Window576",
        bytes32(keccak256("rubber_lumber_window_576")),
        bytes32(keccak256("rubber_lumber_window_576")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_window_576"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_window_576"))),
        bytes32(keccak256("rubber_lumber_window_576")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_window_576")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_slice_706")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Slice706",
        bytes32(keccak256("led_slice_706")),
        bytes32(keccak256("led_slice_706")),
        getChildVoxelTypes(bytes32(keccak256("led_slice_706"))),
        getChildVoxelTypes(bytes32(keccak256("led_slice_706"))),
        bytes32(keccak256("led_slice_706")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_slice_706")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab169 White",
        bytes32(keccak256("cotton_fabric_slab_169_white")),
        bytes32(keccak256("cotton_fabric_slab_169_white")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169_white"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169_white"))),
        bytes32(keccak256("cotton_fabric_slab_169_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab169 Purple",
        bytes32(keccak256("cotton_fabric_slab_169_purple")),
        bytes32(keccak256("cotton_fabric_slab_169_purple")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169_purple"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169_purple"))),
        bytes32(keccak256("cotton_fabric_slab_169_purple")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_polished_step_235")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Polished Step235",
        bytes32(keccak256("granite_polished_step_235")),
        bytes32(keccak256("granite_polished_step_235")),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_step_235"))),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_step_235"))),
        bytes32(keccak256("granite_polished_step_235")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_polished_step_235")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_polished_step_194")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Polished Step194",
        bytes32(keccak256("granite_polished_step_194")),
        bytes32(keccak256("granite_polished_step_194")),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_step_194"))),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_step_194"))),
        bytes32(keccak256("granite_polished_step_194")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_polished_step_194")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_polished_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Polished Step199",
        bytes32(keccak256("granite_polished_step_199")),
        bytes32(keccak256("granite_polished_step_199")),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_step_199"))),
        bytes32(keccak256("granite_polished_step_199")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_polished_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_polished_step_238")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Polished Step238",
        bytes32(keccak256("granite_polished_step_238")),
        bytes32(keccak256("granite_polished_step_238")),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_step_238"))),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_step_238"))),
        bytes32(keccak256("granite_polished_step_238")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_polished_step_238")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Slab130",
        bytes32(keccak256("birch_stripped_slab_130")),
        bytes32(keccak256("birch_stripped_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_slab_130"))),
        bytes32(keccak256("birch_stripped_slab_130")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Slab128",
        bytes32(keccak256("birch_stripped_slab_128")),
        bytes32(keccak256("birch_stripped_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_slab_128"))),
        bytes32(keccak256("birch_stripped_slab_128")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_frame_684")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Frame684",
        bytes32(keccak256("birch_stripped_frame_684")),
        bytes32(keccak256("birch_stripped_frame_684")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_frame_684"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_frame_684"))),
        bytes32(keccak256("birch_stripped_frame_684")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_frame_684")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_frame_645")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Frame645",
        bytes32(keccak256("birch_stripped_frame_645")),
        bytes32(keccak256("birch_stripped_frame_645")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_frame_645"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_frame_645"))),
        bytes32(keccak256("birch_stripped_frame_645")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_frame_645")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_frame_640")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Frame640",
        bytes32(keccak256("birch_stripped_frame_640")),
        bytes32(keccak256("birch_stripped_frame_640")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_frame_640"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_frame_640"))),
        bytes32(keccak256("birch_stripped_frame_640")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_frame_640")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_frame_681")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Frame681",
        bytes32(keccak256("birch_stripped_frame_681")),
        bytes32(keccak256("birch_stripped_frame_681")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_frame_681"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_frame_681"))),
        bytes32(keccak256("birch_stripped_frame_681")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_frame_681")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("boxwood_shrub")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Boxwood Shrub",
        bytes32(keccak256("boxwood_shrub")),
        bytes32(keccak256("boxwood_shrub")),
        getChildVoxelTypes(bytes32(keccak256("boxwood_shrub"))),
        getChildVoxelTypes(bytes32(keccak256("boxwood_shrub"))),
        bytes32(keccak256("boxwood_shrub")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("boxwood_shrub")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1198")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1198",
        bytes32(keccak256("simple_glass_outset_1198")),
        bytes32(keccak256("simple_glass_outset_1198")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1198"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1198"))),
        bytes32(keccak256("simple_glass_outset_1198")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1198")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1159")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1159",
        bytes32(keccak256("simple_glass_outset_1159")),
        bytes32(keccak256("simple_glass_outset_1159")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1159"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1159"))),
        bytes32(keccak256("simple_glass_outset_1159")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1159")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_slice_747")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Slice747",
        bytes32(keccak256("birch_lumber_slice_747")),
        bytes32(keccak256("birch_lumber_slice_747")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slice_747"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slice_747"))),
        bytes32(keccak256("birch_lumber_slice_747")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_slice_747")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Slab172",
        bytes32(keccak256("birch_lumber_slab_172")),
        bytes32(keccak256("birch_lumber_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slab_172"))),
        bytes32(keccak256("birch_lumber_slab_172")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_768")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg768",
        bytes32(keccak256("oak_lumber_peg_768")),
        bytes32(keccak256("oak_lumber_peg_768")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_768"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_768"))),
        bytes32(keccak256("oak_lumber_peg_768")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_768")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_809")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg809",
        bytes32(keccak256("oak_lumber_peg_809")),
        bytes32(keccak256("oak_lumber_peg_809")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_809"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_809"))),
        bytes32(keccak256("oak_lumber_peg_809")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_809")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_748_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice748 Blue",
        bytes32(keccak256("cotton_fabric_slice_748_blue")),
        bytes32(keccak256("cotton_fabric_slice_748_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_748_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_748_blue"))),
        bytes32(keccak256("cotton_fabric_slice_748_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_748_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab133",
        bytes32(keccak256("oak_lumber_slab_133")),
        bytes32(keccak256("oak_lumber_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_133"))),
        bytes32(keccak256("oak_lumber_slab_133")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1193_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1193 White",
        bytes32(keccak256("cotton_fabric_outset_1193_white")),
        bytes32(keccak256("cotton_fabric_outset_1193_white")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1193_white"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1193_white"))),
        bytes32(keccak256("cotton_fabric_outset_1193_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1193_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_812")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg812",
        bytes32(keccak256("oak_lumber_peg_812")),
        bytes32(keccak256("oak_lumber_peg_812")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_812"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_812"))),
        bytes32(keccak256("oak_lumber_peg_812")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_812")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1196_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1196 White",
        bytes32(keccak256("cotton_fabric_outset_1196_white")),
        bytes32(keccak256("cotton_fabric_outset_1196_white")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1196_white"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1196_white"))),
        bytes32(keccak256("cotton_fabric_outset_1196_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1196_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_773")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg773",
        bytes32(keccak256("oak_lumber_peg_773")),
        bytes32(keccak256("oak_lumber_peg_773")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_773"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_773"))),
        bytes32(keccak256("oak_lumber_peg_773")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_773")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1152_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1152 White",
        bytes32(keccak256("cotton_fabric_outset_1152_white")),
        bytes32(keccak256("cotton_fabric_outset_1152_white")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1152_white"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1152_white"))),
        bytes32(keccak256("cotton_fabric_outset_1152_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1152_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1152_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1152 Blue",
        bytes32(keccak256("cotton_fabric_outset_1152_blue")),
        bytes32(keccak256("cotton_fabric_outset_1152_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1152_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1152_blue"))),
        bytes32(keccak256("cotton_fabric_outset_1152_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1152_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_174_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab174 Blue",
        bytes32(keccak256("cotton_fabric_slab_174_blue")),
        bytes32(keccak256("cotton_fabric_slab_174_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_174_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_174_blue"))),
        bytes32(keccak256("cotton_fabric_slab_174_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_174_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_174_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab174 White",
        bytes32(keccak256("cotton_fabric_slab_174_white")),
        bytes32(keccak256("cotton_fabric_slab_174_white")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_174_white"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_174_white"))),
        bytes32(keccak256("cotton_fabric_slab_174_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_174_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_130_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab130 White",
        bytes32(keccak256("cotton_fabric_slab_130_white")),
        bytes32(keccak256("cotton_fabric_slab_130_white")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_130_white"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_130_white"))),
        bytes32(keccak256("cotton_fabric_slab_130_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_130_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_130_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab130 Blue",
        bytes32(keccak256("cotton_fabric_slab_130_blue")),
        bytes32(keccak256("cotton_fabric_slab_130_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_130_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_130_blue"))),
        bytes32(keccak256("cotton_fabric_slab_130_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_130_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_238_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step238 Blue",
        bytes32(keccak256("cotton_fabric_step_238_blue")),
        bytes32(keccak256("cotton_fabric_step_238_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_238_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_238_blue"))),
        bytes32(keccak256("cotton_fabric_step_238_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_238_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_238_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step238 White",
        bytes32(keccak256("cotton_fabric_step_238_white")),
        bytes32(keccak256("cotton_fabric_step_238_white")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_238_white"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_238_white"))),
        bytes32(keccak256("cotton_fabric_step_238_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_238_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_polished_slice_750")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Polished Slice750",
        bytes32(keccak256("basalt_polished_slice_750")),
        bytes32(keccak256("basalt_polished_slice_750")),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished_slice_750"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished_slice_750"))),
        bytes32(keccak256("basalt_polished_slice_750")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_polished_slice_750")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_128_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab128 Blue",
        bytes32(keccak256("cotton_fabric_slab_128_blue")),
        bytes32(keccak256("cotton_fabric_slab_128_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_128_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_128_blue"))),
        bytes32(keccak256("cotton_fabric_slab_128_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_128_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_172_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab172 White",
        bytes32(keccak256("cotton_fabric_slab_172_white")),
        bytes32(keccak256("cotton_fabric_slab_172_white")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_172_white"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_172_white"))),
        bytes32(keccak256("cotton_fabric_slab_172_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_172_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_172_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab172 Blue",
        bytes32(keccak256("cotton_fabric_slab_172_blue")),
        bytes32(keccak256("cotton_fabric_slab_172_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_172_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_172_blue"))),
        bytes32(keccak256("cotton_fabric_slab_172_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_172_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_128_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab128 White",
        bytes32(keccak256("cotton_fabric_slab_128_white")),
        bytes32(keccak256("cotton_fabric_slab_128_white")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_128_white"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_128_white"))),
        bytes32(keccak256("cotton_fabric_slab_128_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_128_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_polished_stool_1031")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Polished Stool1031",
        bytes32(keccak256("basalt_polished_stool_1031")),
        bytes32(keccak256("basalt_polished_stool_1031")),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished_stool_1031"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished_stool_1031"))),
        bytes32(keccak256("basalt_polished_stool_1031")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_polished_stool_1031")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_track_1349")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Track1349",
        bytes32(keccak256("oak_lumber_track_1349")),
        bytes32(keccak256("oak_lumber_track_1349")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_track_1349"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_track_1349"))),
        bytes32(keccak256("oak_lumber_track_1349")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_track_1349")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_polished_track_1388")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Polished Track1388",
        bytes32(keccak256("basalt_polished_track_1388")),
        bytes32(keccak256("basalt_polished_track_1388")),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished_track_1388"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished_track_1388"))),
        bytes32(keccak256("basalt_polished_track_1388")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_polished_track_1388")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_yellow")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Yellow",
        bytes32(keccak256("cotton_fabric_yellow")),
        bytes32(keccak256("cotton_fabric_yellow")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_yellow"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_yellow"))),
        bytes32(keccak256("cotton_fabric_yellow")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_yellow")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_polished_stool_1067")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Polished Stool1067",
        bytes32(keccak256("basalt_polished_stool_1067")),
        bytes32(keccak256("basalt_polished_stool_1067")),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished_stool_1067"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished_stool_1067"))),
        bytes32(keccak256("basalt_polished_stool_1067")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_polished_stool_1067")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Purple",
        bytes32(keccak256("cotton_fabric_purple")),
        bytes32(keccak256("cotton_fabric_purple")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_purple"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_purple"))),
        bytes32(keccak256("cotton_fabric_purple")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_window_576_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Window576 Blue",
        bytes32(keccak256("cotton_fabric_window_576_blue")),
        bytes32(keccak256("cotton_fabric_window_576_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_window_576_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_window_576_blue"))),
        bytes32(keccak256("cotton_fabric_window_576_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_window_576_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Red",
        bytes32(keccak256("cotton_fabric_red")),
        bytes32(keccak256("cotton_fabric_red")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_red"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_red"))),
        bytes32(keccak256("cotton_fabric_red")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_window_578_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Window578 Orange",
        bytes32(keccak256("cotton_fabric_window_578_orange")),
        bytes32(keccak256("cotton_fabric_window_578_orange")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_window_578_orange"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_window_578_orange"))),
        bytes32(keccak256("cotton_fabric_window_578_orange")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_window_578_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_window_576_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Window576 Orange",
        bytes32(keccak256("cotton_fabric_window_576_orange")),
        bytes32(keccak256("cotton_fabric_window_576_orange")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_window_576_orange"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_window_576_orange"))),
        bytes32(keccak256("cotton_fabric_window_576_orange")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_window_576_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_window_620_yellow")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Window620 Yellow",
        bytes32(keccak256("cotton_fabric_window_620_yellow")),
        bytes32(keccak256("cotton_fabric_window_620_yellow")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_window_620_yellow"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_window_620_yellow"))),
        bytes32(keccak256("cotton_fabric_window_620_yellow")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_window_620_yellow")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Orange",
        bytes32(keccak256("cotton_fabric_orange")),
        bytes32(keccak256("cotton_fabric_orange")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_orange"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_orange"))),
        bytes32(keccak256("cotton_fabric_orange")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_peg_809")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Peg809",
        bytes32(keccak256("led_peg_809")),
        bytes32(keccak256("led_peg_809")),
        getChildVoxelTypes(bytes32(keccak256("led_peg_809"))),
        getChildVoxelTypes(bytes32(keccak256("led_peg_809"))),
        bytes32(keccak256("led_peg_809")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_peg_809")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_polished_stub_1257")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Polished Stub1257",
        bytes32(keccak256("basalt_polished_stub_1257")),
        bytes32(keccak256("basalt_polished_stub_1257")),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished_stub_1257"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished_stub_1257"))),
        bytes32(keccak256("basalt_polished_stub_1257")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_polished_stub_1257")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_yellow")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Yellow",
        bytes32(keccak256("oak_lumber_yellow")),
        bytes32(keccak256("oak_lumber_yellow")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_yellow"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_yellow"))),
        bytes32(keccak256("oak_lumber_yellow")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_yellow")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_171")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab171",
        bytes32(keccak256("cotton_fabric_slab_171")),
        bytes32(keccak256("cotton_fabric_slab_171")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_171"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_171"))),
        bytes32(keccak256("cotton_fabric_slab_171")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_171")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_135")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab135",
        bytes32(keccak256("cotton_fabric_slab_135")),
        bytes32(keccak256("cotton_fabric_slab_135")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_135"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_135"))),
        bytes32(keccak256("cotton_fabric_slab_135")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_135")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_235")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step235",
        bytes32(keccak256("cotton_fabric_step_235")),
        bytes32(keccak256("cotton_fabric_step_235")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_235"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_235"))),
        bytes32(keccak256("cotton_fabric_step_235")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_235")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_453_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall453 Blue",
        bytes32(keccak256("cotton_fabric_wall_453_blue")),
        bytes32(keccak256("cotton_fabric_wall_453_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_453_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_453_blue"))),
        bytes32(keccak256("cotton_fabric_wall_453_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_453_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_174_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab174 Purple",
        bytes32(keccak256("oak_lumber_slab_174_purple")),
        bytes32(keccak256("oak_lumber_slab_174_purple")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_174_purple"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_174_purple"))),
        bytes32(keccak256("oak_lumber_slab_174_purple")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_174_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_174_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab174 Pink",
        bytes32(keccak256("oak_lumber_slab_174_pink")),
        bytes32(keccak256("oak_lumber_slab_174_pink")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_174_pink"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_174_pink"))),
        bytes32(keccak256("oak_lumber_slab_174_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_174_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_174_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab174 Orange",
        bytes32(keccak256("oak_lumber_slab_174_orange")),
        bytes32(keccak256("oak_lumber_slab_174_orange")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_174_orange"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_174_orange"))),
        bytes32(keccak256("oak_lumber_slab_174_orange")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_174_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_194_yellow")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step194 Yellow",
        bytes32(keccak256("oak_lumber_step_194_yellow")),
        bytes32(keccak256("oak_lumber_step_194_yellow")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_194_yellow"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_194_yellow"))),
        bytes32(keccak256("oak_lumber_step_194_yellow")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_194_yellow")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_489_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall489 Blue",
        bytes32(keccak256("cotton_fabric_wall_489_blue")),
        bytes32(keccak256("cotton_fabric_wall_489_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_489_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_489_blue"))),
        bytes32(keccak256("cotton_fabric_wall_489_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_489_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_492_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall492 Blue",
        bytes32(keccak256("cotton_fabric_wall_492_blue")),
        bytes32(keccak256("cotton_fabric_wall_492_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_492_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_492_blue"))),
        bytes32(keccak256("cotton_fabric_wall_492_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_492_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moonstone_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moonstone Slab172",
        bytes32(keccak256("moonstone_slab_172")),
        bytes32(keccak256("moonstone_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("moonstone_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("moonstone_slab_172"))),
        bytes32(keccak256("moonstone_slab_172")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moonstone_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moonstone_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moonstone Slab128",
        bytes32(keccak256("moonstone_slab_128")),
        bytes32(keccak256("moonstone_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("moonstone_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("moonstone_slab_128"))),
        bytes32(keccak256("moonstone_slab_128")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moonstone_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_448_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall448 Blue",
        bytes32(keccak256("cotton_fabric_wall_448_blue")),
        bytes32(keccak256("cotton_fabric_wall_448_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_448_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_448_blue"))),
        bytes32(keccak256("cotton_fabric_wall_448_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_448_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_235_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step235 Green",
        bytes32(keccak256("oak_lumber_step_235_green")),
        bytes32(keccak256("oak_lumber_step_235_green")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_235_green"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_235_green"))),
        bytes32(keccak256("oak_lumber_step_235_green")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_235_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Step197",
        bytes32(keccak256("silver_step_197")),
        bytes32(keccak256("silver_step_197")),
        getChildVoxelTypes(bytes32(keccak256("silver_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("silver_step_197"))),
        bytes32(keccak256("silver_step_197")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1157_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1157 Orange",
        bytes32(keccak256("cotton_fabric_outset_1157_orange")),
        bytes32(keccak256("cotton_fabric_outset_1157_orange")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1157_orange"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1157_orange"))),
        bytes32(keccak256("cotton_fabric_outset_1157_orange")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1157_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_slice_706")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Slice706",
        bytes32(keccak256("silver_slice_706")),
        bytes32(keccak256("silver_slice_706")),
        getChildVoxelTypes(bytes32(keccak256("silver_slice_706"))),
        getChildVoxelTypes(bytes32(keccak256("silver_slice_706"))),
        bytes32(keccak256("silver_slice_706")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_slice_706")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_outset_1152")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Outset1152",
        bytes32(keccak256("moss_outset_1152")),
        bytes32(keccak256("moss_outset_1152")),
        getChildVoxelTypes(bytes32(keccak256("moss_outset_1152"))),
        getChildVoxelTypes(bytes32(keccak256("moss_outset_1152"))),
        bytes32(keccak256("moss_outset_1152")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_outset_1152")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_171_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab171 White",
        bytes32(keccak256("oak_lumber_slab_171_white")),
        bytes32(keccak256("oak_lumber_slab_171_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_171_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_171_white"))),
        bytes32(keccak256("oak_lumber_slab_171_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_171_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_135_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab135 Black",
        bytes32(keccak256("oak_lumber_slab_135_black")),
        bytes32(keccak256("oak_lumber_slab_135_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_135_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_135_black"))),
        bytes32(keccak256("oak_lumber_slab_135_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_135_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_238")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step238",
        bytes32(keccak256("cotton_fabric_step_238")),
        bytes32(keccak256("cotton_fabric_step_238")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_238"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_238"))),
        bytes32(keccak256("cotton_fabric_step_238")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_238")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Wall492",
        bytes32(keccak256("clay_polished_wall_492")),
        bytes32(keccak256("clay_polished_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_492"))),
        bytes32(keccak256("clay_polished_wall_492")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_wall_492")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Wall489",
        bytes32(keccak256("clay_polished_wall_489")),
        bytes32(keccak256("clay_polished_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_489"))),
        bytes32(keccak256("clay_polished_wall_489")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_carved_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Carved Slab172",
        bytes32(keccak256("basalt_carved_slab_172")),
        bytes32(keccak256("basalt_carved_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("basalt_carved_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_carved_slab_172"))),
        bytes32(keccak256("basalt_carved_slab_172")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_carved_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_carved_beam_1324")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Carved Beam1324",
        bytes32(keccak256("basalt_carved_beam_1324")),
        bytes32(keccak256("basalt_carved_beam_1324")),
        getChildVoxelTypes(bytes32(keccak256("basalt_carved_beam_1324"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_carved_beam_1324"))),
        bytes32(keccak256("basalt_carved_beam_1324")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_carved_beam_1324")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_beam_1280")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Beam1280",
        bytes32(keccak256("silver_beam_1280")),
        bytes32(keccak256("silver_beam_1280")),
        getChildVoxelTypes(bytes32(keccak256("silver_beam_1280"))),
        getChildVoxelTypes(bytes32(keccak256("silver_beam_1280"))),
        bytes32(keccak256("silver_beam_1280")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_beam_1280")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1196_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1196 Pink",
        bytes32(keccak256("cotton_fabric_outset_1196_pink")),
        bytes32(keccak256("cotton_fabric_outset_1196_pink")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1196_pink"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1196_pink"))),
        bytes32(keccak256("cotton_fabric_outset_1196_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1196_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moonstone_stub_1218")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moonstone Stub1218",
        bytes32(keccak256("moonstone_stub_1218")),
        bytes32(keccak256("moonstone_stub_1218")),
        getChildVoxelTypes(bytes32(keccak256("moonstone_stub_1218"))),
        getChildVoxelTypes(bytes32(keccak256("moonstone_stub_1218"))),
        bytes32(keccak256("moonstone_stub_1218")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moonstone_stub_1218")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_window_617")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Window617",
        bytes32(keccak256("silver_window_617")),
        bytes32(keccak256("silver_window_617")),
        getChildVoxelTypes(bytes32(keccak256("silver_window_617"))),
        getChildVoxelTypes(bytes32(keccak256("silver_window_617"))),
        bytes32(keccak256("silver_window_617")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_window_617")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_709_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice709 Orange",
        bytes32(keccak256("cotton_fabric_slice_709_orange")),
        bytes32(keccak256("cotton_fabric_slice_709_orange")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_709_orange"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_709_orange"))),
        bytes32(keccak256("cotton_fabric_slice_709_orange")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_709_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_slice_704")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Slice704",
        bytes32(keccak256("moss_slice_704")),
        bytes32(keccak256("moss_slice_704")),
        getChildVoxelTypes(bytes32(keccak256("moss_slice_704"))),
        getChildVoxelTypes(bytes32(keccak256("moss_slice_704"))),
        bytes32(keccak256("moss_slice_704")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_slice_704")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_704_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice704 Blue",
        bytes32(keccak256("cotton_fabric_slice_704_blue")),
        bytes32(keccak256("cotton_fabric_slice_704_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_704_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_704_blue"))),
        bytes32(keccak256("cotton_fabric_slice_704_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_704_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_128_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab128 Orange",
        bytes32(keccak256("cotton_fabric_slab_128_orange")),
        bytes32(keccak256("cotton_fabric_slab_128_orange")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_128_orange"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_128_orange"))),
        bytes32(keccak256("cotton_fabric_slab_128_orange")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_128_orange")));

    vm.stopBroadcast();
  }
}
