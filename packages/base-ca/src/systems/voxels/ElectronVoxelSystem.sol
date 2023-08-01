// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-base-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig, CAVoxelType, ElectronTunnelSpot, ElectronTunnelSpotData, ElectronTunnelSpotTableId } from "@tenet-base-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, AirVoxelID, AirVoxelVariantID, ElectronVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, voxelCoordToPositionData } from "@tenet-base-ca/src/Utils.sol";

bytes32 constant ElectronVoxelVariantID = bytes32(keccak256("electron"));
string constant ElectronTexture = "bafkreigrssavucschngym657tmepaqe2mmjyjoc7arznjygjsfdfi2cxny";

contract ElectronVoxelSystem is System {
  function registerVoxelElectron() public {
    address world = _world();
    VoxelVariantsRegistryData memory electronVariant;
    electronVariant.blockType = NoaBlockType.MESH;
    electronVariant.opaque = false;
    electronVariant.solid = false;
    electronVariant.frames = 1;
    string[] memory electronMaterials = new string[](1);
    electronMaterials[0] = ElectronTexture;
    electronVariant.materials = abi.encode(electronMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, ElectronVoxelVariantID, electronVariant);

    bytes32[] memory electronChildVoxelTypes = new bytes32[](1);
    electronChildVoxelTypes[0] = ElectronVoxelID;
    bytes32 baseVoxelTypeId = ElectronVoxelID;
    registerVoxelType(REGISTRY_ADDRESS, "Electron", ElectronVoxelID, baseVoxelTypeId, electronChildVoxelTypes, electronChildVoxelTypes, ElectronVoxelVariantID);

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      ElectronVoxelID,
      IWorld(world).enterWorldElectron.selector,
      IWorld(world).exitWorldElectron.selector,
      IWorld(world).variantSelectorElectron.selector,
      IWorld(world).activateSelectorElectron.selector,
      IWorld(world).eventHandlerElectron.selector
    );
  }

  function enterWorldElectron(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    // Check one above
    VoxelCoord memory aboveCoord = VoxelCoord(coord.x, coord.y, coord.z + 1);
    bytes32 aboveEntity = getEntityAtCoord(IStore(_world()), callerAddress, aboveCoord);
    if (hasKey(ElectronTunnelSpotTableId, ElectronTunnelSpot.encodeKeyTuple(callerAddress, entity))) {
      ElectronTunnelSpotData memory electronTunnelData = ElectronTunnelSpot.get(callerAddress, entity);
      if (electronTunnelData.atTop) {
        if (CAVoxelType.getVoxelTypeId(callerAddress, electronTunnelData.sibling) == AirVoxelID) {
          ElectronTunnelSpot.setAtTop(callerAddress, entity, false);
          ElectronTunnelSpot.setAtTop(callerAddress, electronTunnelData.sibling, false);
        }
      } else {
        if (CAVoxelType.getVoxelTypeId(callerAddress, electronTunnelData.sibling) == AirVoxelID) {
          ElectronTunnelSpot.setAtTop(callerAddress, entity, true);
          ElectronTunnelSpot.setAtTop(callerAddress, electronTunnelData.sibling, true);
        }
      }
    } else {
      if (aboveEntity != 0) {
        if (CAVoxelType.getVoxelTypeId(callerAddress, aboveEntity) == ElectronVoxelID) {
          bool neighbourAtTop = ElectronTunnelSpot.get(callerAddress, aboveEntity).atTop;
          if (neighbourAtTop) {
            revert("ElectronSystem: Cannot place electron when it's tunneling spot is already occupied (south)");
          } else {
            ElectronTunnelSpot.set(callerAddress, entity, true, 0);
          }
        } else {
          if (hasKey(ElectronTunnelSpotTableId, ElectronTunnelSpot.encodeKeyTuple(callerAddress, aboveEntity))) {
            if (ElectronTunnelSpot.get(callerAddress, aboveEntity).atTop) {
              ElectronTunnelSpot.set(callerAddress, aboveEntity, false, entity);
              ElectronTunnelSpot.set(callerAddress, entity, false, aboveEntity);
            } else {
              revert("ElectronSystem: should not be here.");
            }
          }
        }
      } else {
        ElectronTunnelSpot.set(callerAddress, entity, true, 0);
      }
    }
  }

  function exitWorldElectron(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    // TODO: Remove values from ElectronTunnelSpot
  }

  function variantSelectorElectron(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    return ElectronVoxelVariantID;
  }

  function activateSelectorElectron(address callerAddress, bytes32 entity) public view returns (string memory) {}
}
