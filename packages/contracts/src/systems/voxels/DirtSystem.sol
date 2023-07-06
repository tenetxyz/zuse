// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Occurrence, VoxelTypeData, VoxelVariantsData } from "../../codegen/Tables.sol";
import { NoaBlockType } from "../../codegen/Types.sol";
import { VoxelVariantsKey } from "../../Types.sol";
import { TENET_NAMESPACE } from "../../Constants.sol";

bytes32 constant DirtID = bytes32(keccak256("dirt"));

string constant DirtTexture = "bafkreibzraiuk6hgngtfczn57sivuqf3nv77twi6g3ftas2umjnbf6jefe";

string constant DirtUVWrap = "bafkreifbshwckn4pgw5ew2obz3i74eujzpcomatus5gu2tk7mms373gqme";

contract DirtSystem is System {
  function registerDirtVoxel() public {
    IWorld world = IWorld(_world());

    VoxelVariantsData memory dirtVariant;
    dirtVariant.blockType = NoaBlockType.BLOCK;
    dirtVariant.opaque = true;
    dirtVariant.solid = true;
    string[] memory dirtMaterials = new string[](1);
    dirtMaterials[0] = DirtTexture;
    dirtVariant.materials = abi.encode(dirtMaterials);
    dirtVariant.uvWrap = DirtUVWrap;
    world.tenet_VoxelRegistrySys_registerVoxelVariant(DirtID, dirtVariant);

    world.tenet_VoxelRegistrySys_registerVoxelType(
      "Dirt",
      DirtID,
      DirtTexture,
      world.tenet_DirtSystem_dirtVariantSelector.selector
    );

    Occurrence.set(DirtID, world.tenet_OccurrenceSystem_ODirt.selector);
  }

  function dirtVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: DirtID });
  }
}
