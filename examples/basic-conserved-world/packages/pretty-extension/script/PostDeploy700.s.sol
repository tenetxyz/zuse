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

contract PostDeploy700 is Script {
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
        registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_stool_1024")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Stool1024",
        bytes32(keccak256("silver_stool_1024")),
        bytes32(keccak256("silver_stool_1024")),
        getChildVoxelTypes(bytes32(keccak256("silver_stool_1024"))),
        getChildVoxelTypes(bytes32(keccak256("silver_stool_1024"))),
        bytes32(keccak256("silver_stool_1024")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_stool_1024")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1196_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Outset1196 Purple",
        bytes32(keccak256("cotton_fabric_outset_1196_purple")),
        bytes32(keccak256("cotton_fabric_outset_1196_purple")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1196_purple"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_outset_1196_purple"))),
        bytes32(keccak256("cotton_fabric_outset_1196_purple")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_outset_1196_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_slab_171")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Slab171",
        bytes32(keccak256("clay_polished_slab_171")),
        bytes32(keccak256("clay_polished_slab_171")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_171"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_171"))),
        bytes32(keccak256("clay_polished_slab_171")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_slab_171")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_step_194")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Step194",
        bytes32(keccak256("clay_polished_step_194")),
        bytes32(keccak256("clay_polished_step_194")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_step_194"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_step_194"))),
        bytes32(keccak256("clay_polished_step_194")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_step_194")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab172",
        bytes32(keccak256("oak_lumber_slab_172")),
        bytes32(keccak256("oak_lumber_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_172"))),
        bytes32(keccak256("oak_lumber_slab_172")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Slab172",
        bytes32(keccak256("silver_slab_172")),
        bytes32(keccak256("silver_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("silver_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("silver_slab_172"))),
        bytes32(keccak256("silver_slab_172")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_step_192")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Step192",
        bytes32(keccak256("silver_step_192")),
        bytes32(keccak256("silver_step_192")),
        getChildVoxelTypes(bytes32(keccak256("silver_step_192"))),
        getChildVoxelTypes(bytes32(keccak256("silver_step_192"))),
        bytes32(keccak256("silver_step_192")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_step_192")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1221_yellow")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Stub1221 Yellow",
        bytes32(keccak256("cotton_fabric_stub_1221_yellow")),
        bytes32(keccak256("cotton_fabric_stub_1221_yellow")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1221_yellow"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1221_yellow"))),
        bytes32(keccak256("cotton_fabric_stub_1221_yellow")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1221_yellow")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_track_1351")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Track1351",
        bytes32(keccak256("oak_lumber_track_1351")),
        bytes32(keccak256("oak_lumber_track_1351")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_track_1351"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_track_1351"))),
        bytes32(keccak256("oak_lumber_track_1351")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_track_1351")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1221_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Stub1221 Orange",
        bytes32(keccak256("cotton_fabric_stub_1221_orange")),
        bytes32(keccak256("cotton_fabric_stub_1221_orange")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1221_orange"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1221_orange"))),
        bytes32(keccak256("cotton_fabric_stub_1221_orange")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1221_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_track_1388")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Track1388",
        bytes32(keccak256("oak_stripped_track_1388")),
        bytes32(keccak256("oak_stripped_track_1388")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_track_1388"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_track_1388"))),
        bytes32(keccak256("oak_stripped_track_1388")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_track_1388")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_453")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall453",
        bytes32(keccak256("cotton_fabric_wall_453")),
        bytes32(keccak256("cotton_fabric_wall_453")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_453"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_453"))),
        bytes32(keccak256("cotton_fabric_wall_453")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_453")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_stub_1262")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Stub1262",
        bytes32(keccak256("led_stub_1262")),
        bytes32(keccak256("led_stub_1262")),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1262"))),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1262"))),
        bytes32(keccak256("led_stub_1262")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_stub_1262")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_peg_768")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Peg768",
        bytes32(keccak256("cotton_fabric_peg_768")),
        bytes32(keccak256("cotton_fabric_peg_768")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_peg_768"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_peg_768"))),
        bytes32(keccak256("cotton_fabric_peg_768")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_peg_768")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall492",
        bytes32(keccak256("cotton_fabric_wall_492")),
        bytes32(keccak256("cotton_fabric_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_492"))),
        bytes32(keccak256("cotton_fabric_wall_492")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_492")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_748_pink")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice748 Pink",
        bytes32(keccak256("cotton_fabric_slice_748_pink")),
        bytes32(keccak256("cotton_fabric_slice_748_pink")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_748_pink"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_748_pink"))),
        bytes32(keccak256("cotton_fabric_slice_748_pink")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_748_pink")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_748_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice748 Purple",
        bytes32(keccak256("cotton_fabric_slice_748_purple")),
        bytes32(keccak256("cotton_fabric_slice_748_purple")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_748_purple"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_748_purple"))),
        bytes32(keccak256("cotton_fabric_slice_748_purple")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_748_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Slab172",
        bytes32(keccak256("led_slab_172")),
        bytes32(keccak256("led_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("led_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("led_slab_172"))),
        bytes32(keccak256("led_slab_172")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_448")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall448",
        bytes32(keccak256("cotton_fabric_wall_448")),
        bytes32(keccak256("cotton_fabric_wall_448")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_448"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_448"))),
        bytes32(keccak256("cotton_fabric_wall_448")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_448")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_peg_812")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Peg812",
        bytes32(keccak256("cotton_fabric_peg_812")),
        bytes32(keccak256("cotton_fabric_peg_812")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_peg_812"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_peg_812"))),
        bytes32(keccak256("cotton_fabric_peg_812")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_peg_812")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_stub_1259")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Stub1259",
        bytes32(keccak256("led_stub_1259")),
        bytes32(keccak256("led_stub_1259")),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1259"))),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1259"))),
        bytes32(keccak256("led_stub_1259")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_stub_1259")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_236_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step236 Red",
        bytes32(keccak256("cotton_fabric_step_236_red")),
        bytes32(keccak256("cotton_fabric_step_236_red")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_236_red"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_236_red"))),
        bytes32(keccak256("cotton_fabric_step_236_red")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_236_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_stub_1218")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Stub1218",
        bytes32(keccak256("led_stub_1218")),
        bytes32(keccak256("led_stub_1218")),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1218"))),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1218"))),
        bytes32(keccak256("led_stub_1218")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_stub_1218")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_peg_809")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Peg809",
        bytes32(keccak256("cotton_fabric_peg_809")),
        bytes32(keccak256("cotton_fabric_peg_809")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_peg_809"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_peg_809"))),
        bytes32(keccak256("cotton_fabric_peg_809")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_peg_809")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_window_617")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Window617",
        bytes32(keccak256("clay_polished_window_617")),
        bytes32(keccak256("clay_polished_window_617")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_window_617"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_window_617"))),
        bytes32(keccak256("clay_polished_window_617")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_window_617")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_wall_494")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Wall494",
        bytes32(keccak256("cotton_fabric_wall_494")),
        bytes32(keccak256("cotton_fabric_wall_494")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_494"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_wall_494"))),
        bytes32(keccak256("cotton_fabric_wall_494")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_wall_494")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_stub_1223")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Stub1223",
        bytes32(keccak256("led_stub_1223")),
        bytes32(keccak256("led_stub_1223")),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1223"))),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1223"))),
        bytes32(keccak256("led_stub_1223")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_stub_1223")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_peg_773")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Peg773",
        bytes32(keccak256("cotton_fabric_peg_773")),
        bytes32(keccak256("cotton_fabric_peg_773")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_peg_773"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_peg_773"))),
        bytes32(keccak256("cotton_fabric_peg_773")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_peg_773")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_slab_135")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Slab135",
        bytes32(keccak256("clay_polished_slab_135")),
        bytes32(keccak256("clay_polished_slab_135")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_135"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_135"))),
        bytes32(keccak256("clay_polished_slab_135")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_slab_135")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Slab130",
        bytes32(keccak256("clay_polished_slab_130")),
        bytes32(keccak256("clay_polished_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_130"))),
        bytes32(keccak256("clay_polished_slab_130")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_stool_1068")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Stool1068",
        bytes32(keccak256("cotton_fabric_stool_1068")),
        bytes32(keccak256("cotton_fabric_stool_1068")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stool_1068"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stool_1068"))),
        bytes32(keccak256("cotton_fabric_stool_1068")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_stool_1068")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1262")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Stub1262",
        bytes32(keccak256("cotton_fabric_stub_1262")),
        bytes32(keccak256("cotton_fabric_stub_1262")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1262"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1262"))),
        bytes32(keccak256("cotton_fabric_stub_1262")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1262")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1223")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Stub1223",
        bytes32(keccak256("cotton_fabric_stub_1223")),
        bytes32(keccak256("cotton_fabric_stub_1223")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1223"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1223"))),
        bytes32(keccak256("cotton_fabric_stub_1223")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1223")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_stool_1024")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Stool1024",
        bytes32(keccak256("cotton_fabric_stool_1024")),
        bytes32(keccak256("cotton_fabric_stool_1024")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stool_1024"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stool_1024"))),
        bytes32(keccak256("cotton_fabric_stool_1024")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_stool_1024")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_stool_1029")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Stool1029",
        bytes32(keccak256("cotton_fabric_stool_1029")),
        bytes32(keccak256("cotton_fabric_stool_1029")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stool_1029"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stool_1029"))),
        bytes32(keccak256("cotton_fabric_stool_1029")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_stool_1029")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_slab_174")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Slab174",
        bytes32(keccak256("clay_polished_slab_174")),
        bytes32(keccak256("clay_polished_slab_174")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_174"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_174"))),
        bytes32(keccak256("clay_polished_slab_174")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_slab_174")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished",
        bytes32(keccak256("clay_polished")),
        bytes32(keccak256("clay_polished")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished"))),
        bytes32(keccak256("clay_polished")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_corner_834")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Corner834",
        bytes32(keccak256("cotton_fabric_corner_834")),
        bytes32(keccak256("cotton_fabric_corner_834")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_corner_834"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_corner_834"))),
        bytes32(keccak256("cotton_fabric_corner_834")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_corner_834")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_corner_875")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Corner875",
        bytes32(keccak256("cotton_fabric_corner_875")),
        bytes32(keccak256("cotton_fabric_corner_875")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_corner_875"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_corner_875"))),
        bytes32(keccak256("cotton_fabric_corner_875")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_corner_875")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Step199",
        bytes32(keccak256("oak_stripped_step_199")),
        bytes32(keccak256("oak_stripped_step_199")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_step_199"))),
        bytes32(keccak256("oak_stripped_step_199")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_corner_878")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Corner878",
        bytes32(keccak256("cotton_fabric_corner_878")),
        bytes32(keccak256("cotton_fabric_corner_878")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_corner_878"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_corner_878"))),
        bytes32(keccak256("cotton_fabric_corner_878")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_corner_878")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_knob_942")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Knob942",
        bytes32(keccak256("cotton_fabric_knob_942")),
        bytes32(keccak256("cotton_fabric_knob_942")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_942"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_942"))),
        bytes32(keccak256("cotton_fabric_knob_942")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_knob_942")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_knob_903")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Knob903",
        bytes32(keccak256("cotton_fabric_knob_903")),
        bytes32(keccak256("cotton_fabric_knob_903")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_903"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_knob_903"))),
        bytes32(keccak256("cotton_fabric_knob_903")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_knob_903")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_corner_839")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Corner839",
        bytes32(keccak256("cotton_fabric_corner_839")),
        bytes32(keccak256("cotton_fabric_corner_839")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_corner_839"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_corner_839"))),
        bytes32(keccak256("cotton_fabric_corner_839")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_corner_839")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Slab169",
        bytes32(keccak256("clay_polished_slab_169")),
        bytes32(keccak256("clay_polished_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_169"))),
        bytes32(keccak256("clay_polished_slab_169")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Slab128",
        bytes32(keccak256("clay_polished_slab_128")),
        bytes32(keccak256("clay_polished_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_128"))),
        bytes32(keccak256("clay_polished_slab_128")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab133",
        bytes32(keccak256("cotton_fabric_slab_133")),
        bytes32(keccak256("cotton_fabric_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_133"))),
        bytes32(keccak256("cotton_fabric_slab_133")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_outset_1157")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Outset1157",
        bytes32(keccak256("granite_outset_1157")),
        bytes32(keccak256("granite_outset_1157")),
        getChildVoxelTypes(bytes32(keccak256("granite_outset_1157"))),
        getChildVoxelTypes(bytes32(keccak256("granite_outset_1157"))),
        bytes32(keccak256("granite_outset_1157")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_outset_1157")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_outset_1193")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Outset1193",
        bytes32(keccak256("granite_outset_1193")),
        bytes32(keccak256("granite_outset_1193")),
        getChildVoxelTypes(bytes32(keccak256("granite_outset_1193"))),
        getChildVoxelTypes(bytes32(keccak256("granite_outset_1193"))),
        bytes32(keccak256("granite_outset_1193")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_outset_1193")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_outset_1196")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Outset1196",
        bytes32(keccak256("granite_outset_1196")),
        bytes32(keccak256("granite_outset_1196")),
        getChildVoxelTypes(bytes32(keccak256("granite_outset_1196"))),
        getChildVoxelTypes(bytes32(keccak256("granite_outset_1196"))),
        bytes32(keccak256("granite_outset_1196")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_outset_1196")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_outset_1152")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Outset1152",
        bytes32(keccak256("granite_outset_1152")),
        bytes32(keccak256("granite_outset_1152")),
        getChildVoxelTypes(bytes32(keccak256("granite_outset_1152"))),
        getChildVoxelTypes(bytes32(keccak256("granite_outset_1152"))),
        bytes32(keccak256("granite_outset_1152")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_outset_1152")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Slab133",
        bytes32(keccak256("clay_polished_slab_133")),
        bytes32(keccak256("clay_polished_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_133"))),
        bytes32(keccak256("clay_polished_slab_133")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Slab172",
        bytes32(keccak256("clay_polished_slab_172")),
        bytes32(keccak256("clay_polished_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slab_172"))),
        bytes32(keccak256("clay_polished_slab_172")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_stripped_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Stripped Slab172",
        bytes32(keccak256("oak_stripped_slab_172")),
        bytes32(keccak256("oak_stripped_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("oak_stripped_slab_172"))),
        bytes32(keccak256("oak_stripped_slab_172")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_stripped_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Step233",
        bytes32(keccak256("clay_polished_step_233")),
        bytes32(keccak256("clay_polished_step_233")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_step_233"))),
        bytes32(keccak256("clay_polished_step_233")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Step197",
        bytes32(keccak256("clay_polished_step_197")),
        bytes32(keccak256("clay_polished_step_197")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_step_197"))),
        bytes32(keccak256("clay_polished_step_197")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Step236",
        bytes32(keccak256("clay_polished_step_236")),
        bytes32(keccak256("clay_polished_step_236")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_step_236"))),
        bytes32(keccak256("clay_polished_step_236")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("gold")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Gold",
        bytes32(keccak256("gold")),
        bytes32(keccak256("gold")),
        getChildVoxelTypes(bytes32(keccak256("gold"))),
        getChildVoxelTypes(bytes32(keccak256("gold"))),
        bytes32(keccak256("gold")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("gold")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_polished")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Polished",
        bytes32(keccak256("basalt_polished")),
        bytes32(keccak256("basalt_polished")),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_polished"))),
        bytes32(keccak256("basalt_polished")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_polished")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_log")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Log",
        bytes32(keccak256("oak_log")),
        bytes32(keccak256("oak_log")),
        getChildVoxelTypes(bytes32(keccak256("oak_log"))),
        getChildVoxelTypes(bytes32(keccak256("oak_log"))),
        bytes32(keccak256("oak_log")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_log")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_stub_1216_tan")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Stub1216 Tan",
        bytes32(keccak256("led_stub_1216_tan")),
        bytes32(keccak256("led_stub_1216_tan")),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1216_tan"))),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1216_tan"))),
        bytes32(keccak256("led_stub_1216_tan")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_stub_1216_tan")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_lumber_outset_1193")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Lumber Outset1193",
        bytes32(keccak256("rubber_lumber_outset_1193")),
        bytes32(keccak256("rubber_lumber_outset_1193")),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_outset_1193"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_lumber_outset_1193"))),
        bytes32(keccak256("rubber_lumber_outset_1193")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_lumber_outset_1193")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slice_706")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slice706",
        bytes32(keccak256("oak_lumber_slice_706")),
        bytes32(keccak256("oak_lumber_slice_706")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_706"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slice_706"))),
        bytes32(keccak256("oak_lumber_slice_706")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slice_706")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_outset_1157_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Outset1157 Orange",
        bytes32(keccak256("oak_lumber_outset_1157_orange")),
        bytes32(keccak256("oak_lumber_outset_1157_orange")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1157_orange"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1157_orange"))),
        bytes32(keccak256("oak_lumber_outset_1157_orange")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_outset_1157_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Orange",
        bytes32(keccak256("oak_lumber_orange")),
        bytes32(keccak256("oak_lumber_orange")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_orange"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_orange"))),
        bytes32(keccak256("oak_lumber_orange")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_polished_outset_1157")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Polished Outset1157",
        bytes32(keccak256("granite_polished_outset_1157")),
        bytes32(keccak256("granite_polished_outset_1157")),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_outset_1157"))),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_outset_1157"))),
        bytes32(keccak256("granite_polished_outset_1157")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_polished_outset_1157")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Wall489",
        bytes32(keccak256("birch_stripped_wall_489")),
        bytes32(keccak256("birch_stripped_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_wall_489"))),
        bytes32(keccak256("birch_stripped_wall_489")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("thatch_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Thatch Step236",
        bytes32(keccak256("thatch_step_236")),
        bytes32(keccak256("thatch_step_236")),
        getChildVoxelTypes(bytes32(keccak256("thatch_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("thatch_step_236"))),
        bytes32(keccak256("thatch_step_236")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("thatch_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Wall492",
        bytes32(keccak256("birch_stripped_wall_492")),
        bytes32(keccak256("birch_stripped_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_wall_492"))),
        bytes32(keccak256("birch_stripped_wall_492")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_wall_492")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_log_256")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Log256",
        bytes32(keccak256("clay_log_256")),
        bytes32(keccak256("clay_log_256")),
        getChildVoxelTypes(bytes32(keccak256("clay_log_256"))),
        getChildVoxelTypes(bytes32(keccak256("clay_log_256"))),
        bytes32(keccak256("clay_log_256")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_log_256")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_polished_outset_1193")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Polished Outset1193",
        bytes32(keccak256("granite_polished_outset_1193")),
        bytes32(keccak256("granite_polished_outset_1193")),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_outset_1193"))),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_outset_1193"))),
        bytes32(keccak256("granite_polished_outset_1193")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_polished_outset_1193")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("thatch_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Thatch Slab133",
        bytes32(keccak256("thatch_slab_133")),
        bytes32(keccak256("thatch_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("thatch_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("thatch_slab_133"))),
        bytes32(keccak256("thatch_slab_133")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("thatch_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("thatch_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Thatch Slab172",
        bytes32(keccak256("thatch_slab_172")),
        bytes32(keccak256("thatch_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("thatch_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("thatch_slab_172"))),
        bytes32(keccak256("thatch_slab_172")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("thatch_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_stool_1031")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Stool1031",
        bytes32(keccak256("birch_stripped_stool_1031")),
        bytes32(keccak256("birch_stripped_stool_1031")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_stool_1031"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_stool_1031"))),
        bytes32(keccak256("birch_stripped_stool_1031")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_stool_1031")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_outset_1157")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Outset1157",
        bytes32(keccak256("oak_lumber_outset_1157")),
        bytes32(keccak256("oak_lumber_outset_1157")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1157"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1157"))),
        bytes32(keccak256("oak_lumber_outset_1157")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_outset_1157")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_wall_453")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Wall453",
        bytes32(keccak256("birch_stripped_wall_453")),
        bytes32(keccak256("birch_stripped_wall_453")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_wall_453"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_wall_453"))),
        bytes32(keccak256("birch_stripped_wall_453")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_wall_453")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_slice_704")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Slice704",
        bytes32(keccak256("birch_lumber_slice_704")),
        bytes32(keccak256("birch_lumber_slice_704")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slice_704"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_slice_704"))),
        bytes32(keccak256("birch_lumber_slice_704")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_slice_704")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_polished_outset_1152")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Polished Outset1152",
        bytes32(keccak256("granite_polished_outset_1152")),
        bytes32(keccak256("granite_polished_outset_1152")),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_outset_1152"))),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_outset_1152"))),
        bytes32(keccak256("granite_polished_outset_1152")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_polished_outset_1152")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_path_512")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Path512",
        bytes32(keccak256("moss_path_512")),
        bytes32(keccak256("moss_path_512")),
        getChildVoxelTypes(bytes32(keccak256("moss_path_512"))),
        getChildVoxelTypes(bytes32(keccak256("moss_path_512"))),
        bytes32(keccak256("moss_path_512")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_path_512")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("thatch_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Thatch Step197",
        bytes32(keccak256("thatch_step_197")),
        bytes32(keccak256("thatch_step_197")),
        getChildVoxelTypes(bytes32(keccak256("thatch_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("thatch_step_197"))),
        bytes32(keccak256("thatch_step_197")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("thatch_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_outset_1193")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Outset1193",
        bytes32(keccak256("birch_stripped_outset_1193")),
        bytes32(keccak256("birch_stripped_outset_1193")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_outset_1193"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_outset_1193"))),
        bytes32(keccak256("birch_stripped_outset_1193")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_outset_1193")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Step199",
        bytes32(keccak256("birch_stripped_step_199")),
        bytes32(keccak256("birch_stripped_step_199")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_step_199"))),
        bytes32(keccak256("birch_stripped_step_199")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_slab_171")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Slab171",
        bytes32(keccak256("birch_stripped_slab_171")),
        bytes32(keccak256("birch_stripped_slab_171")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_slab_171"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_slab_171"))),
        bytes32(keccak256("birch_stripped_slab_171")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_slab_171")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_step_194")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Step194",
        bytes32(keccak256("birch_stripped_step_194")),
        bytes32(keccak256("birch_stripped_step_194")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_step_194"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_step_194"))),
        bytes32(keccak256("birch_stripped_step_194")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_step_194")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_outset_1196")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Outset1196",
        bytes32(keccak256("birch_stripped_outset_1196")),
        bytes32(keccak256("birch_stripped_outset_1196")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_outset_1196"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_outset_1196"))),
        bytes32(keccak256("birch_stripped_outset_1196")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_outset_1196")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_453_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall453 Orange",
        bytes32(keccak256("oak_lumber_wall_453_orange")),
        bytes32(keccak256("oak_lumber_wall_453_orange")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_453_orange"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_453_orange"))),
        bytes32(keccak256("oak_lumber_wall_453_orange")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_453_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("wood_crate_table_428")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Wood Crate Table428",
        bytes32(keccak256("wood_crate_table_428")),
        bytes32(keccak256("wood_crate_table_428")),
        getChildVoxelTypes(bytes32(keccak256("wood_crate_table_428"))),
        getChildVoxelTypes(bytes32(keccak256("wood_crate_table_428"))),
        bytes32(keccak256("wood_crate_table_428")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("wood_crate_table_428")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_step_238")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Step238",
        bytes32(keccak256("birch_stripped_step_238")),
        bytes32(keccak256("birch_stripped_step_238")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_step_238"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_step_238"))),
        bytes32(keccak256("birch_stripped_step_238")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_step_238")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_outset_1152")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Outset1152",
        bytes32(keccak256("oak_lumber_outset_1152")),
        bytes32(keccak256("oak_lumber_outset_1152")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1152"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_outset_1152"))),
        bytes32(keccak256("oak_lumber_outset_1152")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_outset_1152")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Step236",
        bytes32(keccak256("rubber_stripped_step_236")),
        bytes32(keccak256("rubber_stripped_step_236")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_step_236"))),
        bytes32(keccak256("rubber_stripped_step_236")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_table_428")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Table428",
        bytes32(keccak256("birch_stripped_table_428")),
        bytes32(keccak256("birch_stripped_table_428")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_table_428"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_table_428"))),
        bytes32(keccak256("birch_stripped_table_428")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_table_428")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_448_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall448 Orange",
        bytes32(keccak256("oak_lumber_wall_448_orange")),
        bytes32(keccak256("oak_lumber_wall_448_orange")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_448_orange"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_448_orange"))),
        bytes32(keccak256("oak_lumber_wall_448_orange")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_448_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_stripped_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Stripped Step233",
        bytes32(keccak256("rubber_stripped_step_233")),
        bytes32(keccak256("rubber_stripped_step_233")),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_stripped_step_233"))),
        bytes32(keccak256("rubber_stripped_step_233")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_stripped_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_window_617_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Window617 Black",
        bytes32(keccak256("oak_lumber_window_617_black")),
        bytes32(keccak256("oak_lumber_window_617_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_window_617_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_window_617_black"))),
        bytes32(keccak256("oak_lumber_window_617_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_window_617_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_frame_645_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Frame645 Black",
        bytes32(keccak256("oak_lumber_frame_645_black")),
        bytes32(keccak256("oak_lumber_frame_645_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_645_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_645_black"))),
        bytes32(keccak256("oak_lumber_frame_645_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_frame_645_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_frame_640_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Frame640 Black",
        bytes32(keccak256("oak_lumber_frame_640_black")),
        bytes32(keccak256("oak_lumber_frame_640_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_640_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_frame_640_black"))),
        bytes32(keccak256("oak_lumber_frame_640_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_frame_640_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_polished_outset_1196")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Polished Outset1196",
        bytes32(keccak256("granite_polished_outset_1196")),
        bytes32(keccak256("granite_polished_outset_1196")),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_outset_1196"))),
        getChildVoxelTypes(bytes32(keccak256("granite_polished_outset_1196"))),
        bytes32(keccak256("granite_polished_outset_1196")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_polished_outset_1196")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_stripped_peg_773")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Stripped Peg773",
        bytes32(keccak256("birch_stripped_peg_773")),
        bytes32(keccak256("birch_stripped_peg_773")),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_peg_773"))),
        getChildVoxelTypes(bytes32(keccak256("birch_stripped_peg_773"))),
        bytes32(keccak256("birch_stripped_peg_773")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_stripped_peg_773")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slice_745_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slice745 Purple",
        bytes32(keccak256("cotton_fabric_slice_745_purple")),
        bytes32(keccak256("cotton_fabric_slice_745_purple")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_745_purple"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slice_745_purple"))),
        bytes32(keccak256("cotton_fabric_slice_745_purple")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slice_745_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1257")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Stub1257",
        bytes32(keccak256("cotton_fabric_stub_1257")),
        bytes32(keccak256("cotton_fabric_stub_1257")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1257"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stub_1257"))),
        bytes32(keccak256("cotton_fabric_stub_1257")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_stub_1257")));

    vm.stopBroadcast();
  }
}
