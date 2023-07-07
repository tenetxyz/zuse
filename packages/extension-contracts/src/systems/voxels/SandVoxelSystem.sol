// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";

import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Powered, PoweredData } from "../../codegen/Tables.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { registerVoxelType, registerVoxelVariant, entityIsPowered } from "../../Utils.sol";
import { VoxelVariantsData, VoxelVariantsKey } from "../../Types.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";

bytes32 constant SandID = bytes32(keccak256("sand"));

string constant SandTexture = "bafkreia4afumfatsrlbmq5azbehfwzoqmgu7bjkiutb6njsuormtsqwwbi";

string constant SandUVWrap = "bafkreiewghdyhnlq4yiqe4umxaytoy67jw3k65lwll2rbomfzr6oivhvpy";

contract SandVoxelSystem is System {
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
      IWorld(world).extension_SandVoxelSystem_sandVariantSelector.selector
    );
  }

  function getOrCreatePowered(bytes32 entity) public returns (PoweredData memory) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    if (!entityIsPowered(entity, callerNamespace)) {
      Powered.set(
        callerNamespace,
        entity,
        PoweredData({ isActive: false, direction: BlockDirection.None, hasValue: true })
      );
    }

    return Powered.get(callerNamespace, entity);
  }

  function sandVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    getOrCreatePowered(entity);
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: SandID });
  }
}
