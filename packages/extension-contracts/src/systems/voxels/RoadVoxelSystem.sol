// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenet-contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Occurrence, VoxelTypeData, VoxelVariantsData } from "@tenet-contracts/src/codegen/Tables.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { EXTENSION_NAMESPACE } from "@tenet-extension-contracts/src/constants.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-extension-contracts/src/Utils.sol";

bytes32 constant RoadID = bytes32(keccak256("road"));

string constant RoadTexture = "bafkreiaavptzcmkl6xdyqk6ivp75ehsx45yl6kgxnahumozfbur6z6xcni";

string constant RoadUVWrap = "bafkreihibx43dpw57halle4yfzidfrclm35xlyoiko3kq3m2uh5mewnmyu";

contract RoadVoxelSystem is VoxelType {
  function registerVoxel() public override {
    IWorld world = IWorld(_world());

    VoxelVariantsData memory RoadVariant;
    RoadVariant.blockType = NoaBlockType.BLOCK;
    RoadVariant.opaque = true;
    RoadVariant.solid = true;
    string[] memory RoadMaterials = new string[](1);
    RoadMaterials[0] = RoadTexture;
    RoadVariant.materials = abi.encode(RoadMaterials);
    RoadVariant.uvWrap = RoadUVWrap;
    registerVoxelVariant(_world(), RoadID, RoadVariant);

    registerVoxelType(
      _world(),
      "Road",
      RoadID,
      EXTENSION_NAMESPACE,
      RoadID,
      world.extension_RoadVoxelSystem_variantSelector.selector,
      world.extension_RoadVoxelSystem_enterWorld.selector,
      world.extension_RoadVoxelSystem_exitWorld.selector,
      world.extension_RoadVoxelSystem_activate.selector
    );
  }

  function enterWorld(bytes32 entity) public override {}

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public pure override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: RoadID });
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
