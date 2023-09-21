// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, DirtVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";
import { AirVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { CAEventData, CAEventType } from "@tenet-utils/src/Types.sol";
import { CAVoxelType } from "@tenet-level1-ca/src/codegen/tables/CAVoxelType.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";

bytes32 constant DirtVoxelVariantID = bytes32(keccak256("dirt"));
string constant DirtTexture = "bafkreihy3pblhqaqquwttcykwlyey3umpou57rkvtncpdrjo7mlgna53g4";
string constant DirtUVWrap = "bafkreifsrs64rckwnfkwcyqkzpdo3tpa2at7jhe6bw7jhevkxa7estkdnm";

contract DirtVoxelSystem is VoxelType {
  function registerBody() public override {
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

    bytes32[] memory dirtChildVoxelTypes = new bytes32[](1);
    dirtChildVoxelTypes[0] = DirtVoxelID;
    bytes32 baseVoxelTypeId = DirtVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Dirt",
      DirtVoxelID,
      baseVoxelTypeId,
      dirtChildVoxelTypes,
      dirtChildVoxelTypes,
      DirtVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).ca_DirtVoxelSystem_enterWorld.selector,
        IWorld(world).ca_DirtVoxelSystem_exitWorld.selector,
        IWorld(world).ca_DirtVoxelSystem_variantSelector.selector,
        IWorld(world).ca_DirtVoxelSystem_activate.selector,
        IWorld(world).ca_DirtVoxelSystem_eventHandler.selector
      ),
      abi.encode(componentDefs)
    );
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return DirtVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory, bytes[] memory) {
    // TODO: Remove, was for testing only to show how you voxel types can move
    bytes32 changedCenterEntityId = 0;
    bytes32[] memory changedNeighbourEntityIds = new bytes32[](neighbourEntityIds.length);
    bytes[] memory entityEventData = new bytes[](neighbourEntityIds.length + 1);
    for (uint8 i; i < neighbourEntityIds.length; i++) {
      if (neighbourEntityIds[i] == 0) {
        continue;
      }
      VoxelCoord memory baseCoord = getCAEntityPositionStrict(IStore(_world()), centerEntityId);
      VoxelCoord memory newCoord = VoxelCoord({ x: baseCoord.x, y: baseCoord.y + 1, z: baseCoord.z });
      bytes32 neighbourVoxelTypeId = getCAVoxelType(neighbourEntityIds[i]);

      if (neighbourVoxelTypeId == BedrockVoxelID) {
        entityEventData[0] = abi.encode(CAEventData({ eventType: CAEventType.Move, newCoord: newCoord }));
      }
    }

    return (changedCenterEntityId, changedNeighbourEntityIds, entityEventData);
  }
}
