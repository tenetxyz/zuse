// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelVariantsKey } from "../Types.sol";
import { OwnedBy, Position, PositionData, PositionTableId, VoxelType, VoxelTypeData, VoxelVariants, VoxelVariantsData, VoxelTypeRegistry } from "../codegen/Tables.sol";
import { AirID } from "../prototypes/Voxels.sol";
import { addressToEntityKey, updateVoxelVariant, increaseVoxelTypeSpawnCount, getEntitiesAtCoord } from "../Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { EMPTY_NAMESPACE, EMPTY_ID, TENET_NAMESPACE } from "../Constants.sol";

contract GravitySystem is System {
  // function checkIfShouldFall(VoxelVariantsData memory voxelTop, VoxelVariantsData voxelBottom) public returns (bool) {
  //   // check if the mass of the voxel is greater than the mass of the voxel below it
  //   return voxelTop.mass > voxelBottom.mass;
  // }

  function runGravity(bytes32 entity) public {
    PositionData memory currentPosition = Position.get(entity);
    VoxelTypeData memory currentVoxelTypeData = VoxelType.get(entity);
    VoxelVariantsData memory currentVoxelData = VoxelVariants.get(
      currentVoxelTypeData.voxelVariantNamespace,
      currentVoxelTypeData.voxelVariantId
    );

    // 1) check if the block below this block is lighter than this block, if so, move this block down and break that block
    VoxelTypeData memory belowVoxelTypeData;
    VoxelCoord memory belowPosition = VoxelCoord(currentPosition.x, currentPosition.y - 1, currentPosition.z);
    bytes32[] memory entityBelow = getEntitiesAtCoord(belowPosition);
    if (entityBelow.length == 0) {
      // get terrain voxel variant
      VoxelVariantsKey memory terrainVoxel = IWorld(_world()).tenet_LibTerrainSystem_getTerrainVoxel(belowPosition);
      require(
        terrainVoxel.voxelVariantNamespace != EMPTY_NAMESPACE && terrainVoxel.voxelVariantId != EMPTY_ID,
        "Terrain voxel does not exist"
      );
      belowVoxelTypeData = VoxelTypeData({
        voxelTypeNamespace: TENET_NAMESPACE,
        voxelTypeId: terrainVoxel.voxelVariantId,
        voxelVariantNamespace: terrainVoxel.voxelVariantNamespace,
        voxelVariantId: terrainVoxel.voxelVariantId
      });
    } else {
      // get entity voxel variant
      belowVoxelTypeData = VoxelType.get(entityBelow[0]);
    }

    VoxelVariantsData memory belowVoxelData = VoxelVariants.get(
      belowVoxelTypeData.voxelVariantNamespace,
      belowVoxelTypeData.voxelVariantId
    );
    if (currentVoxelData.mass > belowVoxelData.mass) {
      // move this block down and break that block
      if (belowVoxelTypeData.voxelTypeId == AirID) {
        // if the block below is air, then we can just move this block down
        IWorld(_world()).tenet_MineSystem_mine(
          currentPosition,
          currentVoxelTypeData.voxelTypeNamespace,
          currentVoxelTypeData.voxelTypeId,
          currentVoxelTypeData.voxelVariantNamespace,
          currentVoxelTypeData.voxelVariantId
        );
        IWorld(_world()).tenet_BuildSystem_build(entity, belowPosition);
      } else {
        // if the block below is not air, then we need to break that block and move this block down
        IWorld(_world()).tenet_MineSystem_mine(
          belowPosition,
          belowVoxelTypeData.voxelTypeNamespace,
          belowVoxelTypeData.voxelTypeId,
          belowVoxelTypeData.voxelVariantNamespace,
          belowVoxelTypeData.voxelVariantId
        );
      }
    }

    // 2) check if the block above this block is heavier than this block, if so, break this block and move that block down
    VoxelTypeData memory aboveVoxelTypeData;
    VoxelVariantsData memory aboveVoxelData;
    VoxelCoord memory abovePosition = VoxelCoord(currentPosition.x, currentPosition.y + 1, currentPosition.z);
    bytes32[] memory entityAbove = getEntitiesAtCoord(abovePosition);
    if (entityAbove.length == 0) {
      // get terrain voxel variant
      // get terrain voxel variant
      VoxelVariantsKey memory terrainVoxel = IWorld(_world()).tenet_LibTerrainSystem_getTerrainVoxel(abovePosition);
      require(
        terrainVoxel.voxelVariantNamespace != EMPTY_NAMESPACE && terrainVoxel.voxelVariantId != EMPTY_ID,
        "Terrain voxel does not exist"
      );
      aboveVoxelData = VoxelTypeData({
        voxelTypeNamespace: TENET_NAMESPACE,
        voxelTypeId: terrainVoxel.voxelVariantId,
        voxelVariantNamespace: terrainVoxel.voxelVariantNamespace,
        voxelVariantId: terrainVoxel.voxelVariantId
      });
    } else {
      // get entity voxel variant
      aboveVoxelTypeData = VoxelType.get(entityAbove[0]);
    }
    aboveVoxelData = VoxelVariants.get(aboveVoxelTypeData.voxelVariantNamespace, aboveVoxelTypeData.voxelVariantId);
    if (currentVoxelData.mass < aboveVoxelData.mass) {
      if (currentVoxelTypeData.voxelTypeId == AirID) {
        // if the we are air, then we can just move the above block down
        IWorld(_world()).tenet_MineSystem_mine(
          abovePosition,
          aboveVoxelTypeData.voxelTypeNamespace,
          aboveVoxelTypeData.voxelTypeId,
          aboveVoxelTypeData.voxelVariantNamespace,
          aboveVoxelTypeData.voxelVariantId
        );
        IWorld(_world()).tenet_BuildSystem_build(entityAbove[0], currentPosition);
      } else {
        // if we are not air, then we need to break this block and move the above block down
        IWorld(_world()).tenet_MineSystem_mine(
          currentPosition,
          currentVoxelTypeData.voxelTypeNamespace,
          currentVoxelTypeData.voxelTypeId,
          currentVoxelTypeData.voxelVariantNamespace,
          currentVoxelTypeData.voxelVariantId
        );
      }
    }
  }
}
