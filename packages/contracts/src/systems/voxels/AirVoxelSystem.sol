// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "../../prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Occurrence, VoxelTypeData, VoxelVariantsData } from "../../codegen/Tables.sol";
import { NoaBlockType } from "../../codegen/Types.sol";
import { VoxelVariantsKey } from "../../Types.sol";
import { TENET_NAMESPACE } from "../../Constants.sol";

bytes32 constant AirID = bytes32(keccak256("air"));

contract AirVoxelSystem is VoxelType {
  function registerVoxel() public override {
    IWorld world = IWorld(_world());

    VoxelVariantsData memory airVariant;
    airVariant.blockType = NoaBlockType.BLOCK;
    world.tenet_VoxelRegistrySys_registerVoxelVariant(AirID, airVariant);

    world.tenet_VoxelRegistrySys_registerVoxelType(
      "Air",
      AirID,
      "",
      "",
      world.tenet_AirVoxelSystem_airVariantSelector.selector
    );
  }

  function airVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: AirID });
  }
}
