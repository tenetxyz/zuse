// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { CA_ENTER_WORLD_SIG, CA_EXIT_WORLD_SIG, CA_RUN_INTERACTION_SIG, CA_ACTIVATE_VOXEL_SIG } from "./Constants.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";

function mineWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) returns (bytes memory) {
  return
    safeCall(
      callerAddress,
      abi.encodeWithSignature("mineVoxelType(bytes32,(int32,int32,int32),bool)", voxelTypeId, coord, true),
      string(abi.encode("mine ", voxelTypeId, " ", coord))
    );
}

function buildWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) returns (bytes memory) {
  return
    safeCall(
      callerAddress,
      abi.encodeWithSignature("buildVoxelType(bytes32,(int32,int32,int32),bool,bool)", voxelTypeId, coord, true, false),
      string(abi.encode("buildVoxelType ", voxelTypeId, " ", coord))
    );
}

function enterWorld(
  address caAddress,
  bytes32 voxelTypeId,
  VoxelCoord memory coord,
  bytes32 entity,
  bytes32[] memory neighbourEntityIds,
  bytes32[] memory childEntityIds,
  bytes32 parentEntity
) returns (bytes memory) {
  return
    safeCall(
      caAddress,
      abi.encodeWithSignature(
        CA_ENTER_WORLD_SIG,
        voxelTypeId,
        coord,
        entity,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      ),
      string(
        abi.encode(
          "enterWorld ",
          voxelTypeId,
          " ",
          coord,
          " ",
          entity,
          " ",
          neighbourEntityIds,
          " ",
          childEntityIds,
          " ",
          parentEntity
        )
      )
    );
}

function exitWorld(
  address caAddress,
  bytes32 voxelTypeId,
  VoxelCoord memory coord,
  bytes32 entity,
  bytes32[] memory neighbourEntityIds,
  bytes32[] memory childEntityIds,
  bytes32 parentEntity
) returns (bytes memory) {
  return
    safeCall(
      caAddress,
      abi.encodeWithSignature(
        CA_EXIT_WORLD_SIG,
        voxelTypeId,
        coord,
        entity,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      ),
      string(
        abi.encode(
          "exitWorld ",
          voxelTypeId,
          " ",
          coord,
          " ",
          entity,
          " ",
          neighbourEntityIds,
          " ",
          childEntityIds,
          " ",
          parentEntity
        )
      )
    );
}

function runInteraction(
  address caAddress,
  bytes32 entity,
  bytes32[] memory neighbourEntityIds,
  bytes32[] memory childEntityIds,
  bytes32 parentEntity
) returns (bytes memory) {
  return
    safeCall(
      caAddress,
      abi.encodeWithSignature(CA_RUN_INTERACTION_SIG, entity, neighbourEntityIds, childEntityIds, parentEntity),
      string(abi.encode("runInteraction ", entity, " ", neighbourEntityIds, " ", childEntityIds, " ", parentEntity))
    );
}

function activateVoxel(address caAddress, bytes32 entity) returns (bytes memory) {
  return
    safeCall(
      caAddress,
      abi.encodeWithSignature(CA_ACTIVATE_VOXEL_SIG, entity),
      string(abi.encode("activateVoxel ", entity))
    );
}

function getVoxelTypeFromCaller(address callerAddress, uint32 scale, bytes32 entity) returns (bytes32) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("getVoxelTypeId(uint32,bytes32)", scale, entity),
    "getVoxelTypeId"
  );
  return abi.decode(returnData, (bytes32));
}

function getNeighbourEntitiesFromCaller(
  address callerAddress,
  uint32 scale,
  bytes32 entity
) returns (bytes32[] memory) {
  bytes memory returnData = safeCall(
    callerAddress,
    abi.encodeWithSignature("calculateNeighbourEntities(uint32,bytes32)", scale, entity),
    "calculateNeighbourEntities"
  );
  return abi.decode(returnData, (bytes32[]));
}

function getChildEntitiesFromCaller(address callerAddress, uint32 scale, bytes32 entity) returns (bytes32[] memory) {
  bytes memory returnData = safeCall(
    callerAddress,
    abi.encodeWithSignature("calculateChildEntities(uint32,bytes32)", scale, entity),
    "calculateChildEntities"
  );
  return abi.decode(returnData, (bytes32[]));
}

function getParentEntityFromCaller(address callerAddress, uint32 scale, bytes32 entity) returns (bytes32) {
  bytes memory returnData = safeCall(
    callerAddress,
    abi.encodeWithSignature("calculateParentEntity(uint32,bytes32)", scale, entity),
    "calculateParentEntity"
  );
  return abi.decode(returnData, (bytes32));
}
