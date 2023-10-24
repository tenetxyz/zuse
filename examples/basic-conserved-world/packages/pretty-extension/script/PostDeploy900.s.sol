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

contract PostDeploy900 is Script {
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
        registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_outset_1152")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Outset1152",
        bytes32(keccak256("neptunium_outset_1152")),
        bytes32(keccak256("neptunium_outset_1152")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_outset_1152"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_outset_1152"))),
        bytes32(keccak256("neptunium_outset_1152")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_outset_1152")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_frame_684")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Frame684",
        bytes32(keccak256("rubber_stripped_frame_684")),
        bytes32(keccak256("rubber_stripped_frame_684")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_frame_684"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_frame_684"))),
        bytes32(keccak256("rubber_stripped_frame_684")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_frame_684")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1260")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Stub1260",
        bytes32(keccak256("cotton_fabric_stub_1260")),
        bytes32(keccak256("cotton_fabric_stub_1260")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1260"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1260"))),
        bytes32(keccak256("cotton_fabric_stub_1260")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1260")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slice_704_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slice704 White",
        bytes32(keccak256("oak_lumber_slice_704_white")),
        bytes32(keccak256("oak_lumber_slice_704_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_704_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_704_white"))),
        bytes32(keccak256("oak_lumber_slice_704_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slice_704_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_slab_135")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Slab135",
        bytes32(keccak256("neptunium_slab_135")),
        bytes32(keccak256("neptunium_slab_135")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_slab_135"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_slab_135"))),
        bytes32(keccak256("neptunium_slab_135")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_slab_135")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_frame_645")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Frame645",
        bytes32(keccak256("neptunium_frame_645")),
        bytes32(keccak256("neptunium_frame_645")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_frame_645"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_frame_645"))),
        bytes32(keccak256("neptunium_frame_645")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_frame_645")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_frame_640")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Frame640",
        bytes32(keccak256("neptunium_frame_640")),
        bytes32(keccak256("neptunium_frame_640")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_frame_640"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_frame_640"))),
        bytes32(keccak256("neptunium_frame_640")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_frame_640")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_slab_171")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Slab171",
        bytes32(keccak256("neptunium_slab_171")),
        bytes32(keccak256("neptunium_slab_171")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_slab_171"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_slab_171"))),
        bytes32(keccak256("neptunium_slab_171")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_slab_171")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_704_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice704 Black",
        bytes32(keccak256("cotton_fabric_slice_704_black")),
        bytes32(keccak256("cotton_fabric_slice_704_black")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_704_black"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_704_black"))),
        bytes32(keccak256("cotton_fabric_slice_704_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_704_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Slab130",
        bytes32(keccak256("neptunium_slab_130")),
        bytes32(keccak256("neptunium_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_slab_130"))),
        bytes32(keccak256("neptunium_slab_130")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_peg_809")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Peg809",
        bytes32(keccak256("neptunium_peg_809")),
        bytes32(keccak256("neptunium_peg_809")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_peg_809"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_peg_809"))),
        bytes32(keccak256("neptunium_peg_809")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_peg_809")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_stool_1029")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Stool1029",
        bytes32(keccak256("neptunium_stool_1029")),
        bytes32(keccak256("neptunium_stool_1029")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_stool_1029"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_stool_1029"))),
        bytes32(keccak256("neptunium_stool_1029")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_stool_1029")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slice_711")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slice711",
        bytes32(keccak256("oak_lumber_slice_711")),
        bytes32(keccak256("oak_lumber_slice_711")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_711"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_711"))),
        bytes32(keccak256("oak_lumber_slice_711")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slice_711")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_453_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall453 Black",
        bytes32(keccak256("cotton_fabric_wall_453_black")),
        bytes32(keccak256("cotton_fabric_wall_453_black")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_453_black"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_453_black"))),
        bytes32(keccak256("cotton_fabric_wall_453_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_453_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Black",
        bytes32(keccak256("cotton_fabric_black")),
        bytes32(keccak256("cotton_fabric_black")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_black"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_black"))),
        bytes32(keccak256("cotton_fabric_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_492_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall492 Black",
        bytes32(keccak256("cotton_fabric_wall_492_black")),
        bytes32(keccak256("cotton_fabric_wall_492_black")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_492_black"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_492_black"))),
        bytes32(keccak256("cotton_fabric_wall_492_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_492_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_448_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall448 Black",
        bytes32(keccak256("cotton_fabric_wall_448_black")),
        bytes32(keccak256("cotton_fabric_wall_448_black")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_448_black"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_448_black"))),
        bytes32(keccak256("cotton_fabric_wall_448_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_448_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_outset_1157")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Outset1157",
        bytes32(keccak256("rubber_stripped_outset_1157")),
        bytes32(keccak256("rubber_stripped_outset_1157")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_outset_1157"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_outset_1157"))),
        bytes32(keccak256("rubber_stripped_outset_1157")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_outset_1157")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_outset_1193")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Outset1193",
        bytes32(keccak256("rubber_stripped_outset_1193")),
        bytes32(keccak256("rubber_stripped_outset_1193")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_outset_1193"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_outset_1193"))),
        bytes32(keccak256("rubber_stripped_outset_1193")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_outset_1193")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_197_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step197 Black",
        bytes32(keccak256("cotton_fabric_step_197_black")),
        bytes32(keccak256("cotton_fabric_step_197_black")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_197_black"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_197_black"))),
        bytes32(keccak256("cotton_fabric_step_197_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_197_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1029")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Stool1029",
        bytes32(keccak256("rubber_stripped_stool_1029")),
        bytes32(keccak256("rubber_stripped_stool_1029")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1029"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1029"))),
        bytes32(keccak256("rubber_stripped_stool_1029")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1029")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1068")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Stool1068",
        bytes32(keccak256("rubber_stripped_stool_1068")),
        bytes32(keccak256("rubber_stripped_stool_1068")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1068"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_stool_1068"))),
        bytes32(keccak256("rubber_stripped_stool_1068")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_stool_1068")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_log_297")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Log297",
        bytes32(keccak256("clay_log_297")),
        bytes32(keccak256("clay_log_297")),
        getChildVoxelTypes(bytes32(keccak256("clay_log_297"))),
        getChildVoxelTypes(bytes32(keccak256("clay_log_297"))),
        bytes32(keccak256("clay_log_297")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_log_297")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1196_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1196 Blue",
        bytes32(keccak256("cotton_fabric_outset_1196_blue")),
        bytes32(keccak256("cotton_fabric_outset_1196_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1196_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1196_blue"))),
        bytes32(keccak256("cotton_fabric_outset_1196_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1196_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moonstone_slice_706")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moonstone Slice706",
        bytes32(keccak256("moonstone_slice_706")),
        bytes32(keccak256("moonstone_slice_706")),
        getChildVoxelTypes(bytes32(keccak256("moonstone_slice_706"))),
        getChildVoxelTypes(bytes32(keccak256("moonstone_slice_706"))),
        bytes32(keccak256("moonstone_slice_706")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moonstone_slice_706")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_450_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall450 Black",
        bytes32(keccak256("cotton_fabric_wall_450_black")),
        bytes32(keccak256("cotton_fabric_wall_450_black")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_450_black"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_450_black"))),
        bytes32(keccak256("cotton_fabric_wall_450_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_450_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_455_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall455 Black",
        bytes32(keccak256("cotton_fabric_wall_455_black")),
        bytes32(keccak256("cotton_fabric_wall_455_black")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_455_black"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_455_black"))),
        bytes32(keccak256("cotton_fabric_wall_455_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_455_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_stool_1070")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Stool1070",
        bytes32(keccak256("neptunium_stool_1070")),
        bytes32(keccak256("neptunium_stool_1070")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_stool_1070"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_stool_1070"))),
        bytes32(keccak256("neptunium_stool_1070")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_stool_1070")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1152_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1152 Black",
        bytes32(keccak256("simple_glass_outset_1152_black")),
        bytes32(keccak256("simple_glass_outset_1152_black")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1152_black"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1152_black"))),
        bytes32(keccak256("simple_glass_outset_1152_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1152_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1196_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1196 Black",
        bytes32(keccak256("simple_glass_outset_1196_black")),
        bytes32(keccak256("simple_glass_outset_1196_black")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1196_black"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1196_black"))),
        bytes32(keccak256("simple_glass_outset_1196_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1196_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1198_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1198 Black",
        bytes32(keccak256("simple_glass_outset_1198_black")),
        bytes32(keccak256("simple_glass_outset_1198_black")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1198_black"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1198_black"))),
        bytes32(keccak256("simple_glass_outset_1198_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1198_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1154_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1154 Black",
        bytes32(keccak256("simple_glass_outset_1154_black")),
        bytes32(keccak256("simple_glass_outset_1154_black")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1154_black"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1154_black"))),
        bytes32(keccak256("simple_glass_outset_1154_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1154_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1193_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1193 Black",
        bytes32(keccak256("simple_glass_outset_1193_black")),
        bytes32(keccak256("simple_glass_outset_1193_black")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1193_black"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1193_black"))),
        bytes32(keccak256("simple_glass_outset_1193_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1193_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1157_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1157 Black",
        bytes32(keccak256("simple_glass_outset_1157_black")),
        bytes32(keccak256("simple_glass_outset_1157_black")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1157_black"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1157_black"))),
        bytes32(keccak256("simple_glass_outset_1157_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1157_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1159_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1159 Black",
        bytes32(keccak256("simple_glass_outset_1159_black")),
        bytes32(keccak256("simple_glass_outset_1159_black")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1159_black"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1159_black"))),
        bytes32(keccak256("simple_glass_outset_1159_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1159_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_slab_171")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Slab171",
        bytes32(keccak256("birch_lumber_slab_171")),
        bytes32(keccak256("birch_lumber_slab_171")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slab_171"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slab_171"))),
        bytes32(keccak256("birch_lumber_slab_171")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_slab_171")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Slab130",
        bytes32(keccak256("birch_lumber_slab_130")),
        bytes32(keccak256("birch_lumber_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slab_130"))),
        bytes32(keccak256("birch_lumber_slab_130")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_step_238")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Step238",
        bytes32(keccak256("cobblestone_brick_step_238")),
        bytes32(keccak256("cobblestone_brick_step_238")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_step_238"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_step_238"))),
        bytes32(keccak256("cobblestone_brick_step_238")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_step_238")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Slab133",
        bytes32(keccak256("cobblestone_brick_slab_133")),
        bytes32(keccak256("cobblestone_brick_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_133"))),
        bytes32(keccak256("cobblestone_brick_slab_133")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Slab169",
        bytes32(keccak256("cobblestone_brick_slab_169")),
        bytes32(keccak256("cobblestone_brick_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_169"))),
        bytes32(keccak256("cobblestone_brick_slab_169")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Slab130",
        bytes32(keccak256("cobblestone_brick_slab_130")),
        bytes32(keccak256("cobblestone_brick_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_130"))),
        bytes32(keccak256("cobblestone_brick_slab_130")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Slab128",
        bytes32(keccak256("cobblestone_brick_slab_128")),
        bytes32(keccak256("cobblestone_brick_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_slab_128"))),
        bytes32(keccak256("cobblestone_brick_slab_128")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_step_235")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Step235",
        bytes32(keccak256("cobblestone_brick_step_235")),
        bytes32(keccak256("cobblestone_brick_step_235")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_step_235"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_step_235"))),
        bytes32(keccak256("cobblestone_brick_step_235")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_step_235")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_489_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall489 White",
        bytes32(keccak256("oak_lumber_wall_489_white")),
        bytes32(keccak256("oak_lumber_wall_489_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_489_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_489_white"))),
        bytes32(keccak256("oak_lumber_wall_489_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_489_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_492_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall492 White",
        bytes32(keccak256("oak_lumber_wall_492_white")),
        bytes32(keccak256("oak_lumber_wall_492_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_492_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_492_white"))),
        bytes32(keccak256("oak_lumber_wall_492_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_492_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_768_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg768 Green",
        bytes32(keccak256("oak_lumber_peg_768_green")),
        bytes32(keccak256("oak_lumber_peg_768_green")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_768_green"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_768_green"))),
        bytes32(keccak256("oak_lumber_peg_768_green")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_768_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_704")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice704",
        bytes32(keccak256("cotton_fabric_slice_704")),
        bytes32(keccak256("cotton_fabric_slice_704")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_704"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_704"))),
        bytes32(keccak256("cotton_fabric_slice_704")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_704")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_320_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence320 Green",
        bytes32(keccak256("oak_lumber_fence_320_green")),
        bytes32(keccak256("oak_lumber_fence_320_green")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_320_green"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_320_green"))),
        bytes32(keccak256("oak_lumber_fence_320_green")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_320_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_window_581_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Window581 Green",
        bytes32(keccak256("oak_lumber_window_581_green")),
        bytes32(keccak256("oak_lumber_window_581_green")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_window_581_green"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_window_581_green"))),
        bytes32(keccak256("oak_lumber_window_581_green")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_window_581_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_745_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice745 Blue",
        bytes32(keccak256("cotton_fabric_slice_745_blue")),
        bytes32(keccak256("cotton_fabric_slice_745_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_745_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_745_blue"))),
        bytes32(keccak256("cotton_fabric_slice_745_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_745_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab169 Blue",
        bytes32(keccak256("cotton_fabric_slab_169_blue")),
        bytes32(keccak256("cotton_fabric_slab_169_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_169_blue"))),
        bytes32(keccak256("cotton_fabric_slab_169_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_169_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_window_617_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Window617 Green",
        bytes32(keccak256("oak_lumber_window_617_green")),
        bytes32(keccak256("oak_lumber_window_617_green")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_window_617_green"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_window_617_green"))),
        bytes32(keccak256("oak_lumber_window_617_green")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_window_617_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_364_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence364 Green",
        bytes32(keccak256("oak_lumber_fence_364_green")),
        bytes32(keccak256("oak_lumber_fence_364_green")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_364_green"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_364_green"))),
        bytes32(keccak256("oak_lumber_fence_364_green")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_364_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_peg_812")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Peg812",
        bytes32(keccak256("rubber_stripped_peg_812")),
        bytes32(keccak256("rubber_stripped_peg_812")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_peg_812"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_peg_812"))),
        bytes32(keccak256("rubber_stripped_peg_812")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_peg_812")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1193_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1193 Green",
        bytes32(keccak256("cotton_fabric_outset_1193_green")),
        bytes32(keccak256("cotton_fabric_outset_1193_green")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1193_green"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1193_green"))),
        bytes32(keccak256("cotton_fabric_outset_1193_green")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1193_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_peg_773")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Peg773",
        bytes32(keccak256("rubber_stripped_peg_773")),
        bytes32(keccak256("rubber_stripped_peg_773")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_peg_773"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_peg_773"))),
        bytes32(keccak256("rubber_stripped_peg_773")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_peg_773")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_stub_1218")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Stub1218",
        bytes32(keccak256("clay_polished_stub_1218")),
        bytes32(keccak256("clay_polished_stub_1218")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stub_1218"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stub_1218"))),
        bytes32(keccak256("clay_polished_stub_1218")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_stub_1218")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_199_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step199 Blue",
        bytes32(keccak256("cotton_fabric_step_199_blue")),
        bytes32(keccak256("cotton_fabric_step_199_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_199_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_199_blue"))),
        bytes32(keccak256("cotton_fabric_step_199_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_199_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_194_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step194 Blue",
        bytes32(keccak256("cotton_fabric_step_194_blue")),
        bytes32(keccak256("cotton_fabric_step_194_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_194_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_194_blue"))),
        bytes32(keccak256("cotton_fabric_step_194_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_194_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_325_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence325 White",
        bytes32(keccak256("oak_lumber_fence_325_white")),
        bytes32(keccak256("oak_lumber_fence_325_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_325_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_325_white"))),
        bytes32(keccak256("oak_lumber_fence_325_white")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_325_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_235_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step235 Blue",
        bytes32(keccak256("cotton_fabric_step_235_blue")),
        bytes32(keccak256("cotton_fabric_step_235_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_235_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_235_blue"))),
        bytes32(keccak256("cotton_fabric_step_235_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_235_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1193_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1193 Blue",
        bytes32(keccak256("cotton_fabric_outset_1193_blue")),
        bytes32(keccak256("cotton_fabric_outset_1193_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1193_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1193_blue"))),
        bytes32(keccak256("cotton_fabric_outset_1193_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1193_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_133_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab133 Red",
        bytes32(keccak256("oak_lumber_slab_133_red")),
        bytes32(keccak256("oak_lumber_slab_133_red")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_133_red"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_133_red"))),
        bytes32(keccak256("oak_lumber_slab_133_red")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_133_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_172_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab172 Red",
        bytes32(keccak256("cotton_fabric_slab_172_red")),
        bytes32(keccak256("cotton_fabric_slab_172_red")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_172_red"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_172_red"))),
        bytes32(keccak256("cotton_fabric_slab_172_red")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_172_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_stool_1026")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Stool1026",
        bytes32(keccak256("clay_polished_stool_1026")),
        bytes32(keccak256("clay_polished_stool_1026")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stool_1026"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stool_1026"))),
        bytes32(keccak256("clay_polished_stool_1026")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_stool_1026")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slab_171")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slab171",
        bytes32(keccak256("basalt_shingles_slab_171")),
        bytes32(keccak256("basalt_shingles_slab_171")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_171"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_171"))),
        bytes32(keccak256("basalt_shingles_slab_171")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slab_171")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_fence_320")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Fence320",
        bytes32(keccak256("cobblestone_brick_fence_320")),
        bytes32(keccak256("cobblestone_brick_fence_320")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_fence_320"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_fence_320"))),
        bytes32(keccak256("cobblestone_brick_fence_320")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_fence_320")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_fence_325")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Fence325",
        bytes32(keccak256("cobblestone_brick_fence_325")),
        bytes32(keccak256("cobblestone_brick_fence_325")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_fence_325"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_fence_325"))),
        bytes32(keccak256("cobblestone_brick_fence_325")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_fence_325")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_log_peg_812")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Log Peg812",
        bytes32(keccak256("birch_log_peg_812")),
        bytes32(keccak256("birch_log_peg_812")),
        getChildVoxelTypes(bytes32(keccak256("birch_log_peg_812"))),
        getChildVoxelTypes(bytes32(keccak256("birch_log_peg_812"))),
        bytes32(keccak256("birch_log_peg_812")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_log_peg_812")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_log_stool_1068")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Log Stool1068",
        bytes32(keccak256("birch_log_stool_1068")),
        bytes32(keccak256("birch_log_stool_1068")),
        getChildVoxelTypes(bytes32(keccak256("birch_log_stool_1068"))),
        getChildVoxelTypes(bytes32(keccak256("birch_log_stool_1068"))),
        bytes32(keccak256("birch_log_stool_1068")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_log_stool_1068")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_stool_1067")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Stool1067",
        bytes32(keccak256("silver_stool_1067")),
        bytes32(keccak256("silver_stool_1067")),
        getChildVoxelTypes(bytes32(keccak256("silver_stool_1067"))),
        getChildVoxelTypes(bytes32(keccak256("silver_stool_1067"))),
        bytes32(keccak256("silver_stool_1067")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_stool_1067")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_knob_901")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Knob901",
        bytes32(keccak256("clay_polished_knob_901")),
        bytes32(keccak256("clay_polished_knob_901")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_knob_901"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_knob_901"))),
        bytes32(keccak256("clay_polished_knob_901")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_knob_901")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_knob_940")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Knob940",
        bytes32(keccak256("clay_polished_knob_940")),
        bytes32(keccak256("clay_polished_knob_940")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_knob_940"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_knob_940"))),
        bytes32(keccak256("clay_polished_knob_940")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_knob_940")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_wall_448")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Wall448",
        bytes32(keccak256("clay_polished_wall_448")),
        bytes32(keccak256("clay_polished_wall_448")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_448"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_448"))),
        bytes32(keccak256("clay_polished_wall_448")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_wall_448")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_table_428")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Table428",
        bytes32(keccak256("oak_lumber_table_428")),
        bytes32(keccak256("oak_lumber_table_428")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_table_428"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_table_428"))),
        bytes32(keccak256("oak_lumber_table_428")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_table_428")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_wall_453")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Wall453",
        bytes32(keccak256("clay_polished_wall_453")),
        bytes32(keccak256("clay_polished_wall_453")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_453"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_453"))),
        bytes32(keccak256("clay_polished_wall_453")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_wall_453")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_745")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice745",
        bytes32(keccak256("cotton_fabric_slice_745")),
        bytes32(keccak256("cotton_fabric_slice_745")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_745"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_745"))),
        bytes32(keccak256("cotton_fabric_slice_745")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_745")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_knob_937")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Knob937",
        bytes32(keccak256("clay_polished_knob_937")),
        bytes32(keccak256("clay_polished_knob_937")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_knob_937"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_knob_937"))),
        bytes32(keccak256("clay_polished_knob_937")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_knob_937")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_wall_455")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Wall455",
        bytes32(keccak256("clay_polished_wall_455")),
        bytes32(keccak256("clay_polished_wall_455")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_455"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_455"))),
        bytes32(keccak256("clay_polished_wall_455")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_wall_455")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_knob_896")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Knob896",
        bytes32(keccak256("clay_polished_knob_896")),
        bytes32(keccak256("clay_polished_knob_896")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_knob_896"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_knob_896"))),
        bytes32(keccak256("clay_polished_knob_896")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_knob_896")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_stool_1070")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Stool1070",
        bytes32(keccak256("silver_stool_1070")),
        bytes32(keccak256("silver_stool_1070")),
        getChildVoxelTypes(bytes32(keccak256("silver_stool_1070"))),
        getChildVoxelTypes(bytes32(keccak256("silver_stool_1070"))),
        bytes32(keccak256("silver_stool_1070")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_stool_1070")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_stub_1216_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Stub1216 Blue",
        bytes32(keccak256("led_stub_1216_blue")),
        bytes32(keccak256("led_stub_1216_blue")),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1216_blue"))),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1216_blue"))),
        bytes32(keccak256("led_stub_1216_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_stub_1216_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_outset_1152")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Outset1152",
        bytes32(keccak256("oak_stripped_outset_1152")),
        bytes32(keccak256("oak_stripped_outset_1152")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_outset_1152"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_outset_1152"))),
        bytes32(keccak256("oak_stripped_outset_1152")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_outset_1152")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_wall_450")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Wall450",
        bytes32(keccak256("clay_polished_wall_450")),
        bytes32(keccak256("clay_polished_wall_450")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_450"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_450"))),
        bytes32(keccak256("clay_polished_wall_450")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_wall_450")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("wood_crate_table_384")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Wood Crate Table384",
        bytes32(keccak256("wood_crate_table_384")),
        bytes32(keccak256("wood_crate_table_384")),
        getChildVoxelTypes(bytes32(keccak256("wood_crate_table_384"))),
        getChildVoxelTypes(bytes32(keccak256("wood_crate_table_384"))),
        bytes32(keccak256("wood_crate_table_384")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("wood_crate_table_384")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_709_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice709 Blue",
        bytes32(keccak256("cotton_fabric_slice_709_blue")),
        bytes32(keccak256("cotton_fabric_slice_709_blue")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_709_blue"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_709_blue"))),
        bytes32(keccak256("cotton_fabric_slice_709_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_709_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_step_238")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Step238",
        bytes32(keccak256("moss_step_238")),
        bytes32(keccak256("moss_step_238")),
        getChildVoxelTypes(bytes32(keccak256("moss_step_238"))),
        getChildVoxelTypes(bytes32(keccak256("moss_step_238"))),
        bytes32(keccak256("moss_step_238")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_step_238")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_outset_1157")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Outset1157",
        bytes32(keccak256("moss_outset_1157")),
        bytes32(keccak256("moss_outset_1157")),
        getChildVoxelTypes(bytes32(keccak256("moss_outset_1157"))),
        getChildVoxelTypes(bytes32(keccak256("moss_outset_1157"))),
        bytes32(keccak256("moss_outset_1157")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_outset_1157")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_step_235")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Step235",
        bytes32(keccak256("moss_step_235")),
        bytes32(keccak256("moss_step_235")),
        getChildVoxelTypes(bytes32(keccak256("moss_step_235"))),
        getChildVoxelTypes(bytes32(keccak256("moss_step_235"))),
        bytes32(keccak256("moss_step_235")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_step_235")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_wall_453")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Wall453",
        bytes32(keccak256("moss_wall_453")),
        bytes32(keccak256("moss_wall_453")),
        getChildVoxelTypes(bytes32(keccak256("moss_wall_453"))),
        getChildVoxelTypes(bytes32(keccak256("moss_wall_453"))),
        bytes32(keccak256("moss_wall_453")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_wall_453")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_wall_448")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Wall448",
        bytes32(keccak256("moss_wall_448")),
        bytes32(keccak256("moss_wall_448")),
        getChildVoxelTypes(bytes32(keccak256("moss_wall_448"))),
        getChildVoxelTypes(bytes32(keccak256("moss_wall_448"))),
        bytes32(keccak256("moss_wall_448")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_wall_448")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_wall_494")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Wall494",
        bytes32(keccak256("clay_polished_wall_494")),
        bytes32(keccak256("clay_polished_wall_494")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_494"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_wall_494"))),
        bytes32(keccak256("clay_polished_wall_494")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_wall_494")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_knob_940")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Knob940",
        bytes32(keccak256("cotton_fabric_knob_940")),
        bytes32(keccak256("cotton_fabric_knob_940")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_940"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_940"))),
        bytes32(keccak256("cotton_fabric_knob_940")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_knob_940")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_knob_901")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Knob901",
        bytes32(keccak256("cobblestone_knob_901")),
        bytes32(keccak256("cobblestone_knob_901")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_knob_901"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_knob_901"))),
        bytes32(keccak256("cobblestone_knob_901")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_knob_901")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_window_620")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Window620",
        bytes32(keccak256("rubber_lumber_window_620")),
        bytes32(keccak256("rubber_lumber_window_620")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_window_620"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_window_620"))),
        bytes32(keccak256("rubber_lumber_window_620")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_window_620")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_beam_1285_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Beam1285 Blue",
        bytes32(keccak256("led_beam_1285_blue")),
        bytes32(keccak256("led_beam_1285_blue")),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1285_blue"))),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1285_blue"))),
        bytes32(keccak256("led_beam_1285_blue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_beam_1285_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_step_238")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Step238",
        bytes32(keccak256("rubber_lumber_step_238")),
        bytes32(keccak256("rubber_lumber_step_238")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_step_238"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_step_238"))),
        bytes32(keccak256("rubber_lumber_step_238")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_step_238")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("quartzite_shingles_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Quartzite Shingles Step197",
        bytes32(keccak256("quartzite_shingles_step_197")),
        bytes32(keccak256("quartzite_shingles_step_197")),
        getChildVoxelTypes(bytes32(keccak256("quartzite_shingles_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("quartzite_shingles_step_197"))),
        bytes32(keccak256("quartzite_shingles_step_197")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("quartzite_shingles_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_beam_1324_lightblue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Beam1324 Lightblue",
        bytes32(keccak256("led_beam_1324_lightblue")),
        bytes32(keccak256("led_beam_1324_lightblue")),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1324_lightblue"))),
        getChildVoxelTypes(bytes32(keccak256("led_beam_1324_lightblue"))),
        bytes32(keccak256("led_beam_1324_lightblue")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_beam_1324_lightblue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Step233",
        bytes32(keccak256("birch_lumber_step_233")),
        bytes32(keccak256("birch_lumber_step_233")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_233"))),
        bytes32(keccak256("birch_lumber_step_233")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_step_233")));

    vm.stopBroadcast();
  }
}
