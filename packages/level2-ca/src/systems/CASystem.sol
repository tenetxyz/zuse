// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { CAVoxelInteractionConfig, CAVoxelConfig, CAVoxelConfigTableId, CAVoxelType, CAVoxelTypeData, CAPosition, CAPositionData, CAPositionTableId } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { EMPTY_ID } from "./LibTerrainSystem.sol";
import { getEntityAtCoord } from "@tenet-base-ca/src/Utils.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";

contract CASystem is System {
  function isVoxelTypeAllowed(bytes32 voxelTypeId) public view returns (bool) {
    return hasKey(CAVoxelConfigTableId, CAVoxelConfig.encodeKeyTuple(voxelTypeId));
  }

  function enterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) public {
    address callerAddress = _msgSender();
    require(isVoxelTypeAllowed(voxelTypeId), "This voxel type is not allowed in this CA");

    // Check if we can set the voxel type at this position
    bytes32 existingEntity = getEntityAtCoord(IStore(_world()), callerAddress, coord);
    if (existingEntity != 0) {
      require(
        CAVoxelType.get(callerAddress, existingEntity).voxelTypeId == Level2AirVoxelID,
        "This position is already occupied by another voxel"
      );
    } else {
      CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
    }

    bytes4 voxelEnterWorldSelector = CAVoxelConfig.getEnterWorldSelector(voxelTypeId);
    safeCall(
      _world(),
      abi.encodeWithSelector(voxelEnterWorldSelector, callerAddress, coord, entity),
      "voxel enter world"
    );

    bytes32 voxelVariantId = getVoxelVariant(voxelTypeId, entity);
    CAVoxelType.set(callerAddress, entity, voxelTypeId, voxelVariantId);
  }

  function getVoxelVariant(bytes32 voxelTypeId, bytes32 entity) public returns (bytes32) {
    bytes4 voxelVariantSelector = CAVoxelConfig.getVoxelVariantSelector(voxelTypeId);
    bytes memory returnData = safeStaticCall(
      _world(),
      abi.encodeWithSelector(voxelVariantSelector, entity),
      "voxel variant selector"
    );
    return abi.decode(returnData, (bytes32));
  }

  function exitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) public {
    require(voxelTypeId != Level2AirVoxelID, "can not mine air");
    address callerAddress = _msgSender();
    if (!hasKey(CAPositionTableId, CAPosition.encodeKeyTuple(callerAddress, entity))) {
      // If there is no entity at this position, try mining the terrain voxel at this position
      bytes32 terrainVoxelTypeId = IWorld(_world()).getTerrainVoxel(coord);
      require(terrainVoxelTypeId != EMPTY_ID && terrainVoxelTypeId == voxelTypeId, "invalid terrain voxel type");
      CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
    }
    // set to Air
    bytes32 airVoxelVariantId = getVoxelVariant(Level2AirVoxelID, entity);
    CAVoxelType.set(callerAddress, entity, Level2AirVoxelID, airVoxelVariantId);

    bytes4 voxelExitWorldSelector = CAVoxelConfig.getExitWorldSelector(voxelTypeId);
    safeCall(
      _world(),
      abi.encodeWithSelector(voxelExitWorldSelector, callerAddress, coord, entity),
      "voxel exit world"
    );
  }

  function runInteraction(
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32[] memory changedEntities) {
    address callerAddress = _msgSender();

    changedEntities = new bytes32[](neighbourEntityIds.length + 1);

    bytes4[] memory interactionSelectors = CAVoxelInteractionConfig.get();
    for (uint256 i = 0; i < interactionSelectors.length; i++) {
      bytes4 interactionSelector = interactionSelectors[i];
      bytes memory returnData = safeCall(
        _world(),
        abi.encodeWithSelector(
          interactionSelector,
          callerAddress,
          interactEntity,
          neighbourEntityIds,
          childEntityIds,
          parentEntity
        ),
        "voxel interaction selector"
      );
      (bytes32 changedCenterEntityId, bytes32[] memory changedNeighbourEntityIds) = abi.decode(
        returnData,
        (bytes32, bytes32[])
      );

      if (changedEntities[0] == 0) {
        changedEntities[0] = changedCenterEntityId;
      }
      for (uint256 j = 0; j < changedNeighbourEntityIds.length; j++) {
        if (changedEntities[j + 1] == 0) {
          changedEntities[j + 1] = changedNeighbourEntityIds[i];
        }
      }
    }
  }
}
