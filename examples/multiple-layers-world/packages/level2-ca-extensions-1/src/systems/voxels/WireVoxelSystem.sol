// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, WireVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, ComponentDef, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { ElectronVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { getVoxelTypeFromCaller } from "@tenet-base-ca/src/CallUtils.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant WireOffVoxelVariantID = bytes32(keccak256("wire.off"));
bytes32 constant WireOnVoxelVariantID = bytes32(keccak256("wire.on"));

string constant WireOffTexture = "bafkreict4muklnulzho2xm73eupjehofskrotwk3d4aiagyckho2hhxwoq";
string constant WireOnTexture = "bafkreibm3kna5kjjwusivjiq3ip6ormyc2rxwrhomwiolgmwgdurlqrnhq";

string constant WireOffUVWrap = "bafkreiffca6iq4562ko5m57lq6drti27bzwxcdpbq5xcgpraxcv7knr5qa";
string constant WireOnUVWrap = "bafkreia3okzu23ncgtcgrdmgb2zgvawyqndssuxwbzt5nf4ktxvepexz3m";

contract WireVoxelSystem is VoxelType {
  function registerBody() public override {
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

    bytes32 baseVoxelTypeId = WireVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Electron Wire",
      WireVoxelID,
      baseVoxelTypeId,
      wireChildVoxelTypes,
      wireSchemaVoxelTypes,
      WireOffVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).extension1_WireVoxelSystem_enterWorld.selector,
        IWorld(world).extension1_WireVoxelSystem_exitWorld.selector,
        IWorld(world).extension1_WireVoxelSystem_variantSelector.selector,
        IWorld(world).extension1_WireVoxelSystem_activate.selector,
        IWorld(world).extension1_WireVoxelSystem_eventHandler.selector,
        IWorld(world).extension1_WireVoxelSystem_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, WireVoxelID);
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
      : getVoxelTypeFromCaller(callerAddress, VoxelEntity({ scale: 1, entityId: childEntityIds[0] }));
    bytes32 bottomRightType = childEntityIds[1] == 0
      ? AirVoxelID
      : getVoxelTypeFromCaller(callerAddress, VoxelEntity({ scale: 1, entityId: childEntityIds[1] }));
    bytes32 topLeftType = childEntityIds[4] == 0
      ? AirVoxelID
      : getVoxelTypeFromCaller(callerAddress, VoxelEntity({ scale: 1, entityId: childEntityIds[4] }));
    bytes32 topRightType = childEntityIds[5] == 0
      ? AirVoxelID
      : getVoxelTypeFromCaller(callerAddress, VoxelEntity({ scale: 1, entityId: childEntityIds[5] }));

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
  ) public override returns (bool, bytes memory) {}

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, bytes memory) {}
}
