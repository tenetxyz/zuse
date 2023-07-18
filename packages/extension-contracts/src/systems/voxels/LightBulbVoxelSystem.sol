// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenet-contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { Consumer, ConsumerData } from "@tenet-extension-contracts/src/codegen/Tables.sol";
import { getCallerNamespace } from "@tenet-contracts/src/Utils.sol";
import { registerVoxelType, registerVoxelVariant, entityIsConsumer } from "../../Utils.sol";
import { VoxelVariantsKey, BlockHeightUpdate } from "@tenet-contracts/src/Types.sol";
import { VoxelVariantsData } from "@tenet-contracts/src/codegen/tables/VoxelVariants.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";

bytes32 constant LightBulbID = bytes32(keccak256("lightbulb"));

bytes32 constant LightBulbOffID = bytes32(keccak256("lightbulb.off"));
bytes32 constant LightBulbOnID = bytes32(keccak256("lightbulb.on"));

string constant LightBulbOffTexture = "bafkreihaz4jaes4rix623okfyvai64jnkqwofpffamje7kgkfwemvrpiha";
string constant LightBulbOnTexture = "bafkreifcm3mxlydwxpsflgvmltyyalpus24fo2tm7dmervb2z3hwt5juuu";

contract LightBulbVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory lightBulbOffVariant;
    lightBulbOffVariant.blockType = NoaBlockType.MESH;
    lightBulbOffVariant.opaque = false;
    lightBulbOffVariant.solid = false;
    lightBulbOffVariant.frames = 1;
    string[] memory lightBulbOffMaterials = new string[](1);
    lightBulbOffMaterials[0] = LightBulbOffTexture;
    lightBulbOffVariant.materials = abi.encode(lightBulbOffMaterials);
    registerVoxelVariant(world, LightBulbOffID, lightBulbOffVariant);

    VoxelVariantsData memory lightBulbOnVariant;
    lightBulbOnVariant.blockType = NoaBlockType.MESH;
    lightBulbOnVariant.opaque = false;
    lightBulbOnVariant.solid = false;
    lightBulbOnVariant.frames = 1;
    string[] memory lightBulbOnMaterials = new string[](1);
    lightBulbOnMaterials[0] = LightBulbOnTexture;
    lightBulbOnVariant.materials = abi.encode(lightBulbOnMaterials);
    registerVoxelVariant(world, LightBulbOnID, lightBulbOnVariant);

    registerVoxelType(
      world,
      "Light Bulb",
      LightBulbID,
      EXTENSION_NAMESPACE,
      LightBulbOffID,
      IWorld(world).extension_LightBulbVoxelSy_variantSelector.selector,
      IWorld(world).extension_LightBulbVoxelSy_enterWorld.selector,
      IWorld(world).extension_LightBulbVoxelSy_exitWorld.selector,
      IWorld(world).extension_LightBulbVoxelSy_activate.selector
    );
  }

  function enterWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    Consumer.set(
      callerNamespace,
      entity,
      ConsumerData({
        source: bytes32(0),
        sourceDirection: BlockDirection.None,
        inRate: 0,
        lastUpdateBlock: block.number,
        hasValue: true
      })
    );
  }

  function exitWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    Consumer.deleteRecord(callerNamespace, entity);
  }

  function variantSelector(bytes32 entity) public view override returns (VoxelVariantsKey memory) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    ConsumerData memory consumerData = Consumer.get(callerNamespace, entity);
    if (consumerData.inRate > 0) {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: LightBulbOnID });
    } else {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: LightBulbOffID });
    }
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
