// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, DirtVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant DirtVoxelVariantID = bytes32(keccak256("dirt"));
string constant DirtTexture = "bafkreihy3pblhqaqquwttcykwlyey3umpou57rkvtncpdrjo7mlgna53g4";
string constant DirtUVWrap = "bafkreifsrs64rckwnfkwcyqkzpdo3tpa2at7jhe6bw7jhevkxa7estkdnm";

contract DirtVoxelSystem is System {
  function registerVoxelDirt() public {
    address world = _world();
    VoxelVariantsRegistryData memory dirtVariant;
    dirtVariant.blockType = NoaBlockType.BLOCK;
    dirtVariant.opaque = true;
    dirtVariant.solid = true;
    string[] memory dirtMaterials = new string[](1);
    dirtMaterials[0] = DirtTexture;
    dirtVariant.materials = abi.encode(dirtMaterials);
    dirtVariant.uvWrap = DirtUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, DirtVoxelVariantID, dirtVariant);

    bytes32[] memory dirtChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      dirtChildVoxelTypes[i] = AirVoxelID;
    }
    registerVoxelType(REGISTRY_ADDRESS, "Dirt", DirtVoxelID, dirtChildVoxelTypes, DirtVoxelVariantID);

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      DirtVoxelID,
      IWorld(world).enterWorldDirt.selector,
      IWorld(world).exitWorldDirt.selector,
      IWorld(world).variantSelectorDirt.selector
    );
  }

  function enterWorldDirt(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function exitWorldDirt(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function variantSelectorDirt(address callerAddress, bytes32 entity) public view returns (bytes32) {
    return DirtVoxelVariantID;
  }
}
