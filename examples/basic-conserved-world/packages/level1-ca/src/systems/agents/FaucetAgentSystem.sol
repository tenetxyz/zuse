// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-ca/src/prototypes/AgentType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, FaucetVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelEntity, BodySimData, CAEventData, CAEventType, SimEventData, SimTable, VoxelCoord, VoxelSelectors, InteractionSelector, ComponentDef, RangeComponent, StateComponent, ComponentType } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { getCAEntityAtCoord, getCAVoxelType, caEntityToEntity, getCAEntityPositionStrict, getCAEntityIsAgent } from "@tenet-base-ca/src/Utils.sol";
import { AirVoxelID, STARTING_STAMINA_FROM_FAUCET } from "@tenet-level1-ca/src/Constants.sol";
import { uint256ToNegativeInt256, uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { getEntitySimData } from "@tenet-level1-ca/src/Utils.sol";
import { getMooreNeighbourEntities } from "@tenet-base-ca/src/CallUtils.sol";
import { entityArrayToCAEntityArray } from "@tenet-base-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";

bytes32 constant FaucetVoxelVariantID = bytes32(keccak256("faucet"));
string constant FaucetTexture = "bafkreihpdljsgdltghxehq4cebngtugfj3pduucijxcrvcla4hoy34f7vq";

contract FaucetAgentSystem is AgentType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory faucetVariant;
    faucetVariant.blockType = NoaBlockType.MESH;
    faucetVariant.opaque = false;
    faucetVariant.solid = false;
    faucetVariant.frames = 1;
    string[] memory faucetMaterials = new string[](1);
    faucetMaterials[0] = FaucetTexture;
    faucetVariant.materials = abi.encode(faucetMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, FaucetVoxelVariantID, faucetVariant);

    bytes32[] memory faucetChildVoxelTypes = new bytes32[](1);
    faucetChildVoxelTypes[0] = FaucetVoxelID;
    bytes32 baseVoxelTypeId = FaucetVoxelID;

    ComponentDef[] memory componentDefs = new ComponentDef[](0);

    registerVoxelType(
      REGISTRY_ADDRESS,
      "Faucet",
      FaucetVoxelID,
      baseVoxelTypeId,
      faucetChildVoxelTypes,
      faucetChildVoxelTypes,
      FaucetVoxelVariantID,
      VoxelSelectors({
        enterWorldSelector: IWorld(world).ca_FaucetAgentSyste_enterWorld.selector,
        exitWorldSelector: IWorld(world).ca_FaucetAgentSyste_exitWorld.selector,
        voxelVariantSelector: IWorld(world).ca_FaucetAgentSyste_variantSelector.selector,
        activateSelector: IWorld(world).ca_FaucetAgentSyste_activate.selector,
        onNewNeighbourSelector: IWorld(world).ca_FaucetAgentSyste_neighbourEventHandler.selector,
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
    return FaucetVoxelVariantID;
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
      interactionSelector: IWorld(_world()).ca_FaucetAgentSyste_defaultEventHandler.selector,
      interactionName: "Default",
      interactionDescription: ""
    });
    voxelInteractionSelectors[1] = InteractionSelector({
      interactionSelector: IWorld(_world()).ca_FaucetAgentSyste_giveStaminaEventHandler.selector,
      interactionName: "Give Stamina",
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

  function giveStaminaEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    BodySimData memory entitySimData = getEntitySimData(centerEntityId);
    uint256 currentStamina = entitySimData.stamina;
    if (currentStamina == 0) {
      return (false, abi.encode(new bytes(0)));
    }
    (bytes32[] memory mooreNeighbourEntities, ) = getMooreNeighbourEntities(centerEntityId, 1);
    CAEventData[] memory allCAEventData = new CAEventData[](mooreNeighbourEntities.length);
    bytes32[] memory mooreNeighbourCAEntities = entityArrayToCAEntityArray(callerAddress, mooreNeighbourEntities);
    for (uint i = 0; i < mooreNeighbourCAEntities.length; i++) {
      if (uint256(mooreNeighbourCAEntities[i]) == 0) {
        continue;
      }
      if (!getCAEntityIsAgent(REGISTRY_ADDRESS, mooreNeighbourCAEntities[i])) {
        continue;
      }
      BodySimData memory neighbourSimData = getEntitySimData(mooreNeighbourCAEntities[i]);
      if (neighbourSimData.stamina == 0) {
        uint256 transferStamina = STARTING_STAMINA_FROM_FAUCET;
        if (currentStamina < transferStamina) {
          break;
        }
        currentStamina -= transferStamina;
        VoxelEntity memory targetEntity = VoxelEntity({
          scale: 1,
          entityId: caEntityToEntity(mooreNeighbourCAEntities[i])
        });
        VoxelCoord memory targetCoord = getCAEntityPositionStrict(IStore(_world()), mooreNeighbourCAEntities[i]);
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
