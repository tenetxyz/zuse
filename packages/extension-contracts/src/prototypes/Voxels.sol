// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IWorld } from "../codegen/world/IWorld.sol";
import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";
import { stringArrToString } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { REGISTER_VOXEL_VARIANT_SIG, REGISTER_VOXEL_TYPE_SIG } from "@tenetxyz/contracts/src/constants.sol";

// TODO: should not be duplicated from "@tenetxyz/contracts
struct VoxelVariantsData {
  uint32 variantId;
  uint32 frames;
  bool opaque;
  bool fluid;
  bool solid;
  NoaBlockType blockType;
  string materialArr;
  string uvWrap;
}

bytes32 constant SandID = bytes32(keccak256("sand"));
bytes32 constant LogID = bytes32(keccak256("log"));
bytes32 constant OrangeFlowerID = bytes32(keccak256("orangeflower"));

string constant SandTexture = "bafkreia4afumfatsrlbmq5azbehfwzoqmgu7bjkiutb6njsuormtsqwwbi";
string constant LogTexture = "bafkreihllk5lrr2l2fgvmgzzyyxw5kostinfee2gi55kln2mzihfp2mumy";
string constant LogTopTexture = "bafkreiekx2odo544mawzn7np6p4uhkm2bt53nl4n2dhzj3ubbd5hi4jnf4";
string constant OrangeFlowerTexture = "bafkreicins36cmwliwf7ryrlcs32khvi6kleof6buiirlvgv2w6cejpg54";

string constant SandUVWrap = "bafkreiewghdyhnlq4yiqe4umxaytoy67jw3k65lwll2rbomfzr6oivhvpy";
string constant LogUVWrap = "bafkreiddsx5ke3e664ain2gnzd7jxicko34clxnlqzp2paqomvf7a7gb7m";

function defineVoxels(address world) {

    VoxelVariantsData memory sandVariant;
    sandVariant.blockType = NoaBlockType.BLOCK;
    sandVariant.opaque = true;
    sandVariant.solid = true;
    sandVariant.materialArr = SandTexture;
    sandVariant.uvWrap = SandUVWrap;
    (bool success, bytes memory result) = world.call(
        abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG,
                                SandID,
                                sandVariant));
    require(success, "Failed to register sand variant");

    (success, result) = world.call(
        abi.encodeWithSignature(REGISTER_VOXEL_TYPE_SIG,
        SandID,
        SandTexture,
        IWorld(world).tenet_ExtensionInitSys_sandVariantSelector.selector));
    require(success, "Failed to register sand type");

    string[] memory logMaterials = new string[](2);
    logMaterials[0] = LogTopTexture;
    logMaterials[1] = LogTexture;

    VoxelVariantsData memory logVariant;
    logVariant.blockType = NoaBlockType.BLOCK;
    logVariant.opaque = true;
    logVariant.solid = true;
    logVariant.materialArr = stringArrToString(logMaterials);
    logVariant.uvWrap = LogUVWrap;

    (success, result) = world.call(
        abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG,
                                LogID,
                                logVariant));
    require(success, "Failed to register log variant");

    (success, result) = world.call(
        abi.encodeWithSignature(REGISTER_VOXEL_TYPE_SIG,
        LogID,
        LogTexture,
        IWorld(world).tenet_ExtensionInitSys_logVariantSelector.selector));
    require(success, "Failed to register log type");

    VoxelVariantsData memory orangeFlowerVariant;
    orangeFlowerVariant.blockType = NoaBlockType.MESH;
    orangeFlowerVariant.opaque = false;
    orangeFlowerVariant.solid = false;
    orangeFlowerVariant.frames = 1;
    orangeFlowerVariant.materialArr = OrangeFlowerTexture;

    (success, result) = world.call(
        abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG,
                                OrangeFlowerID,
                                orangeFlowerVariant));
    require(success, "Failed to register orange flower variant");

    (success, result) = world.call(
        abi.encodeWithSignature(REGISTER_VOXEL_TYPE_SIG,
        OrangeFlowerID,
        OrangeFlowerTexture,
        IWorld(world).tenet_ExtensionInitSys_orangeFlowerVariantSelector.selector));
    require(success, "Failed to register orange flower type");
}
