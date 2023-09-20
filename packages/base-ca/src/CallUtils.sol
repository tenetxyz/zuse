// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { CA_GET_MIND_SELECTOR_SIG, CA_ENTER_WORLD_SIG, CA_EXIT_WORLD_SIG, CA_RUN_INTERACTION_SIG, CA_ACTIVATE_VOXEL_SIG, CA_REGISTER_VOXEL_SIG, CA_MOVE_WORLD_SIG } from "@tenet-base-ca/src/Constants.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";

function mineWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) returns (bytes memory) {
  return
    safeCall(
      callerAddress,
      abi.encodeWithSignature("mineVoxelType(bytes32,(int32,int32,int32),bool,bool)", voxelTypeId, coord, true, false),
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

function moveWorld(
  address callerAddress,
  bytes32 voxelTypeId,
  VoxelCoord memory oldCoord,
  VoxelCoord memory newCoord
) returns (bytes memory) {
  return
    safeCall(
      callerAddress,
      abi.encodeWithSignature(
        "moveVoxelType(bytes32,(int32,int32,int32),(int32,int32,int32),bool,bool)",
        voxelTypeId,
        oldCoord,
        newCoord,
        true,
        false
      ),
      string(abi.encode("moveVoxelType ", voxelTypeId, " ", oldCoord, " ", newCoord))
    );
}

function getCAMindSelector(address caAddress, bytes32 entity) view returns (bytes4) {
  bytes memory result = safeStaticCall(
    caAddress,
    abi.encodeWithSignature(CA_GET_MIND_SELECTOR_SIG, entity),
    string(abi.encode("getMindSelector ", entity))
  );
  return abi.decode(result, (bytes4));
}

function enterWorld(
  address caAddress,
  bytes32 voxelTypeId,
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
        voxelTypeId,
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
          voxelTypeId,
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

function moveLayer(
  address caAddress,
  bytes32 voxelTypeId,
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
        voxelTypeId,
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
          voxelTypeId,
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

function activateVoxel(address caAddress, bytes32 entity) returns (bytes memory) {
  return
    safeCall(
      caAddress,
      abi.encodeWithSignature(CA_ACTIVATE_VOXEL_SIG, entity),
      string(abi.encode("activateVoxel ", entity))
    );
}

function getVoxelTypeFromCaller(address callerAddress, VoxelEntity memory entity) view returns (bytes32) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("getVoxelTypeId((uint32,bytes32))", entity),
    "getVoxelTypeId"
  );
  return abi.decode(returnData, (bytes32));
}

function shouldRunInteractionForNeighbour(
  address callerAddress,
  VoxelEntity memory originEntity,
  VoxelEntity memory neighbourEntity
) view returns (bool) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature(
      "shouldRunInteractionForNeighbour((uint32,bytes32),(uint32,bytes32))",
      originEntity,
      neighbourEntity
    ),
    "shouldRunInteractionForNeighbour"
  );
  return abi.decode(returnData, (bool));
}

function getNeighbourEntitiesFromCaller(address callerAddress, VoxelEntity memory entity) returns (bytes32[] memory) {
  bytes memory returnData = safeCall(
    callerAddress,
    abi.encodeWithSignature("calculateNeighbourEntities((uint32,bytes32))", entity),
    "calculateNeighbourEntities"
  );
  return abi.decode(returnData, (bytes32[]));
}

function getChildEntitiesFromCaller(address callerAddress, VoxelEntity memory entity) returns (bytes32[] memory) {
  bytes memory returnData = safeCall(
    callerAddress,
    abi.encodeWithSignature("calculateChildEntities((uint32,bytes32))", entity),
    "calculateChildEntities"
  );
  return abi.decode(returnData, (bytes32[]));
}

function getParentEntityFromCaller(address callerAddress, VoxelEntity memory entity) returns (bytes32) {
  bytes memory returnData = safeCall(
    callerAddress,
    abi.encodeWithSignature("calculateParentEntity((uint32,bytes32))", entity),
    "calculateParentEntity"
  );
  return abi.decode(returnData, (bytes32));
}

function registerCAVoxelType(address caAddress, bytes32 voxelTypeId) returns (bytes memory) {
  return
    safeCall(
      caAddress,
      abi.encodeWithSignature(CA_REGISTER_VOXEL_SIG, voxelTypeId),
      string(abi.encode("registerVoxelType ", voxelTypeId))
    );
}
