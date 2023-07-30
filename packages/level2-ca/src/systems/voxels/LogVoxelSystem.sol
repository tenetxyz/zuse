// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, LogVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant LogVoxelVariantID = bytes32(keccak256("log"));

string constant LogTexture = "bafkreihllk5lrr2l2fgvmgzzyyxw5kostinfee2gi55kln2mzihfp2mumy";
string constant LogTopTexture = "bafkreiekx2odo544mawzn7np6p4uhkm2bt53nl4n2dhzj3ubbd5hi4jnf4";

string constant LogUVWrap = "bafkreiddsx5ke3e664ain2gnzd7jxicko34clxnlqzp2paqomvf7a7gb7m";

contract LogVoxelSystem is System {
  function registerVoxelLog() public {
    address world = _world();
    VoxelVariantsRegistryData memory logVariant;
    logVariant.blockType = NoaBlockType.BLOCK;
    logVariant.opaque = true;
    logVariant.solid = true;
    string[] memory logMaterials = new string[](2);
    logMaterials[0] = LogTopTexture;
    logMaterials[1] = LogTexture;
    logVariant.materials = abi.encode(logMaterials);
    logVariant.uvWrap = LogUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, LogVoxelVariantID, logVariant);

    bytes32[] memory logChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      logChildVoxelTypes[i] = AirVoxelID;
    }
    registerVoxelType(REGISTRY_ADDRESS, "Log", LogVoxelID, logChildVoxelTypes, LogVoxelVariantID);

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      LogVoxelID,
      IWorld(world).enterWorldLog.selector,
      IWorld(world).exitWorldLog.selector,
      IWorld(world).variantSelectorLog.selector
    );
  }

  function enterWorldLog(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function exitWorldLog(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function variantSelectorLog(address callerAddress, bytes32 entity) public view returns (bytes32) {
    return LogVoxelVariantID;
  }
}
