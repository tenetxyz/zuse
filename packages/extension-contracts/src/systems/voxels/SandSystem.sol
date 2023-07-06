// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";

import { IWorld } from "../../../src/codegen/world/IWorld.sol";

import { registerVoxelType, registerVoxelVariant } from "../../Utils.sol";
import { VoxelVariantsData, VoxelVariantsKey } from "../../Types.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";

bytes32 constant SandID = bytes32(keccak256("sand"));

string constant SandTexture = "bafkreia4afumfatsrlbmq5azbehfwzoqmgu7bjkiutb6njsuormtsqwwbi";

string constant SandUVWrap = "bafkreiewghdyhnlq4yiqe4umxaytoy67jw3k65lwll2rbomfzr6oivhvpy";

contract SandSystem is System {
  function registerSandVoxel() public {
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
      "Sand",
      SandID,
      SandTexture,
      IWorld(world).extension_SandSystem_sandVariantSelector.selector
    );
  }

  function sandVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SandID });
  }
}
