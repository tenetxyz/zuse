// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenet-contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Generator } from "../../codegen/Tables.sol";
import { getCallerNamespace } from "@tenet-contracts/src/Utils.sol";
import { registerVoxelType, registerVoxelVariant, entityIsGenerator } from "../../Utils.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { VoxelVariantsData } from "@tenet-contracts/src/codegen/tables/VoxelVariants.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";

bytes32 constant ThermoGenID = bytes32(keccak256("thermogen"));

string constant SignalSourceTexture = "bafkreidohfeb5yddppqv6swfjs6s3g7qe44u75ogwaqkky4nolgh7bbafu";

string constant SignalSourceUVWrap = "bafkreigx5gstl4b2fcz62dwex55mstoo7egdcsrmsox6trmiieplcuyalm";

contract ThermoGenVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory signalSourceVariant;
    signalSourceVariant.blockType = NoaBlockType.BLOCK;
    signalSourceVariant.opaque = true;
    signalSourceVariant.solid = true;
    string[] memory signalSourceMaterials = new string[](1);
    signalSourceMaterials[0] = SignalSourceTexture;
    signalSourceVariant.materials = abi.encode(signalSourceMaterials);
    signalSourceVariant.uvWrap = SignalSourceUVWrap;
    registerVoxelVariant(world, ThermoGenID, signalSourceVariant);

    registerVoxelType(
      world,
      "ThermoGen",
      ThermoGenID,
      EXTENSION_NAMESPACE,
      ThermoGenID,
      IWorld(world).extension_ThermoGenVoxelSy_variantSelector.selector,
      IWorld(world).extension_ThermoGenVoxelSy_enterWorld.selector,
      IWorld(world).extension_ThermoGenVoxelSy_exitWorld.selector
    );
  }

  function enterWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    bytes32[] memory sources = new bytes32[](0);
    uint256 genRate = 0;
    bool hasValue = true;
    Generator.set(callerNamespace, entity, genRate, hasValue, sources);
  }

  function exitWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    Generator.deleteRecord(callerNamespace, entity);
  }

  function variantSelector(bytes32 entity) public view override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: ThermoGenID });
  }
}