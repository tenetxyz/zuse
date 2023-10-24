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

contract PostDeploy922 is Script {
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
        registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_step_238")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Step238",
        bytes32(keccak256("birch_lumber_step_238")),
        bytes32(keccak256("birch_lumber_step_238")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_238"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_238"))),
        bytes32(keccak256("birch_lumber_step_238")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_step_238")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_step_199")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Step199",
        bytes32(keccak256("birch_lumber_step_199")),
        bytes32(keccak256("birch_lumber_step_199")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_199"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_199"))),
        bytes32(keccak256("birch_lumber_step_199")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_step_199")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_step_192")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Step192",
        bytes32(keccak256("birch_lumber_step_192")),
        bytes32(keccak256("birch_lumber_step_192")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_192"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_192"))),
        bytes32(keccak256("birch_lumber_step_192")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_step_192")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_step_235")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Step235",
        bytes32(keccak256("birch_lumber_step_235")),
        bytes32(keccak256("birch_lumber_step_235")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_235"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_235"))),
        bytes32(keccak256("birch_lumber_step_235")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_step_235")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_step_236")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Step236",
        bytes32(keccak256("birch_lumber_step_236")),
        bytes32(keccak256("birch_lumber_step_236")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_236"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_236"))),
        bytes32(keccak256("birch_lumber_step_236")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_step_236")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("birch_lumber_step_197")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Birch Lumber Step197",
        bytes32(keccak256("birch_lumber_step_197")),
        bytes32(keccak256("birch_lumber_step_197")),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_197"))),
        getChildVoxelTypes(bytes32(keccak256("birch_lumber_step_197"))),
        bytes32(keccak256("birch_lumber_step_197")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("birch_lumber_step_197")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_stool_1029")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Stool1029",
        bytes32(keccak256("moss_stool_1029")),
        bytes32(keccak256("moss_stool_1029")),
        getChildVoxelTypes(bytes32(keccak256("moss_stool_1029"))),
        getChildVoxelTypes(bytes32(keccak256("moss_stool_1029"))),
        bytes32(keccak256("moss_stool_1029")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_stool_1029")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("cotton_fabric_step_199_purple")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Cotton Fabric Step199 Purple",
        bytes32(keccak256("cotton_fabric_step_199_purple")),
        bytes32(keccak256("cotton_fabric_step_199_purple")),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_199_purple"))),
        getChildVoxelTypes(bytes32(keccak256("cotton_fabric_step_199_purple"))),
        bytes32(keccak256("cotton_fabric_step_199_purple")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("cotton_fabric_step_199_purple")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_stool_1031_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Stool1031 Black",
        bytes32(keccak256("oak_lumber_stool_1031_black")),
        bytes32(keccak256("oak_lumber_stool_1031_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_stool_1031_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_stool_1031_black"))),
        bytes32(keccak256("oak_lumber_stool_1031_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_stool_1031_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("oak_lumber_stool_1029_black")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Oak Lumber Stool1029 Black",
        bytes32(keccak256("oak_lumber_stool_1029_black")),
        bytes32(keccak256("oak_lumber_stool_1029_black")),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_stool_1029_black"))),
        getChildVoxelTypes(bytes32(keccak256("oak_lumber_stool_1029_black"))),
        bytes32(keccak256("oak_lumber_stool_1029_black")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("oak_lumber_stool_1029_black")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("led_slice_709_brightyellow")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Led Slice709 Brightyellow",
        bytes32(keccak256("led_slice_709_brightyellow")),
        bytes32(keccak256("led_slice_709_brightyellow")),
        getChildVoxelTypes(bytes32(keccak256("led_slice_709_brightyellow"))),
        getChildVoxelTypes(bytes32(keccak256("led_slice_709_brightyellow"))),
        bytes32(keccak256("led_slice_709_brightyellow")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("led_slice_709_brightyellow")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("moss_slab_130")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Moss Slab130",
        bytes32(keccak256("moss_slab_130")),
        bytes32(keccak256("moss_slab_130")),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_130"))),
        getChildVoxelTypes(bytes32(keccak256("moss_slab_130"))),
        bytes32(keccak256("moss_slab_130")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("moss_slab_130")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_wall_489")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Wall489",
        bytes32(keccak256("basalt_shingles_wall_489")),
        bytes32(keccak256("basalt_shingles_wall_489")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_wall_489"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_wall_489"))),
        bytes32(keccak256("basalt_shingles_wall_489")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_wall_489")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_wall_492")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Wall492",
        bytes32(keccak256("basalt_shingles_wall_492")),
        bytes32(keccak256("basalt_shingles_wall_492")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_wall_492"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_wall_492"))),
        bytes32(keccak256("basalt_shingles_wall_492")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_wall_492")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_wall_453")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Wall453",
        bytes32(keccak256("basalt_shingles_wall_453")),
        bytes32(keccak256("basalt_shingles_wall_453")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_wall_453"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_wall_453"))),
        bytes32(keccak256("basalt_shingles_wall_453")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_wall_453")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_knob_901")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Knob901",
        bytes32(keccak256("basalt_shingles_knob_901")),
        bytes32(keccak256("basalt_shingles_knob_901")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_knob_901"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_knob_901"))),
        bytes32(keccak256("basalt_shingles_knob_901")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_knob_901")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_knob_940")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Knob940",
        bytes32(keccak256("basalt_shingles_knob_940")),
        bytes32(keccak256("basalt_shingles_knob_940")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_knob_940"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_knob_940"))),
        bytes32(keccak256("basalt_shingles_knob_940")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_knob_940")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_corner_876")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Corner876",
        bytes32(keccak256("basalt_shingles_corner_876")),
        bytes32(keccak256("basalt_shingles_corner_876")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_corner_876"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_corner_876"))),
        bytes32(keccak256("basalt_shingles_corner_876")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_corner_876")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_corner_832")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Corner832",
        bytes32(keccak256("basalt_shingles_corner_832")),
        bytes32(keccak256("basalt_shingles_corner_832")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_corner_832"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_corner_832"))),
        bytes32(keccak256("basalt_shingles_corner_832")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_corner_832")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_knob_896")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Knob896",
        bytes32(keccak256("basalt_shingles_knob_896")),
        bytes32(keccak256("basalt_shingles_knob_896")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_knob_896"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_knob_896"))),
        bytes32(keccak256("basalt_shingles_knob_896")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_knob_896")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("basalt_shingles_knob_937")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Basalt Shingles Knob937",
        bytes32(keccak256("basalt_shingles_knob_937")),
        bytes32(keccak256("basalt_shingles_knob_937")),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_knob_937"))),
        getChildVoxelTypes(bytes32(keccak256("basalt_shingles_knob_937"))),
        bytes32(keccak256("basalt_shingles_knob_937")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("basalt_shingles_knob_937")));
    registerVoxelVariant(REGISTRY_ADDRESS, bytes32(keccak256("simple_glass_outset_1154")), getEmptyVariantsRegistryData());

    registerVoxelType(
        REGISTRY_ADDRESS,
        "Simple Glass Outset1154",
        bytes32(keccak256("simple_glass_outset_1154")),
        bytes32(keccak256("simple_glass_outset_1154")),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1154"))),
        getChildVoxelTypes(bytes32(keccak256("simple_glass_outset_1154"))),
        bytes32(keccak256("simple_glass_outset_1154")),
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
    registerCAVoxelType(CA_ADDRESS, bytes32(keccak256("simple_glass_outset_1154")));

    vm.stopBroadcast();
  }
}
