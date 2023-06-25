// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";
import { VoxelVariantsKey } from "../types.sol";

// TODO: should not be duplicated from "@tenetxyz/contracts
struct VoxelVariantsData {
  uint32 variantId;
  uint32 frames;
  bool opaque;
  bool fluid;
  bool solid;
  NoaBlockType blockType;
  string material;
  string uvWrap;
}

contract ExtensionInitSystem is System {

    function sandVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
        return VoxelVariantsKey({
            namespace: bytes16("tenet"),
            voxelVariantId: bytes32(keccak256("sand"))
        });
    }

    function init() public {
        // register graphics
        VoxelVariantsData memory sandVariant = VoxelVariantsData({
            variantId: 4,
            frames: 0,
            opaque: true,
            fluid: false,
            solid: true,
            blockType: NoaBlockType.BLOCK,
            material: "bafkreia4afumfatsrlbmq5azbehfwzoqmgu7bjkiutb6njsuormtsqwwbi",
            uvWrap: "bafkreiewghdyhnlq4yiqe4umxaytoy67jw3k65lwll2rbomfzr6oivhvpy"
        });
        (bool success, bytes memory result) = _world().call(abi.encodeWithSignature("tenet_VoxelRegistrySys_registerVoxelVariant(bytes32,(uint32,uint32,bool,bool,bool,uint8,string,string))", bytes32(keccak256("sand")), sandVariant));
        require(success, "Failed to register sand variant");

        (success, result) = _world().call(abi.encodeWithSignature("tenet_VoxelRegistrySys_registerVoxelType(bytes32,string,bytes4)", bytes32(keccak256("sand")), "bafkreia4afumfatsrlbmq5azbehfwzoqmgu7bjkiutb6njsuormtsqwwbi", IWorld(_world()).tenet_ExtensionInitSys_sandVariantSelector.selector));
        require(success, "Failed to register sand type");
    }
}
