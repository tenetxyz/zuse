// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-ca/src/prototypes/AgentType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, BuilderVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelEntity, BodySimData, CAEventData, CAEventType, SimEventData, SimTable, VoxelCoord, VoxelSelectors, InteractionSelector, ComponentDef, RangeComponent, StateComponent, ComponentType } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { getCAEntityAtCoord, getCAVoxelType, caEntityToEntity, getCAEntityPositionStrict, getCAEntityIsAgent } from "@tenet-base-ca/src/Utils.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { uint256ToNegativeInt256, uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { getEntitySimData } from "@tenet-level1-ca/src/Utils.sol";
import { getMooreNeighbourEntities } from "@tenet-base-ca/src/CallUtils.sol";
import { entityArrayToCAEntityArray } from "@tenet-base-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";

bytes32 constant BuilderVoxelVariantID = bytes32(keccak256("builder"));
string constant BuilderTexture = "bafkreihpdljsgdltghxehq4cebngtugfj3pduucijxcrvcla4hoy34f7vq";

contract BuilderAgentSystem is AgentType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory builderVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, BuilderVoxelVariantID, builderVariant);

    bytes32[] memory builderChildVoxelTypes = new bytes32[](1);
    builderChildVoxelTypes[0] = BuilderVoxelID;
    bytes32 baseVoxelTypeId = BuilderVoxelID;

    ComponentDef[] memory componentDefs = new ComponentDef[](0);

    registerVoxelType(
      REGISTRY_ADDRESS,
      "Builder",
      BuilderVoxelID,
      baseVoxelTypeId,
      builderChildVoxelTypes,
      builderChildVoxelTypes,
      BuilderVoxelVariantID,
      VoxelSelectors({
        enterWorldSelector: IWorld(world).ca_BuilderAgentSyst_enterWorld.selector,
        exitWorldSelector: IWorld(world).ca_BuilderAgentSyst_exitWorld.selector,
        voxelVariantSelector: IWorld(world).ca_BuilderAgentSyst_variantSelector.selector,
        activateSelector: IWorld(world).ca_BuilderAgentSyst_activate.selector,
        onNewNeighbourSelector: IWorld(world).ca_BuilderAgentSyst_neighbourEventHandler.selector,
        interactionSelectors: getInteractionSelectors()
      }),
      abi.encode(componentDefs),
      1
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
    return BuilderVoxelVariantID;
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
      interactionSelector: IWorld(_world()).ca_BuilderAgentSyst_defaultEventHandler.selector,
      interactionName: "Default",
      interactionDescription: ""
    });
    voxelInteractionSelectors[1] = InteractionSelector({
      interactionSelector: IWorld(_world()).ca_BuilderAgentSyst_slowDownEventHandler.selector,
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
  ) public returns (bool, bytes memory) {}
}
