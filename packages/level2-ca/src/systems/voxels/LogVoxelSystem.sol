// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, LogVoxelID, Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
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

    bytes32[] memory logChildVoxelTypes = VoxelTypeRegistry.getChildVoxelTypeIds(IStore(REGISTRY_ADDRESS), Level2AirVoxelID);
    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    registerVoxelType(REGISTRY_ADDRESS, "Log", LogVoxelID, baseVoxelTypeId, logChildVoxelTypes, logChildVoxelTypes, LogVoxelVariantID);

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      LogVoxelID,
      IWorld(world).enterWorldLog.selector,
      IWorld(world).exitWorldLog.selector,
      IWorld(world).variantSelectorLog.selector,
      IWorld(world).activateSelectorLog.selector,
      IWorld(world).eventHandlerLog.selector
    );
  }

  function enterWorldLog(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function exitWorldLog(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function variantSelectorLog(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    return LogVoxelVariantID;
  }

  function activateSelectorLog(address callerAddress, bytes32 entity) public view returns (string memory) {}

  function eventHandlerLog(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {}
}
