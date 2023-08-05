// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level3-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig } from "@tenet-level3-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, RoadVoxelID } from "@tenet-level3-ca/src/Constants.sol";
import { DirtVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant RoadVoxelVariantID = bytes32(keccak256("road"));

string constant RoadTexture = "bafkreiaavptzcmkl6xdyqk6ivp75ehsx45yl6kgxnahumozfbur6z6xcni";
string constant RoadUVWrap = "bafkreihibx43dpw57halle4yfzidfrclm35xlyoiko3kq3m2uh5mewnmyu";

contract RoadVoxelSystem is System {
  function registerVoxelRoad() public {
    address world = _world();
    VoxelVariantsRegistryData memory roadVariant;
    roadVariant.blockType = NoaBlockType.BLOCK;
    roadVariant.opaque = true;
    roadVariant.solid = true;
    string[] memory roadMaterials = new string[](1);
    roadMaterials[0] = RoadTexture;
    roadVariant.materials = abi.encode(roadMaterials);
    roadVariant.uvWrap = RoadUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, RoadVoxelVariantID, roadVariant);

    bytes32[] memory roadChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      roadChildVoxelTypes[i] = DirtVoxelID;
    }
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Road",
      RoadVoxelID,
      roadChildVoxelTypes,
      roadChildVoxelTypes,
      RoadVoxelVariantID
    );

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      RoadVoxelID,
      IWorld(world).enterWorldRoad.selector,
      IWorld(world).exitWorldRoad.selector,
      IWorld(world).variantSelectorRoad.selector,
      IWorld(world).activateSelectorRoad.selector
    );
  }

  function enterWorldRoad(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function exitWorldRoad(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function variantSelectorRoad(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    return RoadVoxelVariantID;
  }

  function activateSelectorRoad(address callerAddress, bytes32 entity) public view returns (string memory) {}
}
