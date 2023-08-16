// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { BodyVariantsRegistryData } from "@tenet-registry/src/codegen/tables/BodyVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerBodyVariant, registerBodyType } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, FighterVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BodySelectors, InteractionSelector } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { getCAEntityAtCoord, getCABodyType } from "@tenet-base-ca/src/Utils.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { Fighters, FightersData } from "@tenet-level2-ca/src/codegen/tables/Fighters.sol";

bytes32 constant FighterVoxelVariantID = bytes32(keccak256("fighter"));
string constant FighterTexture = "bafkreihpdljsgdltghxehq4cebngtugfj3pduucijxcrvcla4hoy34f7vq";

contract FighterAgentSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();
    BodyVariantsRegistryData memory fighterVariant;
    fighterVariant.blockType = NoaBlockType.MESH;
    fighterVariant.opaque = false;
    fighterVariant.solid = false;
    fighterVariant.frames = 1;
    string[] memory fighterMaterials = new string[](1);
    fighterMaterials[0] = FighterTexture;
    fighterVariant.materials = abi.encode(fighterMaterials);
    registerBodyVariant(REGISTRY_ADDRESS, FighterVoxelVariantID, fighterVariant);

    bytes32[] memory fighterChildBodyTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      fighterChildBodyTypes[i] = AirVoxelID;
    }
    bytes32 baseBodyTypeId = FighterVoxelID;

    InteractionSelector[] memory voxelInteractionSelectors = new InteractionSelector[](1);
    voxelInteractionSelectors[0] = InteractionSelector({
      interactionSelector: IWorld(world).ca_FighterAgentSyst_eventHandler.selector,
      interactionName: "Move Forward",
      interactionDescription: ""
    });

    registerBodyType(
      REGISTRY_ADDRESS,
      "Fighter",
      FighterVoxelID,
      baseBodyTypeId,
      fighterChildBodyTypes,
      fighterChildBodyTypes,
      FighterVoxelVariantID,
      BodySelectors({
        enterWorldSelector: IWorld(world).ca_FighterAgentSyst_enterWorld.selector,
        exitWorldSelector: IWorld(world).ca_FighterAgentSyst_exitWorld.selector,
        bodyVariantSelector: IWorld(world).ca_FighterAgentSyst_variantSelector.selector,
        activateSelector: IWorld(world).ca_FighterAgentSyst_activate.selector,
        onNewNeighbourSelector: IWorld(world).ca_FighterAgentSyst_onNewNeighbour.selector,
        interactionSelectors: voxelInteractionSelectors
      })
    );
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Fighters.set(callerAddress, entity, FightersData({ health: 100, hasValue: true }));
  }

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Fighters.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return FighterVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function onNewNeighbour(bytes32 interactEntity, bytes32 neighbourEntityId) public {
    address callerAddress = super.getCallerAddress();
    Fighters.setHealth(callerAddress, interactEntity, 50);
  }

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory) {
    address callerAddress = super.getCallerAddress();

    return
      IWorld(_world()).ca_MoveForwardSyste_eventHandlerMoveForward(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }
}
