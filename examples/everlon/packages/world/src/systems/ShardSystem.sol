// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { ISimInitSystem } from "@tenet-base-simulator/src/codegen/world/ISimInitSystem.sol";
import { Position, ObjectType, ObjectEntity, Faucet, FaucetData, OwnedBy, Shard, ShardData, ShardTableId } from "@tenet-world/src/codegen/Tables.sol";

import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { SIMULATOR_ADDRESS, SHARD_DIM, FaucetObjectID } from "@tenet-world/src/Constants.sol";

contract ShardSystem is System {
  function claimShard(
    VoxelCoord memory coordInShard,
    address contractAddress,
    bytes4 objectTypeIdSelector,
    bytes4 objectPropertiesSelector,
    VoxelCoord memory faucetAgentCoord
  ) public {
    VoxelCoord memory shardCoord = coordToShardCoord(coordInShard, SHARD_DIM);
    require(
      !hasKey(ShardTableId, Shard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)),
      "ShardSystem: Shard already claimed"
    );
    Shard.set(
      shardCoord.x,
      shardCoord.y,
      shardCoord.z,
      ShardData({
        claimer: tx.origin,
        contractAddress: contractAddress,
        objectTypeIdSelector: objectTypeIdSelector,
        objectPropertiesSelector: objectPropertiesSelector,
        totalGenMass: 0,
        totalGenEnergy: 0
      })
    );

    setFaucetAgent(faucetAgentCoord);
  }

  function setFaucetAgent(VoxelCoord memory coord) internal {
    bytes32 objectTypeId = FaucetObjectID;

    // Create entity
    bytes32 eventEntityId = getUniqueEntity();
    Position.set(eventEntityId, coord.x, coord.y, coord.z);
    ObjectType.set(eventEntityId, objectTypeId);
    bytes32 objectEntityId = getUniqueEntity();
    ObjectEntity.set(eventEntityId, objectEntityId);

    // This will place the agent, so it will check if the object there is air
    ObjectProperties memory faucetProperties = IWorld(_world()).enterWorld(objectTypeId, coord, objectEntityId);
    ISimInitSystem(SIMULATOR_ADDRESS).initObject(objectEntityId, faucetProperties);

    // TODO: Make this the world contract, so that FaucetSystem can build using it
    OwnedBy.set(objectEntityId, address(0)); // Set owner to 0 so no one can claim it
    Faucet.set(objectEntityId, FaucetData({ claimers: new address[](0), claimerAmounts: new uint256[](0) }));
  }
}
