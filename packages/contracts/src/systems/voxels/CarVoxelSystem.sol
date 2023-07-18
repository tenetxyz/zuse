// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "../../prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Occurrence, VoxelTypeData, VoxelVariantsData } from "@tenet-contracts/src/codegen/Tables.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { TENET_NAMESPACE } from "../../Constants.sol";

bytes32 constant CarID = bytes32(keccak256("car"));

string constant CarTexture = "bafkreieq2ss2t4u32hye2mrkfdb3rgzlp64b4nqhhpseb5w7ntx2w6vhnq";

contract CarVoxelSystem is VoxelType {
  function registerVoxel() public override {
    IWorld world = IWorld(_world());

    VoxelVariantsData memory carVariant;
    carVariant.blockType = NoaBlockType.MESH;
    carVariant.opaque = false;
    carVariant.solid = false;
    carVariant.frames = 1;
    string[] memory carMaterials = new string[](1);
    carMaterials[0] = CarTexture;
    carVariant.materials = abi.encode(carMaterials);

    world.tenet_VoxelRegistrySys_registerVoxelVariant(CarID, carVariant);

    world.tenet_VoxelRegistrySys_registerVoxelType(
      "Car",
      CarID,
      TENET_NAMESPACE,
      CarID,
      world.tenet_CarVoxelSystem_variantSelector.selector,
      world.tenet_CarVoxelSystem_enterWorld.selector,
      world.tenet_CarVoxelSystem_exitWorld.selector,
      world.tenet_CarVoxelSystem_activate.selector
    );
  }

  function enterWorld(bytes32 entity) public override {}

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public pure override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: CarID });
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
