// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-ca/src/prototypes/AgentType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, RunnerVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelEntity, BodySimData, CAEventData, CAEventType, SimEventData, SimTable, VoxelCoord, VoxelSelectors, InteractionSelector, ComponentDef, RangeComponent, StateComponent, ComponentType } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { getCAEntityAtCoord, getCAVoxelType, caEntityToEntity, getCAEntityPositionStrict, getCAEntityIsAgent } from "@tenet-base-ca/src/Utils.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { uint256ToNegativeInt256, uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { getEntitySimData, stopEvent } from "@tenet-level1-ca/src/Utils.sol";
import { getMooreNeighbourEntities } from "@tenet-base-ca/src/CallUtils.sol";
import { entityArrayToCAEntityArray } from "@tenet-base-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";

bytes32 constant RunnerVoxelVariantID = bytes32(keccak256("runner"));

contract RunnerAgentSystem is AgentType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory runnerVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, RunnerVoxelVariantID, runnerVariant);

    bytes32[] memory runnerChildVoxelTypes = new bytes32[](1);
    runnerChildVoxelTypes[0] = RunnerVoxelID;
    bytes32 baseVoxelTypeId = RunnerVoxelID;

    ComponentDef[] memory componentDefs = new ComponentDef[](0);

    registerVoxelType(
      REGISTRY_ADDRESS,
      "Runner",
      RunnerVoxelID,
      baseVoxelTypeId,
      runnerChildVoxelTypes,
      runnerChildVoxelTypes,
      RunnerVoxelVariantID,
      VoxelSelectors({
        enterWorldSelector: IWorld(world).ca_RunnerAgentSyste_enterWorld.selector,
        exitWorldSelector: IWorld(world).ca_RunnerAgentSyste_exitWorld.selector,
        voxelVariantSelector: IWorld(world).ca_RunnerAgentSyste_variantSelector.selector,
        activateSelector: IWorld(world).ca_RunnerAgentSyste_activate.selector,
        onNewNeighbourSelector: IWorld(world).ca_RunnerAgentSyste_neighbourEventHandler.selector,
        interactionSelectors: getInteractionSelectors()
      }),
      abi.encode(componentDefs),
      6
    );
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RunnerVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, bytes memory) {}

  function getInteractionSelectors() public override returns (InteractionSelector[] memory) {
    // Agent entities must have more than one interaction to be considered an agent
    InteractionSelector[] memory voxelInteractionSelectors = new InteractionSelector[](2);
    voxelInteractionSelectors[0] = InteractionSelector({
      interactionSelector: IWorld(_world()).ca_RunnerAgentSyste_defaultEventHandler.selector,
      interactionName: "Default",
      interactionDescription: ""
    });
    voxelInteractionSelectors[1] = InteractionSelector({
      interactionSelector: IWorld(_world()).ca_RunnerAgentSyste_slowDownEventHandler.selector,
      interactionName: "Slow Down",
      interactionDescription: ""
    });
    return voxelInteractionSelectors;
  }

  function defaultEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {}

  function slowDownEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    BodySimData memory entitySimData = getEntitySimData(centerEntityId);
    VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), centerEntityId);
    return (false, stopEvent(centerEntityId, coord, entitySimData));
  }
}
