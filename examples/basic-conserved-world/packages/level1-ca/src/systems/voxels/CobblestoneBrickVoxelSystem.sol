// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CobblestoneBrickVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";

bytes32 constant CobblestoneBrickVoxelVariantID = bytes32(keccak256("cobblestoneBrick"));
string constant CobblestoneBrickTexture = "bafkreihy3pblhqaqquwttcykwlyey3umpou57rkvtncpdrjo7mlgna53g4";
string constant CobblestoneBrickUVWrap = "bafkreifsrs64rckwnfkwcyqkzpdo3tpa2at7jhe6bw7jhevkxa7estkdnm";

contract CobblestoneBrickVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cobblestonebrickVariant;
    cobblestonebrickVariant.blockType = NoaBlockType.BLOCK;
    cobblestonebrickVariant.opaque = true;
    cobblestonebrickVariant.solid = true;
    string[] memory cobblestonebrickMaterials = new string[](1);
    cobblestonebrickMaterials[0] = CobblestoneBrickTexture;
    cobblestonebrickVariant.materials = abi.encode(cobblestonebrickMaterials);
    cobblestonebrickVariant.uvWrap = CobblestoneBrickUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, CobblestoneBrickVoxelVariantID, cobblestonebrickVariant);

    bytes32[] memory cobblestonebrickChildVoxelTypes = new bytes32[](1);
    cobblestonebrickChildVoxelTypes[0] = CobblestoneBrickVoxelID;
    bytes32 baseVoxelTypeId = CobblestoneBrickVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "CobblestoneBrick",
      CobblestoneBrickVoxelID,
      baseVoxelTypeId,
      cobblestonebrickChildVoxelTypes,
      cobblestonebrickChildVoxelTypes,
      CobblestoneBrickVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).ca_CobblestoneBrickVoxelSystem_enterWorld.selector,
        IWorld(world).ca_CobblestoneBrickVoxelSystem_exitWorld.selector,
        IWorld(world).ca_CobblestoneBrickVoxelSystem_variantSelector.selector,
        IWorld(world).ca_CobblestoneBrickVoxelSystem_activate.selector,
        IWorld(world).ca_CobblestoneBrickVoxelSystem_eventHandler.selector,
        IWorld(world).ca_CobblestoneBrickVoxelSystem_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
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
    return CobblestoneBrickVoxelVariantID;
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
