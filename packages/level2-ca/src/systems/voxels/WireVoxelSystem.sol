// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, WireVoxelID, WireOffVoxelVariantID, WireOnVoxelVariantID, WireOnTexture, WireOffTexture, WireOnUVWrap, WireOffUVWrap } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { ElectronVoxelID } from "@tenet-base-ca/src/Constants.sol";

contract WireVoxelSystem is System {
  function registerVoxelWire() public {
    address world = _world();
    VoxelVariantsRegistryData memory wireOffVariant;
    wireOffVariant.blockType = NoaBlockType.BLOCK;
    wireOffVariant.opaque = true;
    wireOffVariant.solid = true;
    string[] memory wireOffMaterials = new string[](1);
    wireOffMaterials[0] = WireOffTexture;
    wireOffVariant.materials = abi.encode(wireOffMaterials);
    wireOffVariant.uvWrap = WireOffUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, WireOffVoxelVariantID, wireOffVariant);

    VoxelVariantsRegistryData memory wireOnVariant;
    wireOnVariant.blockType = NoaBlockType.BLOCK;
    wireOnVariant.opaque = true;
    wireOnVariant.solid = true;
    string[] memory wireOnMaterials = new string[](1);
    wireOnMaterials[0] = WireOnTexture;
    wireOnVariant.materials = abi.encode(wireOnMaterials);
    wireOnVariant.uvWrap = WireOnUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, WireOnVoxelVariantID, wireOnVariant);

    bytes32[] memory wireChildVoxelTypes = new bytes32[](8);
    wireChildVoxelTypes[4] = ElectronVoxelID;
    wireChildVoxelTypes[5] = ElectronVoxelID;
    registerVoxelType(REGISTRY_ADDRESS, "Electron Wire", WireVoxelID, wireChildVoxelTypes, WireOffVoxelVariantID);

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      WireVoxelID,
      IWorld(world).enterWorldWire.selector,
      IWorld(world).exitWorldWire.selector,
      IWorld(world).variantSelectorWire.selector
    );
  }

  function enterWorldWire(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function exitWorldWire(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function variantSelectorWire(bytes32 entity) public view returns (bytes32) {
    return WireOffVoxelVariantID;
  }
}
