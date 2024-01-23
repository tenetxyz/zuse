// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

import { MonumentClaimedArea, MonumentClaimedAreaData, MonumentClaimedAreaTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { MonumentToken, MonumentTokenTableId } from "@tenet-derived/src/codegen/Tables.sol";

import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { ObjectEntity, ObjectEntityTableId } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";

import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord } from "@tenet-base-world/src/Utils.sol";

import { WORLD_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int32ToUint32, uint32ToInt32 } from "@tenet-utils/src/TypeUtils.sol";
import { SHARD_DIM } from "@tenet-world/src/Constants.sol";

struct AreaLikes {
  int32 x;
  int32 y;
  int32 z;
  uint256 likes;
}

contract MonumentCASystem is System {
  // Note: we only support claiming 2D areas for now, ie all y values are ignored
  function claimMonumentsArea(
    bytes32 agentObjectEntityId,
    VoxelCoord memory lowerSouthwestCorner,
    VoxelCoord memory size,
    string memory displayName
  ) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    require(
      OwnedBy.get(worldStore, agentObjectEntityId) == _msgSender(),
      "MonumentCASystem: You do not own this agent"
    );
    VoxelCoord memory coord = getVoxelCoord(worldStore, agentObjectEntityId);

    // Check coord is within the area
    require(
      coord.x >= lowerSouthwestCorner.x &&
        coord.z >= lowerSouthwestCorner.z &&
        coord.x < lowerSouthwestCorner.x + size.x &&
        coord.z < lowerSouthwestCorner.z + size.z,
      "MonumentCASystem: Your agent is not within the selected area"
    );

    require(
      !hasKey(
        MonumentClaimedAreaTableId,
        MonumentClaimedArea.encodeKeyTuple(lowerSouthwestCorner.x, 0, lowerSouthwestCorner.z)
      ),
      "MonumentCASystem: This area is already claimed"
    );

    VoxelCoord memory topNortheastCorner = VoxelCoord(
      lowerSouthwestCorner.x + size.x,
      0,
      lowerSouthwestCorner.z + size.z
    );

    // Check if the area overlaps with another claimed area
    uint256 numClaimedAreas = requireNoOverlap(lowerSouthwestCorner, topNortheastCorner);

    // TODO: Add spam protection to make it so a user doesn't claim too many areas

    MonumentClaimedArea.set(
      lowerSouthwestCorner.x,
      0,
      lowerSouthwestCorner.z,
      MonumentClaimedAreaData({
        length: int32ToUint32(size.x),
        width: int32ToUint32(size.z),
        height: int32ToUint32(size.y),
        owner: _msgSender(),
        agentObjectEntityId: agentObjectEntityId,
        displayName: displayName
      })
    );
  }

  // TODO: Find a more gas efficient way to check for overlap, maybe use ZK proofs
  function requireNoOverlap(
    VoxelCoord memory lowerCorner,
    VoxelCoord memory upperCorner
  ) internal view returns (uint256) {
    bytes32[][] memory monumentsCAEntities = getKeysInTable(MonumentClaimedAreaTableId);
    for (uint i = 0; i < monumentsCAEntities.length; i++) {
      int32 x = int32(int256(uint256(monumentsCAEntities[i][0])));
      int32 y = int32(int256(uint256(monumentsCAEntities[i][1])));
      int32 z = int32(int256(uint256(monumentsCAEntities[i][2])));
      uint32 length = MonumentClaimedArea.getLength(x, y, z);
      uint32 width = MonumentClaimedArea.getWidth(x, y, z);
      VoxelCoord memory compareLowerCorner = VoxelCoord(x, y, z);
      VoxelCoord memory compareUpperCorner = VoxelCoord(x + uint32ToInt32(length), y, z + uint32ToInt32(width));
      // Check if the area overlaps with the claimed area
      if (
        !(upperCorner.x <= compareLowerCorner.x || // to the left of
          lowerCorner.x >= compareUpperCorner.x || // to the right of
          lowerCorner.z >= compareUpperCorner.z || // above
          upperCorner.z <= compareLowerCorner.z) // below
      ) {
        revert("MonumentCASystem: This area overlaps with another claimed area");
      }
    }
    return monumentsCAEntities.length;
  }
}
