// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { BuildEvent } from "@tenet-base-world/src/prototypes/BuildEvent.sol";
import { BuildEventData } from "@tenet-base-world/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { OwnedBy, VoxelType, WorldConfig } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { min } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { BuildWorldEventData } from "@tenet-world/src/Types.sol";
import { onBuild } from "@tenet-simulator/src/CallUtils.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

contract BuildSystem is BuildEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function processCAEvents(EntityEventData[] memory entitiesEventData) internal override {
    IWorld(_world()).caEventsHandler(entitiesEventData);
  }

  function emptyVoxelId() internal pure override returns (bytes32) {
    return AirVoxelID;
  }

  // Called by users
  function buildWithAgent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory agentEntity,
    bytes4 mindSelector
  ) public returns (VoxelEntity memory) {
    BuildWorldEventData memory buildEventData = BuildWorldEventData({ agentEntity: agentEntity });
    return
      build(
        voxelTypeId,
        coord,
        abi.encode(BuildEventData({ mindSelector: mindSelector, worldData: abi.encode(buildEventData) }))
      );
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal override {
    super.preRunCA(caAddress, voxelTypeId, coord, eventVoxelEntity, eventData);
    // Call simulator mass change
    uint256 bodyMass = VoxelTypeRegistry.getMass(IStore(REGISTRY_ADDRESS), voxelTypeId);
    BuildEventData memory buildEventData = abi.decode(eventData, (BuildEventData));
    BuildWorldEventData memory buildWorldEventData = abi.decode(buildEventData.worldData, (BuildWorldEventData));
    onBuild(SIMULATOR_ADDRESS, buildWorldEventData.agentEntity, eventVoxelEntity, coord, bodyMass);
  }
}
