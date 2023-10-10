// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { ElectronTunnelSpot, ElectronTunnelSpotData, ElectronTunnelSpotTableId } from "@tenet-level1-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, AirVoxelID, AirVoxelVariantID, ElectronVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { getCAEntityAtCoord, getCAVoxelType } from "@tenet-base-ca/src/Utils.sol";

bytes32 constant ElectronVoxelVariantID = bytes32(keccak256("electron"));
string constant ElectronTexture = "bafkreigrssavucschngym657tmepaqe2mmjyjoc7arznjygjsfdfi2cxny";

contract ElectronVoxelSystem is VoxelType {
  function registerBody() public override {
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
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Electron",
      ElectronVoxelID,
      baseVoxelTypeId,
      electronChildVoxelTypes,
      electronChildVoxelTypes,
      ElectronVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).ca_ElectronVoxelSys_enterWorld.selector,
        IWorld(world).ca_ElectronVoxelSys_exitWorld.selector,
        IWorld(world).ca_ElectronVoxelSys_variantSelector.selector,
        IWorld(world).ca_ElectronVoxelSys_activate.selector,
        IWorld(world).ca_ElectronVoxelSys_eventHandler.selector,
        IWorld(world).ca_ElectronVoxelSys_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();

    // Check one above
    VoxelCoord memory aboveCoord = VoxelCoord(coord.x, coord.y, coord.z + 1);
    bytes32 aboveEntity = getCAEntityAtCoord(IStore(_world()), callerAddress, aboveCoord);
    if (hasKey(ElectronTunnelSpotTableId, ElectronTunnelSpot.encodeKeyTuple(callerAddress, entity))) {
      ElectronTunnelSpotData memory electronTunnelData = ElectronTunnelSpot.get(callerAddress, entity);
      if (electronTunnelData.atTop) {
        if (getCAVoxelType(electronTunnelData.sibling) == AirVoxelID) {
          ElectronTunnelSpot.setAtTop(callerAddress, entity, false);
          ElectronTunnelSpot.setAtTop(callerAddress, electronTunnelData.sibling, false);
        }
      } else {
        if (getCAVoxelType(electronTunnelData.sibling) == AirVoxelID) {
          ElectronTunnelSpot.setAtTop(callerAddress, entity, true);
          ElectronTunnelSpot.setAtTop(callerAddress, electronTunnelData.sibling, true);
        }
      }
    } else {
      if (aboveEntity != 0) {
        if (getCAVoxelType(aboveEntity) == ElectronVoxelID) {
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

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    // TODO: Remove values from ElectronTunnelSpot
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ElectronVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();

    return
      IWorld(_world()).ca_ElectronSystem_eventHandlerElectron(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();

    return
      IWorld(_world()).ca_ElectronSystem_neighbourEventHandlerElectron(
        callerAddress,
        neighbourEntityId,
        centerEntityId
      );
  }
}
