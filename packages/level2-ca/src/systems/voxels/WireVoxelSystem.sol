// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-level2-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, WireVoxelID, Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { ElectronVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { getVoxelTypeFromCaller } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant WireOffVoxelVariantID = bytes32(keccak256("wire.off"));
bytes32 constant WireOnVoxelVariantID = bytes32(keccak256("wire.on"));

string constant WireOffTexture = "bafkreict4muklnulzho2xm73eupjehofskrotwk3d4aiagyckho2hhxwoq";
string constant WireOnTexture = "bafkreibm3kna5kjjwusivjiq3ip6ormyc2rxwrhomwiolgmwgdurlqrnhq";

string constant WireOffUVWrap = "bafkreiffca6iq4562ko5m57lq6drti27bzwxcdpbq5xcgpraxcv7knr5qa";
string constant WireOnUVWrap = "bafkreia3okzu23ncgtcgrdmgb2zgvawyqndssuxwbzt5nf4ktxvepexz3m";

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
    bytes32[] memory wireSchemaVoxelTypes = new bytes32[](8);
    wireSchemaVoxelTypes[4] = ElectronVoxelID;
    wireSchemaVoxelTypes[1] = ElectronVoxelID; // The second electron moves to be diagonal from the first

    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    registerVoxelType(REGISTRY_ADDRESS, "Electron Wire", WireVoxelID, baseVoxelTypeId, wireChildVoxelTypes, wireSchemaVoxelTypes, WireOffVoxelVariantID);

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      WireVoxelID,
      IWorld(world).enterWorldWire.selector,
      IWorld(world).exitWorldWire.selector,
      IWorld(world).variantSelectorWire.selector,
      IWorld(world).activateSelectorWire.selector,
      IWorld(world).eventHandlerWire.selector
    );
  }

  function enterWorldWire(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function exitWorldWire(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function variantSelectorWire(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32) {
    if (childEntityIds.length == 0) {
      return WireOffVoxelVariantID;
    }

    bytes32 bottomLeftType = childEntityIds[0] == 0
      ? AirVoxelID
      : getVoxelTypeFromCaller(callerAddress, 1, childEntityIds[0]);
    bytes32 bottomRightType = childEntityIds[1] == 0
      ? AirVoxelID
      : getVoxelTypeFromCaller(callerAddress, 1, childEntityIds[1]);
    bytes32 topLeftType = childEntityIds[4] == 0
      ? AirVoxelID
      : getVoxelTypeFromCaller(callerAddress, 1, childEntityIds[4]);
    bytes32 topRightType = childEntityIds[5] == 0
      ? AirVoxelID
      : getVoxelTypeFromCaller(callerAddress, 1, childEntityIds[5]);

    if (topLeftType == ElectronVoxelID && bottomRightType == ElectronVoxelID) {
      return WireOffVoxelVariantID;
    } else if (bottomLeftType == ElectronVoxelID && topRightType == ElectronVoxelID) {
      return WireOnVoxelVariantID;
    }
    return WireOffVoxelVariantID;
  }

  function activateSelectorWire(address callerAddress, bytes32 entity) public view returns (string memory) {}


  function eventHandlerWire(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {}
}
