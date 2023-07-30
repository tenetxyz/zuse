// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig, CAVoxelType, CAPosition, CAPositionData, CAPositionTableId, ElectronTunnelSpot, ElectronTunnelSpotData, ElectronTunnelSpotTableId } from "@tenet-base-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, AirVoxelID, AirVoxelVariantID } from "@tenet-base-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, voxelCoordToPositionData } from "@tenet-base-ca/src/Utils.sol";

contract AirVoxelSystem is System {
  function registerVoxelAir() public {
    address world = _world();

    VoxelVariantsRegistryData memory airVariant;
    airVariant.blockType = NoaBlockType.BLOCK;
    registerVoxelVariant(REGISTRY_ADDRESS, AirVoxelVariantID, airVariant);

    bytes32[] memory airChildVoxelTypes = new bytes32[](1);
    airChildVoxelTypes[0] = AirVoxelID;
    registerVoxelType(REGISTRY_ADDRESS, "Air", AirVoxelID, airChildVoxelTypes, AirVoxelVariantID);

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      AirVoxelID,
      IWorld(world).enterWorldAir.selector,
      IWorld(world).exitWorldAir.selector,
      IWorld(world).variantSelectorAir.selector
    );
  }

  function enterWorldAir(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function exitWorldAir(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function variantSelectorAir(address callerAddress, bytes32 entity) public view returns (bytes32) {
    return AirVoxelVariantID;
  }
}
