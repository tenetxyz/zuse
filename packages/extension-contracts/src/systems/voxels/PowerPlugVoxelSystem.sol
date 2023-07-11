// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenet-contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerPlug, PowerPlugData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { getCallerNamespace } from "@tenet-contracts/src/Utils.sol";
import { registerVoxelType, registerVoxelVariant, entityIsGenerator } from "../../Utils.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { VoxelVariantsData } from "@tenet-contracts/src/codegen/tables/VoxelVariants.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";

bytes32 constant PowerPlugID = bytes32(keccak256("powerplug"));

string constant PowerPlugTexture = "bafkreidohfeb5yddppqv6swfjs6s3g7qe44u75ogwaqkky4nolgh7bbafu";

string constant PowerPlugUVWrap = "bafkreigx5gstl4b2fcz62dwex55mstoo7egdcsrmsox6trmiieplcuyalm";

contract PowerPlugVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory signalSourceVariant;
    signalSourceVariant.blockType = NoaBlockType.BLOCK;
    signalSourceVariant.opaque = true;
    signalSourceVariant.solid = true;
    string[] memory signalSourceMaterials = new string[](1);
    signalSourceMaterials[0] = PowerPlugTexture;
    signalSourceVariant.materials = abi.encode(signalSourceMaterials);
    signalSourceVariant.uvWrap = PowerPlugUVWrap;
    registerVoxelVariant(world, PowerPlugID, signalSourceVariant);

    registerVoxelType(
      world,
      "Power Plug",
      PowerPlugID,
      EXTENSION_NAMESPACE,
      PowerPlugID,
      IWorld(world).extension_PowerPlugVoxelSy_variantSelector.selector,
      IWorld(world).extension_PowerPlugVoxelSy_enterWorld.selector,
      IWorld(world).extension_PowerPlugVoxelSy_exitWorld.selector,
      IWorld(world).extension_PowerPlugVoxelSy_activate.selector
    );
  }

  function enterWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    
    bytes32 _source = bytes32(0);
    bytes32 _destination = bytes32(0);

    PowerPlug.set(
      callerNamespace,
      entity,
      PowerPlugData({ source: _source, destination: _destination, genRate: 0, direction: BlockDirection.None, hasValue: true })
    );
  }

  function exitWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    PowerPlug.deleteRecord(callerNamespace, entity);
  }

  function variantSelector(bytes32 entity) public view override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: PowerPlugID });
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
