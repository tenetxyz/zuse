// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { BodyVariantsRegistryData } from "@tenet-registry/src/codegen/tables/BodyVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerBodyVariant, registerBodyType, bodySelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, WireVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { ElectronVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { getBodyTypeFromCaller } from "@tenet-base-ca/src/CallUtils.sol";
import { registerCABodyType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant WireOffVoxelVariantID = bytes32(keccak256("wire.off"));
bytes32 constant WireOnVoxelVariantID = bytes32(keccak256("wire.on"));

string constant WireOffTexture = "bafkreict4muklnulzho2xm73eupjehofskrotwk3d4aiagyckho2hhxwoq";
string constant WireOnTexture = "bafkreibm3kna5kjjwusivjiq3ip6ormyc2rxwrhomwiolgmwgdurlqrnhq";

string constant WireOffUVWrap = "bafkreiffca6iq4562ko5m57lq6drti27bzwxcdpbq5xcgpraxcv7knr5qa";
string constant WireOnUVWrap = "bafkreia3okzu23ncgtcgrdmgb2zgvawyqndssuxwbzt5nf4ktxvepexz3m";

contract WireVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();
    BodyVariantsRegistryData memory wireOffVariant;
    wireOffVariant.blockType = NoaBlockType.BLOCK;
    wireOffVariant.opaque = true;
    wireOffVariant.solid = true;
    string[] memory wireOffMaterials = new string[](1);
    wireOffMaterials[0] = WireOffTexture;
    wireOffVariant.materials = abi.encode(wireOffMaterials);
    wireOffVariant.uvWrap = WireOffUVWrap;
    registerBodyVariant(REGISTRY_ADDRESS, WireOffVoxelVariantID, wireOffVariant);

    BodyVariantsRegistryData memory wireOnVariant;
    wireOnVariant.blockType = NoaBlockType.BLOCK;
    wireOnVariant.opaque = true;
    wireOnVariant.solid = true;
    string[] memory wireOnMaterials = new string[](1);
    wireOnMaterials[0] = WireOnTexture;
    wireOnVariant.materials = abi.encode(wireOnMaterials);
    wireOnVariant.uvWrap = WireOnUVWrap;
    registerBodyVariant(REGISTRY_ADDRESS, WireOnVoxelVariantID, wireOnVariant);

    bytes32[] memory wireChildBodyTypes = new bytes32[](8);
    wireChildBodyTypes[4] = ElectronVoxelID;
    wireChildBodyTypes[5] = ElectronVoxelID;
    bytes32[] memory wireSchemaBodyTypes = new bytes32[](8);
    wireSchemaBodyTypes[4] = ElectronVoxelID;
    wireSchemaBodyTypes[1] = ElectronVoxelID; // The second electron moves to be diagonal from the first

    bytes32 baseBodyTypeId = WireVoxelID;
    registerBodyType(
      REGISTRY_ADDRESS,
      "Electron Wire",
      WireVoxelID,
      baseBodyTypeId,
      wireChildBodyTypes,
      wireSchemaBodyTypes,
      WireOffVoxelVariantID,
      bodySelectorsForVoxel(
        IWorld(world).extension1_WireVoxelSystem_enterWorld.selector,
        IWorld(world).extension1_WireVoxelSystem_exitWorld.selector,
        IWorld(world).extension1_WireVoxelSystem_variantSelector.selector,
        IWorld(world).extension1_WireVoxelSystem_activate.selector,
        IWorld(world).extension1_WireVoxelSystem_eventHandler.selector
      )
    );

    registerCABodyType(CA_ADDRESS, WireVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    address callerAddress = super.getCallerAddress();
    if (childEntityIds.length == 0) {
      return WireOffVoxelVariantID;
    }

    bytes32 bottomLeftType = childEntityIds[0] == 0
      ? AirVoxelID
      : getBodyTypeFromCaller(callerAddress, 1, childEntityIds[0]);
    bytes32 bottomRightType = childEntityIds[1] == 0
      ? AirVoxelID
      : getBodyTypeFromCaller(callerAddress, 1, childEntityIds[1]);
    bytes32 topLeftType = childEntityIds[4] == 0
      ? AirVoxelID
      : getBodyTypeFromCaller(callerAddress, 1, childEntityIds[4]);
    bytes32 topRightType = childEntityIds[5] == 0
      ? AirVoxelID
      : getBodyTypeFromCaller(callerAddress, 1, childEntityIds[5]);

    if (topLeftType == ElectronVoxelID && bottomRightType == ElectronVoxelID) {
      return WireOffVoxelVariantID;
    } else if (bottomLeftType == ElectronVoxelID && topRightType == ElectronVoxelID) {
      return WireOnVoxelVariantID;
    }
    return WireOffVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory) {}
}
