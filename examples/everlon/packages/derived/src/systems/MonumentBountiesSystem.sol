// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

import { ObjectTypeRegistry, ObjectTypeRegistryTableId } from "@tenet-registry/src/codegen/tables/ObjectTypeRegistry.sol";
import { MonumentBounties, MonumentBountiesData, MonumentBountiesTableId } from "@tenet-derived/src/codegen/Tables.sol";

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
import { REGISTRY_ADDRESS } from "@tenet-derived/src/Constants.sol";

contract MonumentBountiesSystem is System {
  function addBounty(
    uint256 bountyAmount,
    bytes32[] memory objectTypeIds,
    VoxelCoord[] memory relativePositions,
    string memory name,
    string memory description
  ) public {
    require(bountyAmount > 0, "MonumentBountiesSystem: Bounty amount must be greater than 0");
    require(bytes(name).length > 0, "MonumentBountiesSystem: Name must be non-empty");

    require(objectTypeIds.length > 0, "MonumentBountiesSystem: Must specify at least one object type ID");
    require(
      objectTypeIds.length == relativePositions.length,
      "MonumentBountiesSystem: Number of object type IDs must match number of relative positions"
    );
    for (uint256 i = 0; i < objectTypeIds.length; i++) {
      require(
        hasKey(
          IStore(REGISTRY_ADDRESS),
          ObjectTypeRegistryTableId,
          ObjectTypeRegistry.encodeKeyTuple(objectTypeIds[i])
        ),
        "MonumentBountiesSystem: Object type ID has not been registered"
      );
    }

    bytes32 bountyId = getUniqueEntity();
    MonumentBounties.set(
      bountyId,
      MonumentBountiesData({
        creator: _msgSender(),
        bountyAmount: bountyAmount,
        claimedBy: address(0),
        objectTypeIds: objectTypeIds,
        relativePositions: abi.encode(relativePositions),
        name: name,
        description: description
      })
    );
  }

  function claimBounty() public {}
}
