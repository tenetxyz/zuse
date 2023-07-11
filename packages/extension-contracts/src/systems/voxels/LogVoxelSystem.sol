// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenet-contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { registerVoxelVariant, registerVoxelType } from "../../Utils.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { VoxelVariantsData } from "@tenet-contracts/src/codegen/tables/VoxelVariants.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";

bytes32 constant LogID = bytes32(keccak256("log"));

string constant LogTexture = "bafkreihllk5lrr2l2fgvmgzzyyxw5kostinfee2gi55kln2mzihfp2mumy";
string constant LogTopTexture = "bafkreiekx2odo544mawzn7np6p4uhkm2bt53nl4n2dhzj3ubbd5hi4jnf4";

string constant LogUVWrap = "bafkreiddsx5ke3e664ain2gnzd7jxicko34clxnlqzp2paqomvf7a7gb7m";

contract LogVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory logVariant;
    logVariant.blockType = NoaBlockType.BLOCK;
    logVariant.opaque = true;
    logVariant.solid = true;
    string[] memory logMaterials = new string[](2);
    logMaterials[0] = LogTopTexture;
    logMaterials[1] = LogTexture;
    logVariant.materials = abi.encode(logMaterials);
    logVariant.uvWrap = LogUVWrap;
    registerVoxelVariant(world, LogID, logVariant);

    registerVoxelType(
      world,
      "Log",
      LogID,
      EXTENSION_NAMESPACE,
      LogID,
      IWorld(world).extension_LogVoxelSystem_variantSelector.selector,
      IWorld(world).extension_LogVoxelSystem_enterWorld.selector,
      IWorld(world).extension_LogVoxelSystem_exitWorld.selector,
      IWorld(world).extension_LogVoxelSystem_activate.selector
    );
  }

  function enterWorld(bytes32 entity) public override {}

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public pure override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: LogID });
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
