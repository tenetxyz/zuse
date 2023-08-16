// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { BodyVariantsRegistryData } from "@tenet-registry/src/codegen/tables/BodyVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerBodyVariant, registerBodyType, bodySelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, DirtVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant DirtVoxelVariantID = bytes32(keccak256("dirt"));
string constant DirtTexture = "bafkreihy3pblhqaqquwttcykwlyey3umpou57rkvtncpdrjo7mlgna53g4";
string constant DirtUVWrap = "bafkreifsrs64rckwnfkwcyqkzpdo3tpa2at7jhe6bw7jhevkxa7estkdnm";

contract DirtVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();
    BodyVariantsRegistryData memory dirtVariant;
    dirtVariant.blockType = NoaBlockType.BLOCK;
    dirtVariant.opaque = true;
    dirtVariant.solid = true;
    string[] memory dirtMaterials = new string[](1);
    dirtMaterials[0] = DirtTexture;
    dirtVariant.materials = abi.encode(dirtMaterials);
    dirtVariant.uvWrap = DirtUVWrap;
    registerBodyVariant(REGISTRY_ADDRESS, DirtVoxelVariantID, dirtVariant);

    bytes32[] memory dirtChildBodyTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      dirtChildBodyTypes[i] = AirVoxelID;
    }
    bytes32 baseBodyTypeId = DirtVoxelID;
    registerBodyType(
      REGISTRY_ADDRESS,
      "Dirt",
      DirtVoxelID,
      baseBodyTypeId,
      dirtChildBodyTypes,
      dirtChildBodyTypes,
      DirtVoxelVariantID,
      bodySelectorsForVoxel(
        IWorld(world).ca_DirtVoxelSystem_enterWorld.selector,
        IWorld(world).ca_DirtVoxelSystem_exitWorld.selector,
        IWorld(world).ca_DirtVoxelSystem_variantSelector.selector,
        IWorld(world).ca_DirtVoxelSystem_activate.selector,
        IWorld(world).ca_DirtVoxelSystem_eventHandler.selector
      )
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
  ) public override returns (bytes32, bytes32[] memory) {}
}
