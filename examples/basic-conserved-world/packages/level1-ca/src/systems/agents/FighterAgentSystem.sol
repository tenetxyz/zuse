// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-ca/src/prototypes/AgentType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, FighterVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelEntity, BodySimData, CAEventData, CAEventType, SimEventData, SimTable, VoxelCoord, VoxelSelectors, InteractionSelector, ComponentDef, RangeComponent, StateComponent, ComponentType } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { getCAEntityAtCoord, getCAVoxelType, caEntityToEntity, getCAEntityPositionStrict, getCAEntityIsAgent } from "@tenet-base-ca/src/Utils.sol";
import { AirVoxelID, STARTING_STAMINA_FROM_FAUCET } from "@tenet-level1-ca/src/Constants.sol";
import { uint256ToNegativeInt256, uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { getEntitySimData } from "@tenet-level1-ca/src/Utils.sol";

bytes32 constant FighterVoxelVariantID = bytes32(keccak256("fighter"));
string constant FighterTexture = "bafkreihpdljsgdltghxehq4cebngtugfj3pduucijxcrvcla4hoy34f7vq";

contract FighterAgentSystem is AgentType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory fighterVariant;
    fighterVariant.blockType = NoaBlockType.MESH;
    fighterVariant.opaque = false;
    fighterVariant.solid = false;
    fighterVariant.frames = 1;
    string[] memory fighterMaterials = new string[](1);
    fighterMaterials[0] = FighterTexture;
    fighterVariant.materials = abi.encode(fighterMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, FighterVoxelVariantID, fighterVariant);

    bytes32[] memory fighterChildVoxelTypes = new bytes32[](1);
    fighterChildVoxelTypes[0] = FighterVoxelID;
    bytes32 baseVoxelTypeId = FighterVoxelID;

    ComponentDef[] memory componentDefs = new ComponentDef[](3);
    componentDefs[0] = ComponentDef(
      ComponentType.RANGE,
      "Health",
      abi.encode(RangeComponent({ rangeStart: 0, rangeEnd: 100 }))
    );
    componentDefs[1] = ComponentDef(
      ComponentType.RANGE,
      "Stamina",
      abi.encode(RangeComponent({ rangeStart: 0, rangeEnd: 200 }))
    );
    string[] memory states = new string[](3);
    states[0] = "Running";
    states[1] = "Defending";
    states[2] = "Attacking";
    componentDefs[2] = ComponentDef(ComponentType.STATE, "State", abi.encode(StateComponent(states)));

    registerVoxelType(
      REGISTRY_ADDRESS,
      "Fighter",
      FighterVoxelID,
      baseVoxelTypeId,
      fighterChildVoxelTypes,
      fighterChildVoxelTypes,
      FighterVoxelVariantID,
      VoxelSelectors({
        enterWorldSelector: IWorld(world).ca_FighterAgentSyst_enterWorld.selector,
        exitWorldSelector: IWorld(world).ca_FighterAgentSyst_exitWorld.selector,
        voxelVariantSelector: IWorld(world).ca_FighterAgentSyst_variantSelector.selector,
        activateSelector: IWorld(world).ca_FighterAgentSyst_activate.selector,
        onNewNeighbourSelector: IWorld(world).ca_FighterAgentSyst_neighbourEventHandler.selector,
        interactionSelectors: getInteractionSelectors()
      }),
      abi.encode(componentDefs),
      5
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
    return FighterVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, bytes memory) {}

  function getInteractionSelectors() public override returns (InteractionSelector[] memory) {
    InteractionSelector[] memory voxelInteractionSelectors = new InteractionSelector[](3);
    voxelInteractionSelectors[0] = InteractionSelector({
      interactionSelector: IWorld(_world()).ca_FighterAgentSyst_giveStaminaEventHandler.selector,
      interactionName: "Give Stamina",
      interactionDescription: ""
    });
    return voxelInteractionSelectors;
  }

  function giveStaminaEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);
    BodySimData memory entitySimData = getEntitySimData(centerEntityId);
    uint256 currentStamina = entitySimData.stamina;
    if (currentStamina == 0) {
      return (false, abi.encode(allCAEventData));
    }
    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (neighbourEntityIds[i] == 0) {
        continue;
      }
      if (!getCAEntityIsAgent(REGISTRY_ADDRESS, neighbourEntityIds[i])) {
        continue;
      }
      BodySimData memory neighbourSimData = getEntitySimData(neighbourEntityIds[i]);
      if (neighbourSimData.stamina == 0) {
        uint256 transferStamina = STARTING_STAMINA_FROM_FAUCET;
        if (currentStamina < transferStamina) {
          break;
        }
        currentStamina -= transferStamina;
        VoxelEntity memory targetEntity = VoxelEntity({ scale: 1, entityId: caEntityToEntity(neighbourEntityIds[i]) });
        VoxelCoord memory targetCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
        SimEventData memory eventData = SimEventData({
          senderTable: SimTable.Stamina,
          senderValue: abi.encode(uint256ToNegativeInt256(transferStamina)),
          targetEntity: targetEntity,
          targetCoord: targetCoord,
          targetTable: SimTable.Stamina,
          targetValue: abi.encode(uint256ToInt256(transferStamina))
        });
        allCAEventData[i] = CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(eventData) });
      }
    }
    return (false, abi.encode(allCAEventData));
  }
}
