// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-ca/src/prototypes/AgentType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, FarmerVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { VoxelEntity, BodySimData, CAEventData, CAEventType, SimEventData, SimTable, VoxelCoord, VoxelSelectors, InteractionSelector, ComponentDef, RangeComponent, StateComponent, ComponentType } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { getCAEntityAtCoord, getCAVoxelType, caEntityToEntity, getCAEntityPositionStrict, getCAEntityIsAgent } from "@tenet-base-ca/src/Utils.sol";
import { uint256ToNegativeInt256, uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { getMooreNeighbourEntities } from "@tenet-base-ca/src/CallUtils.sol";
import { entityArrayToCAEntityArray } from "@tenet-base-ca/src/Utils.sol";
import { Farmer } from "@tenet-pokemon-extension/src/codegen/tables/Farmer.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { console } from "forge-std/console.sol";
import { getEntitySimData, stopEvent } from "@tenet-level1-ca/src/Utils.sol";

bytes32 constant FarmerVoxelVariantID = bytes32(keccak256("farmer"));
string constant FarmerTexture = "bafkreihpdljsgdltghxehq4cebngtugfj3pduucijxcrvcla4hoy34f7vq";

contract FarmerAgentSystem is AgentType {
  function registerObject() public override {
    address world = _world();
    VoxelVariantsRegistryData memory farmerVariant;
    farmerVariant.blockType = NoaBlockType.MESH;
    farmerVariant.opaque = false;
    farmerVariant.solid = false;
    farmerVariant.frames = 1;
    string[] memory farmerMaterials = new string[](1);
    farmerMaterials[0] = FarmerTexture;
    farmerVariant.materials = abi.encode(farmerMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, FarmerVoxelVariantID, farmerVariant);

    bytes32[] memory farmerChildVoxeTypes = new bytes32[](1);
    farmerChildVoxeTypes[0] = FarmerVoxelID;
    bytes32 baseVoxelTypeId = FarmerVoxelID;

    ComponentDef[] memory componentDefs = new ComponentDef[](0);

    registerVoxelType(
      REGISTRY_ADDRESS,
      "Farmer",
      FarmerVoxelID,
      baseVoxelTypeId,
      farmerChildVoxeTypes,
      farmerChildVoxeTypes,
      FarmerVoxelVariantID,
      VoxelSelectors({
        enterWorldSelector: IWorld(world).pokemon_FarmerAgentSyste_enterWorld.selector,
        exitWorldSelector: IWorld(world).pokemon_FarmerAgentSyste_exitWorld.selector,
        voxelVariantSelector: IWorld(world).pokemon_FarmerAgentSyste_variantSelector.selector,
        activateSelector: IWorld(world).pokemon_FarmerAgentSyste_activate.selector,
        onNewNeighbourSelector: IWorld(world).pokemon_FarmerAgentSyste_neighbourEventHandler.selector,
        interactionSelectors: getInteractionSelectors()
      }),
      abi.encode(componentDefs),
      10
    );

    registerCAVoxelType(CA_ADDRESS, FarmerVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    bool hasValue = true;
    Farmer.set(callerAddress, entity, false, hasValue);
  }

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Farmer.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return FarmerVoxelVariantID;
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
      interactionSelector: IWorld(_world()).pokemon_FarmerAgentSyste_defaultEventHandler.selector,
      interactionName: "Default",
      interactionDescription: ""
    });
    voxelInteractionSelectors[1] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_FarmerAgentSyste_eatEventHandler.selector,
      interactionName: "Eat",
      interactionDescription: ""
    });
    return voxelInteractionSelectors;
  }

  function defaultEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    if (Farmer.getIsHungry(callerAddress, centerEntityId)) {
      Farmer.setIsHungry(callerAddress, centerEntityId, false);
    }
    BodySimData memory entitySimData = getEntitySimData(centerEntityId);
    VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), centerEntityId);
    return (false, stopEvent(centerEntityId, coord, entitySimData));
  }

  function eatEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    Farmer.setIsHungry(callerAddress, centerEntityId, true);
  }
}
