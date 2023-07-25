// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "../../prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { REGISTER_VOXEL_TYPE_SIG, REGISTER_VOXEL_VARIANT_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_WORLD } from "../../Constants.sol";

bytes32 constant AirID = bytes32(keccak256("air"));

contract AirVoxelSystem is VoxelType {
  function registerVoxel() public override {
    VoxelVariantsRegistryData memory airVariant;
    airVariant.blockType = NoaBlockType.BLOCK;
    REGISTRY_WORLD.call(abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, AirID, airVariant));
    REGISTRY_WORLD.call(abi.encodeWithSignature(REGISTER_VOXEL_TYPE_SIG, "Air", AirID, AirID, _world()));
  }

  function enterWorld(bytes32 entity) public override {}

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public pure override returns (bytes32) {
    return AirID;
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
