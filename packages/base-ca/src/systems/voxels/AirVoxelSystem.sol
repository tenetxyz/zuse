// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig, CAVoxelType, CAPosition, CAPositionData, CAPositionTableId, ElectronTunnelSpot, ElectronTunnelSpotData, ElectronTunnelSpotTableId } from "@base-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, AirVoxelID, AirVoxelVariantID, ElectronVoxelID, ElectronVoxelVariantID, ElectronTexture } from "@base-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, voxelCoordToPositionData } from "@base-ca/src/Utils.sol";

string constant ElectronTexture = "bafkreibmk2qi52v4atyfka3x5ygj44vfig7ks4jz6xzxqfdzduux3fqifa";

contract AirVoxelSystem is System {
  function registerVoxelAir() public {
    VoxelVariantsRegistryData memory airVariant;
    airVariant.blockType = NoaBlockType.BLOCK;
    registerVoxelVariant(REGISTRY_ADDRESS, AirVoxelVariantID, airVariant);

    bytes32[] memory airChildVoxelTypes = new bytes32[](1);
    airChildVoxelTypes[0] = AirVoxelID;
    registerVoxelType(REGISTRY_ADDRESS, "Air", AirVoxelID, airChildVoxelTypes, AirVoxelVariantID);

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      ElectronVoxelID,
      IWorld(world).enterWorldAir.selector,
      IWorld(world).exitWorldAir.selector,
      IWorld(world).variantSelectorAir.selector
    );
  }

  function enterWorldAir(VoxelCoord memory coord, bytes32 entity) public {}

  function exitWorldAir(VoxelCoord memory coord, bytes32 entity) public {}

  function variantSelectorAir(bytes32 entity) public view returns (bytes32) {
    return AirVoxelVariantID;
  }
}
