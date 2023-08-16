// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { CA_ENTER_WORLD_SIG, CA_EXIT_WORLD_SIG, CA_RUN_INTERACTION_SIG, CA_ACTIVATE_BODY_SIG, CA_REGISTER_BODY_SIG, CA_MOVE_WORLD_SIG } from "@tenet-base-ca/src/Constants.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";

function mineWorld(address callerAddress, bytes32 bodyTypeId, VoxelCoord memory coord) returns (bytes memory) {
  return
    safeCall(
      callerAddress,
      abi.encodeWithSignature("mineBodyType(bytes32,(int32,int32,int32),bool,bool)", bodyTypeId, coord, true, false),
      string(abi.encode("mineBodyType ", bodyTypeId, " ", coord))
    );
}

function buildWorld(address callerAddress, bytes32 bodyTypeId, VoxelCoord memory coord) returns (bytes memory) {
  return
    safeCall(
      callerAddress,
      abi.encodeWithSignature("buildBodyType(bytes32,(int32,int32,int32),bool,bool)", bodyTypeId, coord, true, false),
      string(abi.encode("buildBodyType ", bodyTypeId, " ", coord))
    );
}

function moveWorld(
  address callerAddress,
  bytes32 bodyTypeId,
  VoxelCoord memory oldCoord,
  VoxelCoord memory newCoord
) returns (bytes memory) {
  return
    safeCall(
      callerAddress,
      abi.encodeWithSignature(
        "moveBodyType(bytes32,(int32,int32,int32),(int32,int32,int32),bool,bool)",
        bodyTypeId,
        oldCoord,
        newCoord,
        true,
        false
      ),
      string(abi.encode("moveBodyType ", bodyTypeId, " ", oldCoord, " ", newCoord))
    );
}

function enterWorld(
  address caAddress,
  bytes32 bodyTypeId,
  bytes4 mindSelector,
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
        bodyTypeId,
        mindSelector,
        coord,
        entity,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      ),
      string(
        abi.encode(
          "enterWorld ",
          bodyTypeId,
          " ",
          mindSelector,
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
  bytes32 bodyTypeId,
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
        bodyTypeId,
        coord,
        entity,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      ),
      string(
        abi.encode(
          "exitWorld ",
          bodyTypeId,
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

function moveLayer(
  address caAddress,
  bytes32 bodyTypeId,
  VoxelCoord memory oldCoord,
  VoxelCoord memory newCoord,
  bytes32 entity,
  bytes32[] memory neighbourEntityIds,
  bytes32[] memory childEntityIds,
  bytes32 parentEntity
) returns (bytes memory) {
  return
    safeCall(
      caAddress,
      abi.encodeWithSignature(
        CA_MOVE_WORLD_SIG,
        bodyTypeId,
        oldCoord,
        newCoord,
        entity,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      ),
      string(
        abi.encode(
          "moveWorld ",
          bodyTypeId,
          " ",
          oldCoord,
          " ",
          newCoord,
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
  bytes4 interactionSelector,
  bytes32 entity,
  bytes32[] memory neighbourEntityIds,
  bytes32[] memory childEntityIds,
  bytes32 parentEntity
) returns (bytes memory) {
  return
    safeCall(
      caAddress,
      abi.encodeWithSignature(
        CA_RUN_INTERACTION_SIG,
        interactionSelector,
        entity,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      ),
      string(
        abi.encode(
          "runInteraction ",
          interactionSelector,
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

function activateBody(address caAddress, bytes32 entity) returns (bytes memory) {
  return
    safeCall(
      caAddress,
      abi.encodeWithSignature(CA_ACTIVATE_BODY_SIG, entity),
      string(abi.encode("activateBody ", entity))
    );
}

function getBodyTypeFromCaller(address callerAddress, uint32 scale, bytes32 entity) view returns (bytes32) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("getBodyTypeId(uint32,bytes32)", scale, entity),
    "getBodyTypeId"
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

function registerCABodyType(address caAddress, bytes32 bodyTypeId) returns (bytes memory) {
  return
    safeCall(
      caAddress,
      abi.encodeWithSignature(CA_REGISTER_BODY_SIG, bodyTypeId),
      string(abi.encode("registerBodyType ", bodyTypeId))
    );
}
