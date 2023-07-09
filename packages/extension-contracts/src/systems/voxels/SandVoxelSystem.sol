// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenetxyz/contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Powered, PoweredData } from "../../codegen/Tables.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { registerVoxelType, registerVoxelVariant, entityIsPowered } from "../../Utils.sol";
import { VoxelVariantsKey } from "@tenetxyz/contracts/src/Types.sol";
import { VoxelVariantsData } from "../../Types.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";

bytes32 constant SandID = bytes32(keccak256("sand"));

string constant SandTexture = "bafkreia4afumfatsrlbmq5azbehfwzoqmgu7bjkiutb6njsuormtsqwwbi";

string constant SandUVWrap = "bafkreiewghdyhnlq4yiqe4umxaytoy67jw3k65lwll2rbomfzr6oivhvpy";

contract SandVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory sandVariant;
    sandVariant.blockType = NoaBlockType.BLOCK;
    sandVariant.opaque = true;
    sandVariant.solid = true;
    string[] memory sandMaterials = new string[](1);
    sandMaterials[0] = SandTexture;
    sandVariant.materials = abi.encode(sandMaterials);
    sandVariant.uvWrap = SandUVWrap;
    registerVoxelVariant(world, SandID, sandVariant);

    registerVoxelType(
      world,
      "Powered Sand",
      SandID,
      EXTENSION_NAMESPACE,
      SandID,
      IWorld(world).extension_SandVoxelSystem_variantSelector.selector,
      IWorld(world).extension_SandVoxelSystem_enterWorld.selector,
      IWorld(world).extension_SandVoxelSystem_exitWorld.selector
    );
  }

  function enterWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    Powered.set(
      callerNamespace,
      entity,
      PoweredData({ isActive: false, direction: BlockDirection.None, hasValue: true })
    );
  }

  function exitWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    Powered.deleteRecord(callerNamespace, entity);
  }

  function variantSelector(bytes32 entity) public view override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SandID });
  }
}