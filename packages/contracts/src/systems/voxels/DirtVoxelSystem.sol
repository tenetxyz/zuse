// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "../../prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Occurrence } from "@tenet-contracts/src/codegen/Tables.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { REGISTER_VOXEL_TYPE_SIG, REGISTER_VOXEL_VARIANT_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_WORLD } from "../../Constants.sol";

bytes32 constant DirtID = bytes32(keccak256("dirt"));

string constant DirtTexture = "bafkreibzraiuk6hgngtfczn57sivuqf3nv77twi6g3ftas2umjnbf6jefe";

string constant DirtUVWrap = "bafkreifbshwckn4pgw5ew2obz3i74eujzpcomatus5gu2tk7mms373gqme";

contract DirtVoxelSystem is VoxelType {
  function registerVoxel() public override {
    IWorld world = IWorld(_world());

    VoxelVariantsRegistryData memory dirtVariant;
    dirtVariant.blockType = NoaBlockType.BLOCK;
    dirtVariant.opaque = true;
    dirtVariant.solid = true;
    string[] memory dirtMaterials = new string[](1);
    dirtMaterials[0] = DirtTexture;
    dirtVariant.materials = abi.encode(dirtMaterials);
    dirtVariant.uvWrap = DirtUVWrap;

    REGISTRY_WORLD.call(abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, DirtID, dirtVariant));
    REGISTRY_WORLD.call(abi.encodeWithSignature(REGISTER_VOXEL_TYPE_SIG, "Dirt", DirtID, DirtID, _world()));

    Occurrence.set(DirtID, world.tenet_OccurrenceSystem_ODirt.selector);
  }

  function enterWorld(bytes32 entity) public override {}

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public pure override returns (bytes32) {
    return DirtID;
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
