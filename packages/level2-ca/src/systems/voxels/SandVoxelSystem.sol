// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig, Powered, PoweredData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, SandVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant SandVoxelVariantID = bytes32(keccak256("sand"));

string constant SandTexture = "bafkreia4afumfatsrlbmq5azbehfwzoqmgu7bjkiutb6njsuormtsqwwbi";

string constant SandUVWrap = "bafkreiewghdyhnlq4yiqe4umxaytoy67jw3k65lwll2rbomfzr6oivhvpy";

contract SandVoxelSystem is System {
  function registerVoxelSand() public {
    address world = _world();

    VoxelVariantsRegistryData memory sandVariant;
    sandVariant.blockType = NoaBlockType.BLOCK;
    sandVariant.opaque = true;
    sandVariant.solid = true;
    string[] memory sandMaterials = new string[](1);
    sandMaterials[0] = SandTexture;
    sandVariant.materials = abi.encode(sandMaterials);
    sandVariant.uvWrap = SandUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, SandVoxelVariantID, sandVariant);

    bytes32[] memory sandChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      sandChildVoxelTypes[i] = AirVoxelID;
    }
    registerVoxelType(REGISTRY_ADDRESS, "Powered Sand", SandVoxelID, sandChildVoxelTypes, SandVoxelVariantID);

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      SandVoxelID,
      IWorld(world).enterWorldSand.selector,
      IWorld(world).exitWorldSand.selector,
      IWorld(world).variantSelectorSand.selector,
      IWorld(world).activateSelectorSand.selector
    );
  }

  function enterWorldSand(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    Powered.set(
      callerAddress,
      entity,
      PoweredData({ isActive: false, direction: BlockDirection.None, hasValue: true })
    );
  }

  function exitWorldSand(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    Powered.deleteRecord(callerAddress, entity);
  }

  function variantSelectorSand(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    return SandVoxelVariantID;
  }

  function activateSelectorSand(address callerAddress, bytes32 entity) public view returns (string memory) {}
}
