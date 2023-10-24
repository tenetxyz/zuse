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

contract PostDeploy400 is Script {
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
        registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Step199",
        bytes32(keccak256("basalt_shingles_step_199")),
        bytes32(keccak256("basalt_shingles_step_199")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_199"))),
        bytes32(keccak256("basalt_shingles_step_199")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_log_peg_773")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Log Peg773",
        bytes32(keccak256("birch_log_peg_773")),
        bytes32(keccak256("birch_log_peg_773")),
        getChildVoxelTypes(bytes32(keccak256("birch_log_peg_773"))),
        getChildVoxelTypes(bytes32(keccak256("birch_log_peg_773"))),
        bytes32(keccak256("birch_log_peg_773")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_log_peg_773")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slab_174")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slab174",
        bytes32(keccak256("basalt_shingles_slab_174")),
        bytes32(keccak256("basalt_shingles_slab_174")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_174"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_174"))),
        bytes32(keccak256("basalt_shingles_slab_174")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slab_174")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_169_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab169 White",
        bytes32(keccak256("oak_lumber_slab_169_white")),
        bytes32(keccak256("oak_lumber_slab_169_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_169_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_169_white"))),
        bytes32(keccak256("oak_lumber_slab_169_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_169_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Step197",
        bytes32(keccak256("basalt_shingles_step_197")),
        bytes32(keccak256("basalt_shingles_step_197")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_197"))),
        bytes32(keccak256("basalt_shingles_step_197")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slab_172")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slab172",
        bytes32(keccak256("basalt_shingles_slab_172")),
        bytes32(keccak256("basalt_shingles_slab_172")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_172"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_172"))),
        bytes32(keccak256("basalt_shingles_slab_172")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slab_172")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slab133",
        bytes32(keccak256("basalt_shingles_slab_133")),
        bytes32(keccak256("basalt_shingles_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_133"))),
        bytes32(keccak256("basalt_shingles_slab_133")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slice_711")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slice711",
        bytes32(keccak256("basalt_shingles_slice_711")),
        bytes32(keccak256("basalt_shingles_slice_711")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slice_711"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slice_711"))),
        bytes32(keccak256("basalt_shingles_slice_711")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slice_711")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slice_706")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slice706",
        bytes32(keccak256("basalt_shingles_slice_706")),
        bytes32(keccak256("basalt_shingles_slice_706")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slice_706"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slice_706"))),
        bytes32(keccak256("basalt_shingles_slice_706")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slice_706")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_step_192")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Step192",
        bytes32(keccak256("basalt_shingles_step_192")),
        bytes32(keccak256("basalt_shingles_step_192")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_192"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_192"))),
        bytes32(keccak256("basalt_shingles_step_192")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_step_192")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_log_peg_809")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Log Peg809",
        bytes32(keccak256("birch_log_peg_809")),
        bytes32(keccak256("birch_log_peg_809")),
        getChildVoxelTypes(bytes32(keccak256("birch_log_peg_809"))),
        getChildVoxelTypes(bytes32(keccak256("birch_log_peg_809"))),
        bytes32(keccak256("birch_log_peg_809")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_log_peg_809")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slab169",
        bytes32(keccak256("basalt_shingles_slab_169")),
        bytes32(keccak256("basalt_shingles_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_169"))),
        bytes32(keccak256("basalt_shingles_slab_169")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_shingles_fence_364")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Shingles Fence364",
        bytes32(keccak256("granite_shingles_fence_364")),
        bytes32(keccak256("granite_shingles_fence_364")),
        getChildVoxelTypes(bytes32(keccak256("granite_shingles_fence_364"))),
        getChildVoxelTypes(bytes32(keccak256("granite_shingles_fence_364"))),
        bytes32(keccak256("granite_shingles_fence_364")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_shingles_fence_364")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slab128",
        bytes32(keccak256("basalt_shingles_slab_128")),
        bytes32(keccak256("basalt_shingles_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_128"))),
        bytes32(keccak256("basalt_shingles_slab_128")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_slab_128_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Slab128 Purple",
        bytes32(keccak256("cotton_fabric_slab_128_purple")),
        bytes32(keccak256("cotton_fabric_slab_128_purple")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_128_purple"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_slab_128_purple"))),
        bytes32(keccak256("cotton_fabric_slab_128_purple")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_slab_128_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_window_576")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Window576",
        bytes32(keccak256("cotton_fabric_window_576")),
        bytes32(keccak256("cotton_fabric_window_576")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_window_576"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_window_576"))),
        bytes32(keccak256("cotton_fabric_window_576")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_window_576")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_log_stool_1029")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Log Stool1029",
        bytes32(keccak256("birch_log_stool_1029")),
        bytes32(keccak256("birch_log_stool_1029")),
        getChildVoxelTypes(bytes32(keccak256("birch_log_stool_1029"))),
        getChildVoxelTypes(bytes32(keccak256("birch_log_stool_1029"))),
        bytes32(keccak256("birch_log_stool_1029")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_log_stool_1029")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_stool_1065")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Stool1065",
        bytes32(keccak256("cotton_fabric_stool_1065")),
        bytes32(keccak256("cotton_fabric_stool_1065")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stool_1065"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_stool_1065"))),
        bytes32(keccak256("cotton_fabric_stool_1065")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_stool_1065")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_step_238")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Step238",
        bytes32(keccak256("basalt_shingles_step_238")),
        bytes32(keccak256("basalt_shingles_step_238")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_238"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_238"))),
        bytes32(keccak256("basalt_shingles_step_238")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_step_238")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_shingles_fence_320")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Shingles Fence320",
        bytes32(keccak256("granite_shingles_fence_320")),
        bytes32(keccak256("granite_shingles_fence_320")),
        getChildVoxelTypes(bytes32(keccak256("granite_shingles_fence_320"))),
        getChildVoxelTypes(bytes32(keccak256("granite_shingles_fence_320"))),
        bytes32(keccak256("granite_shingles_fence_320")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_shingles_fence_320")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_step_235")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Step235",
        bytes32(keccak256("basalt_shingles_step_235")),
        bytes32(keccak256("basalt_shingles_step_235")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_235"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_235"))),
        bytes32(keccak256("basalt_shingles_step_235")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_step_235")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Step236",
        bytes32(keccak256("basalt_shingles_step_236")),
        bytes32(keccak256("basalt_shingles_step_236")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_236"))),
        bytes32(keccak256("basalt_shingles_step_236")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_step_233")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Step233",
        bytes32(keccak256("basalt_shingles_step_233")),
        bytes32(keccak256("basalt_shingles_step_233")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_233"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_233"))),
        bytes32(keccak256("basalt_shingles_step_233")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_step_233")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slab130",
        bytes32(keccak256("basalt_shingles_slab_130")),
        bytes32(keccak256("basalt_shingles_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_130"))),
        bytes32(keccak256("basalt_shingles_slab_130")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slab_135")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slab135",
        bytes32(keccak256("basalt_shingles_slab_135")),
        bytes32(keccak256("basalt_shingles_slab_135")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_135"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_135"))),
        bytes32(keccak256("basalt_shingles_slab_135")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slab_135")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_frame_640")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Frame640",
        bytes32(keccak256("clay_polished_frame_640")),
        bytes32(keccak256("clay_polished_frame_640")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_frame_640"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_frame_640"))),
        bytes32(keccak256("clay_polished_frame_640")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_frame_640")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_full_65")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Full65",
        bytes32(keccak256("cobblestone_brick_full_65")),
        bytes32(keccak256("cobblestone_brick_full_65")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_full_65"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_full_65"))),
        bytes32(keccak256("cobblestone_brick_full_65")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_full_65")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_321_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence321 White",
        bytes32(keccak256("oak_lumber_fence_321_white")),
        bytes32(keccak256("oak_lumber_fence_321_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_321_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_321_white"))),
        bytes32(keccak256("oak_lumber_fence_321_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_321_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_809_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg809 White",
        bytes32(keccak256("oak_lumber_peg_809_white")),
        bytes32(keccak256("oak_lumber_peg_809_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_809_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_809_white"))),
        bytes32(keccak256("oak_lumber_peg_809_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_809_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_wall_493")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Wall493",
        bytes32(keccak256("cobblestone_brick_wall_493")),
        bytes32(keccak256("cobblestone_brick_wall_493")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_wall_493"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_wall_493"))),
        bytes32(keccak256("cobblestone_brick_wall_493")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_wall_493")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_fence_365_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Fence365 White",
        bytes32(keccak256("oak_lumber_fence_365_white")),
        bytes32(keccak256("oak_lumber_fence_365_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_365_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_fence_365_white"))),
        bytes32(keccak256("oak_lumber_fence_365_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_fence_365_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_wall_488")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Wall488",
        bytes32(keccak256("cobblestone_wall_488")),
        bytes32(keccak256("cobblestone_wall_488")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_wall_488"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_wall_488"))),
        bytes32(keccak256("cobblestone_wall_488")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_wall_488")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_769_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg769 White",
        bytes32(keccak256("oak_lumber_peg_769_white")),
        bytes32(keccak256("oak_lumber_peg_769_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_769_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_769_white"))),
        bytes32(keccak256("oak_lumber_peg_769_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_769_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_stub_1219")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Stub1219",
        bytes32(keccak256("clay_polished_stub_1219")),
        bytes32(keccak256("clay_polished_stub_1219")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stub_1219"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stub_1219"))),
        bytes32(keccak256("clay_polished_stub_1219")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_stub_1219")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_813_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg813 White",
        bytes32(keccak256("oak_lumber_peg_813_white")),
        bytes32(keccak256("oak_lumber_peg_813_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_813_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_813_white"))),
        bytes32(keccak256("oak_lumber_peg_813_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_813_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_239_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step239 Red",
        bytes32(keccak256("cotton_fabric_step_239_red")),
        bytes32(keccak256("cotton_fabric_step_239_red")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_239_red"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_239_red"))),
        bytes32(keccak256("cotton_fabric_step_239_red")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_239_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_234_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step234 Red",
        bytes32(keccak256("cotton_fabric_step_234_red")),
        bytes32(keccak256("cotton_fabric_step_234_red")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_234_red"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_234_red"))),
        bytes32(keccak256("cotton_fabric_step_234_red")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_234_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_133_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab133 Blue",
        bytes32(keccak256("oak_lumber_slab_133_blue")),
        bytes32(keccak256("oak_lumber_slab_133_blue")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_133_blue"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_133_blue"))),
        bytes32(keccak256("oak_lumber_slab_133_blue")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_133_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_195_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step195 Red",
        bytes32(keccak256("cotton_fabric_step_195_red")),
        bytes32(keccak256("cotton_fabric_step_195_red")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_195_red"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_195_red"))),
        bytes32(keccak256("cotton_fabric_step_195_red")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_195_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_198_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step198 Red",
        bytes32(keccak256("cotton_fabric_step_198_red")),
        bytes32(keccak256("cotton_fabric_step_198_red")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_198_red"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_198_red"))),
        bytes32(keccak256("cotton_fabric_step_198_red")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_198_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sunstone_log_257")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sunstone Log257",
        bytes32(keccak256("sunstone_log_257")),
        bytes32(keccak256("sunstone_log_257")),
        getChildVoxelTypes(bytes32(keccak256("sunstone_log_257"))),
        getChildVoxelTypes(bytes32(keccak256("sunstone_log_257"))),
        bytes32(keccak256("sunstone_log_257")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sunstone_log_257")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_full_65")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Full65",
        bytes32(keccak256("cobblestone_full_65")),
        bytes32(keccak256("cobblestone_full_65")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_full_65"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_full_65"))),
        bytes32(keccak256("cobblestone_full_65")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_full_65")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_stub_1222")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Stub1222",
        bytes32(keccak256("clay_polished_stub_1222")),
        bytes32(keccak256("clay_polished_stub_1222")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stub_1222"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stub_1222"))),
        bytes32(keccak256("clay_polished_stub_1222")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_stub_1222")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_stool_1031")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Stool1031",
        bytes32(keccak256("clay_polished_stool_1031")),
        bytes32(keccak256("clay_polished_stool_1031")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stool_1031"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stool_1031"))),
        bytes32(keccak256("clay_polished_stool_1031")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_stool_1031")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_wall_493")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Wall493",
        bytes32(keccak256("cobblestone_wall_493")),
        bytes32(keccak256("cobblestone_wall_493")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_wall_493"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_wall_493"))),
        bytes32(keccak256("cobblestone_wall_493")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_wall_493")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_wall_488")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Wall488",
        bytes32(keccak256("cobblestone_brick_wall_488")),
        bytes32(keccak256("cobblestone_brick_wall_488")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_wall_488"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_wall_488"))),
        bytes32(keccak256("cobblestone_brick_wall_488")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_wall_488")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_full_65")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Full65",
        bytes32(keccak256("basalt_shingles_full_65")),
        bytes32(keccak256("basalt_shingles_full_65")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_full_65"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_full_65"))),
        bytes32(keccak256("basalt_shingles_full_65")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_full_65")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_step_239")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Step239",
        bytes32(keccak256("basalt_shingles_step_239")),
        bytes32(keccak256("basalt_shingles_step_239")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_239"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_239"))),
        bytes32(keccak256("basalt_shingles_step_239")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_step_239")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slab_131")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slab131",
        bytes32(keccak256("basalt_shingles_slab_131")),
        bytes32(keccak256("basalt_shingles_slab_131")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_131"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_131"))),
        bytes32(keccak256("basalt_shingles_slab_131")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slab_131")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("sunstone_log_301")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Sunstone Log301",
        bytes32(keccak256("sunstone_log_301")),
        bytes32(keccak256("sunstone_log_301")),
        getChildVoxelTypes(bytes32(keccak256("sunstone_log_301"))),
        getChildVoxelTypes(bytes32(keccak256("sunstone_log_301"))),
        bytes32(keccak256("sunstone_log_301")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("sunstone_log_301")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slab_175")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slab175",
        bytes32(keccak256("basalt_shingles_slab_175")),
        bytes32(keccak256("basalt_shingles_slab_175")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_175"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_175"))),
        bytes32(keccak256("basalt_shingles_slab_175")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slab_175")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_step_234")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Step234",
        bytes32(keccak256("basalt_shingles_step_234")),
        bytes32(keccak256("basalt_shingles_step_234")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_234"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_234"))),
        bytes32(keccak256("basalt_shingles_step_234")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_step_234")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slab_129")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slab129",
        bytes32(keccak256("basalt_shingles_slab_129")),
        bytes32(keccak256("basalt_shingles_slab_129")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_129"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_129"))),
        bytes32(keccak256("basalt_shingles_slab_129")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slab_129")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slab_168")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slab168",
        bytes32(keccak256("basalt_shingles_slab_168")),
        bytes32(keccak256("basalt_shingles_slab_168")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_168"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_168"))),
        bytes32(keccak256("basalt_shingles_slab_168")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slab_168")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_step_232")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Step232",
        bytes32(keccak256("basalt_shingles_step_232")),
        bytes32(keccak256("basalt_shingles_step_232")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_232"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_232"))),
        bytes32(keccak256("basalt_shingles_step_232")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_step_232")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_fence_321")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Fence321",
        bytes32(keccak256("cobblestone_brick_fence_321")),
        bytes32(keccak256("cobblestone_brick_fence_321")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_fence_321"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_fence_321"))),
        bytes32(keccak256("cobblestone_brick_fence_321")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_fence_321")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_stool_1030")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Stool1030",
        bytes32(keccak256("clay_polished_stool_1030")),
        bytes32(keccak256("clay_polished_stool_1030")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stool_1030"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stool_1030"))),
        bytes32(keccak256("clay_polished_stool_1030")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_stool_1030")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_step_237")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Step237",
        bytes32(keccak256("basalt_shingles_step_237")),
        bytes32(keccak256("basalt_shingles_step_237")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_237"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_step_237"))),
        bytes32(keccak256("basalt_shingles_step_237")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_step_237")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_slab_173")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Slab173",
        bytes32(keccak256("basalt_shingles_slab_173")),
        bytes32(keccak256("basalt_shingles_slab_173")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_173"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_slab_173"))),
        bytes32(keccak256("basalt_shingles_slab_173")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_slab_173")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_shingles_fence_325")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Shingles Fence325",
        bytes32(keccak256("granite_shingles_fence_325")),
        bytes32(keccak256("granite_shingles_fence_325")),
        getChildVoxelTypes(bytes32(keccak256("granite_shingles_fence_325"))),
        getChildVoxelTypes(bytes32(keccak256("granite_shingles_fence_325"))),
        bytes32(keccak256("granite_shingles_fence_325")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_shingles_fence_325")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_stool_1028")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Stool1028",
        bytes32(keccak256("clay_polished_stool_1028")),
        bytes32(keccak256("clay_polished_stool_1028")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stool_1028"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_stool_1028"))),
        bytes32(keccak256("clay_polished_stool_1028")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_stool_1028")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_stool_1024_white")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Stool1024 White",
        bytes32(keccak256("oak_lumber_stool_1024_white")),
        bytes32(keccak256("oak_lumber_stool_1024_white")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_stool_1024_white"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_stool_1024_white"))),
        bytes32(keccak256("oak_lumber_stool_1024_white")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_stool_1024_white")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("granite_polished")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Granite Polished",
        bytes32(keccak256("granite_polished")),
        bytes32(keccak256("granite_polished")),
        getChildVoxelTypes(bytes32(keccak256("granite_polished"))),
        getChildVoxelTypes(bytes32(keccak256("granite_polished"))),
        bytes32(keccak256("granite_polished")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("granite_polished")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_stub_1260_blue")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Stub1260 Blue",
        bytes32(keccak256("led_stub_1260_blue")),
        bytes32(keccak256("led_stub_1260_blue")),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1260_blue"))),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1260_blue"))),
        bytes32(keccak256("led_stub_1260_blue")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_stub_1260_blue")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Wall492",
        bytes32(keccak256("silver_wall_492")),
        bytes32(keccak256("silver_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("silver_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("silver_wall_492"))),
        bytes32(keccak256("silver_wall_492")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_wall_492")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_slice_704")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Slice704",
        bytes32(keccak256("neptunium_slice_704")),
        bytes32(keccak256("neptunium_slice_704")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_slice_704"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_slice_704"))),
        bytes32(keccak256("neptunium_slice_704")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_slice_704")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_stool_1068")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Stool1068",
        bytes32(keccak256("neptunium_stool_1068")),
        bytes32(keccak256("neptunium_stool_1068")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_stool_1068"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_stool_1068"))),
        bytes32(keccak256("neptunium_stool_1068")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_stool_1068")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("rubber_reinforced_stool_1067")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Rubber Reinforced Stool1067",
        bytes32(keccak256("rubber_reinforced_stool_1067")),
        bytes32(keccak256("rubber_reinforced_stool_1067")),
        getChildVoxelTypes(bytes32(keccak256("rubber_reinforced_stool_1067"))),
        getChildVoxelTypes(bytes32(keccak256("rubber_reinforced_stool_1067"))),
        bytes32(keccak256("rubber_reinforced_stool_1067")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("rubber_reinforced_stool_1067")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("neptunium_slice_750")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Neptunium Slice750",
        bytes32(keccak256("neptunium_slice_750")),
        bytes32(keccak256("neptunium_slice_750")),
        getChildVoxelTypes(bytes32(keccak256("neptunium_slice_750"))),
        getChildVoxelTypes(bytes32(keccak256("neptunium_slice_750"))),
        bytes32(keccak256("neptunium_slice_750")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("neptunium_slice_750")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led",
        bytes32(keccak256("led")),
        bytes32(keccak256("led")),
        getChildVoxelTypes(bytes32(keccak256("led"))),
        getChildVoxelTypes(bytes32(keccak256("led"))),
        bytes32(keccak256("led")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_809_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg809 Orange",
        bytes32(keccak256("oak_lumber_peg_809_orange")),
        bytes32(keccak256("oak_lumber_peg_809_orange")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_809_orange"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_809_orange"))),
        bytes32(keccak256("oak_lumber_peg_809_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_809_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_stub_1260_green")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Stub1260 Green",
        bytes32(keccak256("led_stub_1260_green")),
        bytes32(keccak256("led_stub_1260_green")),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1260_green"))),
        getChildVoxelTypes(bytes32(keccak256("led_stub_1260_green"))),
        bytes32(keccak256("led_stub_1260_green")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_stub_1260_green")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_slice_750")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Slice750",
        bytes32(keccak256("led_slice_750")),
        bytes32(keccak256("led_slice_750")),
        getChildVoxelTypes(bytes32(keccak256("led_slice_750"))),
        getChildVoxelTypes(bytes32(keccak256("led_slice_750"))),
        bytes32(keccak256("led_slice_750")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_slice_750")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_453")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall453",
        bytes32(keccak256("oak_lumber_wall_453")),
        bytes32(keccak256("oak_lumber_wall_453")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_453"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_453"))),
        bytes32(keccak256("oak_lumber_wall_453")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_453")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_wall_448")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Wall448",
        bytes32(keccak256("oak_lumber_wall_448")),
        bytes32(keccak256("oak_lumber_wall_448")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_448"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_wall_448"))),
        bytes32(keccak256("oak_lumber_wall_448")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_wall_448")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("grass_slab_128")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Grass Slab128",
        bytes32(keccak256("grass_slab_128")),
        bytes32(keccak256("grass_slab_128")),
        getChildVoxelTypes(bytes32(keccak256("grass_slab_128"))),
        getChildVoxelTypes(bytes32(keccak256("grass_slab_128"))),
        bytes32(keccak256("grass_slab_128")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("grass_slab_128")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("grass_slab_169")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Grass Slab169",
        bytes32(keccak256("grass_slab_169")),
        bytes32(keccak256("grass_slab_169")),
        getChildVoxelTypes(bytes32(keccak256("grass_slab_169"))),
        getChildVoxelTypes(bytes32(keccak256("grass_slab_169"))),
        bytes32(keccak256("grass_slab_169")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("grass_slab_169")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("grass_slab_133")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Grass Slab133",
        bytes32(keccak256("grass_slab_133")),
        bytes32(keccak256("grass_slab_133")),
        getChildVoxelTypes(bytes32(keccak256("grass_slab_133"))),
        getChildVoxelTypes(bytes32(keccak256("grass_slab_133"))),
        bytes32(keccak256("grass_slab_133")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("grass_slab_133")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_slab_171_tan")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Slab171 Tan",
        bytes32(keccak256("led_slab_171_tan")),
        bytes32(keccak256("led_slab_171_tan")),
        getChildVoxelTypes(bytes32(keccak256("led_slab_171_tan"))),
        getChildVoxelTypes(bytes32(keccak256("led_slab_171_tan"))),
        bytes32(keccak256("led_slab_171_tan")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_slab_171_tan")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_stool_1065_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Stool1065 Orange",
        bytes32(keccak256("oak_lumber_stool_1065_orange")),
        bytes32(keccak256("oak_lumber_stool_1065_orange")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_stool_1065_orange"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_stool_1065_orange"))),
        bytes32(keccak256("oak_lumber_stool_1065_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_stool_1065_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_outset_1157")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Outset1157",
        bytes32(keccak256("silver_outset_1157")),
        bytes32(keccak256("silver_outset_1157")),
        getChildVoxelTypes(bytes32(keccak256("silver_outset_1157"))),
        getChildVoxelTypes(bytes32(keccak256("silver_outset_1157"))),
        bytes32(keccak256("silver_outset_1157")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_outset_1157")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_outset_1193")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Outset1193",
        bytes32(keccak256("silver_outset_1193")),
        bytes32(keccak256("silver_outset_1193")),
        getChildVoxelTypes(bytes32(keccak256("silver_outset_1193"))),
        getChildVoxelTypes(bytes32(keccak256("silver_outset_1193"))),
        bytes32(keccak256("silver_outset_1193")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_outset_1193")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("silver_outset_1152")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Silver Outset1152",
        bytes32(keccak256("silver_outset_1152")),
        bytes32(keccak256("silver_outset_1152")),
        getChildVoxelTypes(bytes32(keccak256("silver_outset_1152"))),
        getChildVoxelTypes(bytes32(keccak256("silver_outset_1152"))),
        bytes32(keccak256("silver_outset_1152")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("silver_outset_1152")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_track_1385_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Track1385 Orange",
        bytes32(keccak256("oak_lumber_track_1385_orange")),
        bytes32(keccak256("oak_lumber_track_1385_orange")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_track_1385_orange"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_track_1385_orange"))),
        bytes32(keccak256("oak_lumber_track_1385_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_track_1385_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("red_mushroom")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Red Mushroom",
        bytes32(keccak256("red_mushroom")),
        bytes32(keccak256("red_mushroom")),
        getChildVoxelTypes(bytes32(keccak256("red_mushroom"))),
        getChildVoxelTypes(bytes32(keccak256("red_mushroom"))),
        bytes32(keccak256("red_mushroom")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("red_mushroom")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("ivy_vine")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Ivy Vine",
        bytes32(keccak256("ivy_vine")),
        bytes32(keccak256("ivy_vine")),
        getChildVoxelTypes(bytes32(keccak256("ivy_vine"))),
        getChildVoxelTypes(bytes32(keccak256("ivy_vine"))),
        bytes32(keccak256("ivy_vine")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("ivy_vine")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("lilac_flower")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Lilac Flower",
        bytes32(keccak256("lilac_flower")),
        bytes32(keccak256("lilac_flower")),
        getChildVoxelTypes(bytes32(keccak256("lilac_flower"))),
        getChildVoxelTypes(bytes32(keccak256("lilac_flower"))),
        bytes32(keccak256("lilac_flower")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("lilac_flower")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("tangle_weed")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Tangle Weed",
        bytes32(keccak256("tangle_weed")),
        bytes32(keccak256("tangle_weed")),
        getChildVoxelTypes(bytes32(keccak256("tangle_weed"))),
        getChildVoxelTypes(bytes32(keccak256("tangle_weed"))),
        bytes32(keccak256("tangle_weed")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("tangle_weed")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("switch_grass")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Switch Grass",
        bytes32(keccak256("switch_grass")),
        bytes32(keccak256("switch_grass")),
        getChildVoxelTypes(bytes32(keccak256("switch_grass"))),
        getChildVoxelTypes(bytes32(keccak256("switch_grass"))),
        bytes32(keccak256("switch_grass")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("switch_grass")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1196")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1196",
        bytes32(keccak256("simple_glass_outset_1196")),
        bytes32(keccak256("simple_glass_outset_1196")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1196"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1196"))),
        bytes32(keccak256("simple_glass_outset_1196")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1196")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1157")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1157",
        bytes32(keccak256("simple_glass_outset_1157")),
        bytes32(keccak256("simple_glass_outset_1157")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1157"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1157"))),
        bytes32(keccak256("simple_glass_outset_1157")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1157")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1193")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1193",
        bytes32(keccak256("simple_glass_outset_1193")),
        bytes32(keccak256("simple_glass_outset_1193")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1193"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1193"))),
        bytes32(keccak256("simple_glass_outset_1193")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1193")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1152")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1152",
        bytes32(keccak256("simple_glass_outset_1152")),
        bytes32(keccak256("simple_glass_outset_1152")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1152"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1152"))),
        bytes32(keccak256("simple_glass_outset_1152")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1152")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step236",
        bytes32(keccak256("oak_lumber_step_236")),
        bytes32(keccak256("oak_lumber_step_236")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_236"))),
        bytes32(keccak256("oak_lumber_step_236")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("clay_polished_slice_704")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Clay Polished Slice704",
        bytes32(keccak256("clay_polished_slice_704")),
        bytes32(keccak256("clay_polished_slice_704")),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slice_704"))),
        getChildVoxelTypes(bytes32(keccak256("clay_polished_slice_704"))),
        bytes32(keccak256("clay_polished_slice_704")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("clay_polished_slice_704")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_199_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step199 Orange",
        bytes32(keccak256("oak_lumber_step_199_orange")),
        bytes32(keccak256("oak_lumber_step_199_orange")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_199_orange"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_199_orange"))),
        bytes32(keccak256("oak_lumber_step_199_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_199_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_step_194_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Step194 Orange",
        bytes32(keccak256("oak_lumber_step_194_orange")),
        bytes32(keccak256("oak_lumber_step_194_orange")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_194_orange"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_step_194_orange"))),
        bytes32(keccak256("oak_lumber_step_194_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_step_194_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_peg_812_orange")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Peg812 Orange",
        bytes32(keccak256("oak_lumber_peg_812_orange")),
        bytes32(keccak256("oak_lumber_peg_812_orange")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_812_orange"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_peg_812_orange"))),
        bytes32(keccak256("oak_lumber_peg_812_orange")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_peg_812_orange")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_slab_171_red")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Slab171 Red",
        bytes32(keccak256("oak_lumber_slab_171_red")),
        bytes32(keccak256("oak_lumber_slab_171_red")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_171_red"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_slab_171_red"))),
        bytes32(keccak256("oak_lumber_slab_171_red")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_slab_171_red")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cobblestone_brick_step_192")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cobblestone Brick Step192",
        bytes32(keccak256("cobblestone_brick_step_192")),
        bytes32(keccak256("cobblestone_brick_step_192")),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_step_192"))),
        getChildVoxelTypes(bytes32(keccak256("cobblestone_brick_step_192"))),
        bytes32(keccak256("cobblestone_brick_step_192")),
        VoxelSelectors({
          enterWorldSelector: bytes4(0),
          exitWorldSelector: bytes4(0),
          voxelVariantSelector: bytes4(0),
          activateSelector: bytes4(0),
          onNewNeighbourSelector: bytes4(0),
          interactionSelectors: new InteractionSelector[](0)
        }),
        abi.encode(new ComponentDef[](0)),
        2
      );
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cobblestone_brick_step_192")));

    vm.stopBroadcast();
  }
}
