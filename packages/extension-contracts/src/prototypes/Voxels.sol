// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IWorld } from "../codegen/world/IWorld.sol";
import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";
import { stringArrToString } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { REGISTER_VOXEL_VARIANT_SIG } from "@tenetxyz/contracts/src/constants.sol";

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
bytes32 constant SignalID = bytes32(keccak256("signal"));
bytes32 constant SignalOffID = bytes32(keccak256("signal.off"));
bytes32 constant SignalOnID = bytes32(keccak256("signal.on"));
bytes32 constant SignalSourceID = bytes32(keccak256("signalsource"));
bytes32 constant InvertedSignalID = bytes32(keccak256("invertedsignal"));

string constant SandTexture = "bafkreia4afumfatsrlbmq5azbehfwzoqmgu7bjkiutb6njsuormtsqwwbi";
string constant LogTexture = "bafkreihllk5lrr2l2fgvmgzzyyxw5kostinfee2gi55kln2mzihfp2mumy";
string constant LogTopTexture = "bafkreiekx2odo544mawzn7np6p4uhkm2bt53nl4n2dhzj3ubbd5hi4jnf4";
string constant OrangeFlowerTexture = "bafkreicins36cmwliwf7ryrlcs32khvi6kleof6buiirlvgv2w6cejpg54";
string constant SignalOffTexture = "bafkreidu6upeyhrpwjjdzjurgyy7emzsb6wkufulm7xff7ceeeivdaxnsu";
string constant SignalOnTexture = "bafkreic3d2hcqzzk2qj575zag2dr6jbqbkh6gkbvjleadjijqqdgaf2ekm";
string constant SignalSourceTexture = "bafkreifciafvv63x3nnnsdvsccp45ggcx5xczfhoaz3xy3y5k666ma2m4y";

string constant SandUVWrap = "bafkreiewghdyhnlq4yiqe4umxaytoy67jw3k65lwll2rbomfzr6oivhvpy";
string constant LogUVWrap = "bafkreiddsx5ke3e664ain2gnzd7jxicko34clxnlqzp2paqomvf7a7gb7m";
string constant SignalOffUVWrap = "bafkreid27etg4t7gm2ea3e6ivo43vlpear72karqtpmot6v4ct5xymhg5y";
string constant SignalOnUVWrap = "bafkreib5otfb7p2foonchtjm5mhrqpsqwfnzwbxvpxmm3m6xzakmxfqtcu";
string constant SignalSourceUVWrap = "bafkreibyxohq35sq2fqujxffs5nfjdtfx5cmnqhnyliar2xbkqxgcd7d5u";

function defineVoxels(address world) {
  VoxelVariantsData memory sandVariant;
  sandVariant.blockType = NoaBlockType.BLOCK;
  sandVariant.opaque = true;
  sandVariant.solid = true;
  sandVariant.materialArr = SandTexture;
  sandVariant.uvWrap = SandUVWrap;
  (bool success, bytes memory result) = world.call(
    abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, SandID, sandVariant)
  );
  require(success, "Failed to register sand variant");

  string[] memory logMaterials = new string[](2);
  logMaterials[0] = LogTopTexture;
  logMaterials[1] = LogTexture;

  VoxelVariantsData memory logVariant;
  logVariant.blockType = NoaBlockType.BLOCK;
  logVariant.opaque = true;
  logVariant.solid = true;
  logVariant.materialArr = stringArrToString(logMaterials);
  logVariant.uvWrap = LogUVWrap;

  (success, result) = world.call(abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, LogID, logVariant));
  require(success, "Failed to register log variant");

  VoxelVariantsData memory orangeFlowerVariant;
  orangeFlowerVariant.blockType = NoaBlockType.MESH;
  orangeFlowerVariant.opaque = false;
  orangeFlowerVariant.solid = false;
  orangeFlowerVariant.frames = 1;
  orangeFlowerVariant.materialArr = OrangeFlowerTexture;

  (success, result) = world.call(
    abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, OrangeFlowerID, orangeFlowerVariant)
  );
  require(success, "Failed to register orange flower variant");

  VoxelVariantsData memory signalOffVariant;
  signalOffVariant.blockType = NoaBlockType.BLOCK;
  signalOffVariant.opaque = true;
  signalOffVariant.solid = true;
  signalOffVariant.materialArr = SignalOffTexture;
  signalOffVariant.uvWrap = SignalOffUVWrap;
  (success, result) = world.call(abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, SignalOffID, signalOffVariant));
  require(success, "Failed to register signal off variant");

  VoxelVariantsData memory signalOnVariant;
  signalOnVariant.blockType = NoaBlockType.BLOCK;
  signalOnVariant.opaque = true;
  signalOnVariant.solid = true;
  signalOnVariant.materialArr = SignalOnTexture;
  signalOnVariant.uvWrap = SignalOnUVWrap;
  (success, result) = world.call(abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, SignalOnID, signalOnVariant));
  require(success, "Failed to register signal on variant");

  VoxelVariantsData memory signalSourceVariant;
  signalSourceVariant.blockType = NoaBlockType.BLOCK;
  signalSourceVariant.opaque = true;
  signalSourceVariant.solid = true;
  signalSourceVariant.materialArr = SignalSourceTexture;
  signalSourceVariant.uvWrap = SignalSourceUVWrap;
  (success, result) = world.call(
    abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, SignalSourceID, signalSourceVariant)
  );
  require(success, "Failed to register signal source variant");
}
