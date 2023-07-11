// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "../../prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Occurrence, VoxelTypeData, VoxelVariantsData } from "@tenet-contracts/src/codegen/Tables.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { TENET_NAMESPACE } from "../../Constants.sol";

bytes32 constant AirID = bytes32(keccak256("air"));

contract AirVoxelSystem is VoxelType {
  function registerVoxel() public override {
    IWorld world = IWorld(_world());

    VoxelVariantsData memory airVariant;
    airVariant.blockType = NoaBlockType.BLOCK;
    world.tenet_VoxelRegistrySys_registerVoxelVariant(AirID, airVariant);

    world.tenet_VoxelRegistrySys_registerVoxelType(
      "Air",
      AirID,
      TENET_NAMESPACE,
      AirID,
      world.tenet_AirVoxelSystem_variantSelector.selector,
      world.tenet_AirVoxelSystem_enterWorld.selector,
      world.tenet_AirVoxelSystem_exitWorld.selector,
      world.tenet_AirVoxelSystem_activate.selector
    );
  }

  function enterWorld(bytes32 entity) public override {}

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public pure override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: AirID });
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
