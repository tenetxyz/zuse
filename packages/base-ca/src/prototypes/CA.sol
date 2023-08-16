// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { BodyTypeRegistry } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { CAPosition, CAPositionData, CAPositionTableId } from "@tenet-base-ca/src/codegen/tables/CAPosition.sol";
import { CAMind, CAMindTableId } from "@tenet-base-ca/src/codegen/tables/CAMind.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { CAEntityReverseMapping } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { CABodyType, CABodyTypeTableId } from "@tenet-base-ca/src/codegen/tables/CABodyType.sol";
import { VoxelCoord, InteractionSelector } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, entityArrayToCAEntityArray, entityToCAEntity, caEntityArrayToEntityArray } from "@tenet-base-ca/src/Utils.sol";
import { getNeighbourEntitiesFromCaller, getChildEntitiesFromCaller, getParentEntityFromCaller } from "@tenet-base-ca/src/CallUtils.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { getEnterWorldSelector, getExitWorldSelector, getBodyVariantSelector, getActivateSelector, getInteractionSelectors, getOnNewNeighbourSelector } from "@tenet-registry/src/Utils.sol";

abstract contract CA is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function registerCA() public virtual;

  function emptyBodyId() internal pure virtual returns (bytes32) {}

  function callBodyEnterWorld(bytes32 bodyTypeId, VoxelCoord memory coord, bytes32 caEntity) internal virtual;

  function callBodyExitWorld(bytes32 bodyTypeId, VoxelCoord memory coord, bytes32 caEntity) internal virtual;

  function callBodyRunInteraction(
    bytes4 interactionSelector,
    bytes32 bodyTypeId,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal virtual returns (bytes32[] memory);

  function callGetBodyVariant(
    bytes32 bodyTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal virtual returns (bytes32);

  function terrainGen(
    address callerAddress,
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) internal virtual {
    CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
    bytes32 caEntity = getUniqueEntity();
    CAEntityMapping.set(callerAddress, entity, caEntity);
    CAEntityReverseMapping.set(caEntity, callerAddress, entity);
  }

  function isBodyTypeAllowed(bytes32 bodyTypeId) public view returns (bool) {
    bytes32[] memory bodyTypeIds = CARegistry.getBodyTypeIds(IStore(getRegistryAddress()), _world());
    for (uint256 i = 0; i < bodyTypeIds.length; i++) {
      if (bodyTypeIds[i] == bodyTypeId) {
        return true;
      }
    }
    return false;
  }

  function enterWorld(
    bytes32 bodyTypeId,
    bytes4 mindSelector,
    VoxelCoord memory coord,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public {
    address callerAddress = _msgSender();
    require(isBodyTypeAllowed(bodyTypeId), "CASystem: This body type is not allowed in this CA");

    // Check if we can set the body type at this position
    bytes32 existingEntity = getEntityAtCoord(IStore(_world()), callerAddress, coord);
    bytes32 caEntity;
    if (existingEntity != 0) {
      require(
        CABodyType.get(callerAddress, existingEntity).bodyTypeId == emptyBodyId(),
        "EnterWorld: This position is already occupied by another body"
      );
      caEntity = entityToCAEntity(callerAddress, entity);
    } else {
      require(!hasKey(CAEntityMappingTableId, CAEntityMapping.encodeKeyTuple(callerAddress, entity)), "Entity exists");
      CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
      caEntity = getUniqueEntity();
      CAEntityMapping.set(callerAddress, entity, caEntity);
      CAEntityReverseMapping.set(caEntity, callerAddress, entity);
    }
    CAMind.set(caEntity, bodyTypeId, mindSelector);

    bytes32[] memory caNeighbourEntityIds = entityArrayToCAEntityArray(callerAddress, neighbourEntityIds);

    callBodyEnterWorld(bodyTypeId, coord, caEntity);

    bytes32 bodyVariantId = callGetBodyVariant(
      bodyTypeId,
      caEntity,
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity
    );
    CABodyType.set(callerAddress, entity, bodyTypeId, bodyVariantId);
  }

  function exitWorld(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public {
    if (bodyTypeId == emptyBodyId()) {
      return;
    }

    address callerAddress = _msgSender();
    if (!hasKey(CAPositionTableId, CAPosition.encodeKeyTuple(callerAddress, entity))) {
      terrainGen(callerAddress, bodyTypeId, coord, entity);
    }

    bytes32 caEntity = entityToCAEntity(callerAddress, entity);
    bytes32[] memory caNeighbourEntityIds = entityArrayToCAEntityArray(callerAddress, neighbourEntityIds);

    bytes32 emptyBodyVariantId = callGetBodyVariant(
      emptyBodyId(),
      caEntity,
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity
    );
    CABodyType.set(callerAddress, entity, emptyBodyId(), emptyBodyVariantId);

    callBodyExitWorld(bodyTypeId, coord, caEntity);

    CAMind.set(caEntity, bodyTypeId, bytes4(0)); // emoty body has no mind
  }

  function moveWorld(
    bytes32 bodyTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bytes32 newEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public {
    address callerAddress = _msgSender();
    require(isBodyTypeAllowed(bodyTypeId), "CASystem: This body type is not allowed in this CA");

    bytes32 oldEntity = getEntityAtCoord(IStore(_world()), callerAddress, oldCoord);
    require(oldEntity != 0, "No entity at old coord");

    // Set to old entity Air
    bytes32 oldCAEntity = entityToCAEntity(callerAddress, oldEntity);
    // TODO: Note these neighbour, child, and parent are NOT for the old coord
    // But for air, we don't need them.
    {
      bytes32 emptyBodyVariantId = callGetBodyVariant(
        emptyBodyId(),
        bytes32(0),
        new bytes32[](0),
        new bytes32[](0),
        bytes32(0)
      );
      CABodyType.set(callerAddress, oldEntity, emptyBodyId(), emptyBodyVariantId);
    }
    // Set new entity to body type
    bytes32 existingEntity = getEntityAtCoord(IStore(_world()), callerAddress, newCoord);
    bytes32 newCAEntity;
    if (existingEntity != 0) {
      require(
        CABodyType.get(callerAddress, existingEntity).bodyTypeId == emptyBodyId(),
        "MoveWorld: This position is already occupied by another body"
      );
      newCAEntity = entityToCAEntity(callerAddress, newEntity);
    } else {
      require(
        !hasKey(CAEntityMappingTableId, CAEntityMapping.encodeKeyTuple(callerAddress, newEntity)),
        "Entity exists"
      );
      CAPosition.set(callerAddress, newEntity, CAPositionData({ x: newCoord.x, y: newCoord.y, z: newCoord.z }));
      newCAEntity = getUniqueEntity();
      // TODO: should there be a mind for this new entity?
      CAMind.set(newCAEntity, bodyTypeId, bytes4(0));
      // CAEntityMapping.set(callerAddress, newEntity, newCAEntity);
      // CAEntityReverseMapping.set(newCAEntity, callerAddress, newEntity);
    }

    // Update CA entity mapping from old to new
    // Note: This is the main move of the pointer
    CAEntityMapping.set(callerAddress, oldEntity, newCAEntity);
    CAEntityReverseMapping.set(newCAEntity, callerAddress, oldEntity);
    CAEntityMapping.set(callerAddress, newEntity, oldCAEntity);
    CAEntityReverseMapping.set(oldCAEntity, callerAddress, newEntity);

    moveWorldHelper(
      callerAddress,
      oldCAEntity,
      newEntity,
      bodyTypeId,
      neighbourEntityIds,
      childEntityIds,
      parentEntity
    );
  }

  function moveWorldHelper(
    address callerAddress,
    bytes32 oldCAEntity,
    bytes32 newEntity,
    bytes32 bodyTypeId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal {
    bytes32[] memory caNeighbourEntityIds = entityArrayToCAEntityArray(callerAddress, neighbourEntityIds);
    bytes32 bodyVariantId = callGetBodyVariant(
      bodyTypeId,
      oldCAEntity, // This needs to be the old one, since it's a move
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity
    );
    CABodyType.set(callerAddress, newEntity, bodyTypeId, bodyVariantId);
  }

  function runInteraction(
    bytes4 interactionSelector,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32[] memory changedEntities) {
    address callerAddress = _msgSender();
    require(
      hasKey(CABodyTypeTableId, CABodyType.encodeKeyTuple(callerAddress, interactEntity)),
      "Entity does not exist"
    );
    bytes32 bodyTypeId = CABodyType.getBodyTypeId(callerAddress, interactEntity);

    bytes32 caInteractEntity = entityToCAEntity(callerAddress, interactEntity);
    bytes32[] memory caNeighbourEntityIds = entityArrayToCAEntityArray(callerAddress, neighbourEntityIds);

    // Note: Center and Neighbour could just be different interfaces, but then the user would have to
    // define two, so instead we just call one interface and pass in the entity ids

    // Center Interaction
    bytes32[] memory changedCAEntities = callBodyRunInteraction(
      interactionSelector,
      bodyTypeId,
      caInteractEntity,
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity
    );

    // Neighbour Interactions
    for (uint256 i = 0; i < neighbourEntityIds.length; i++) {
      if (neighbourEntityIds[i] != 0) {
        bytes32 neighbourBodyTypeId = CABodyType.getBodyTypeId(callerAddress, neighbourEntityIds[i]);

        {
          bytes4 onNewNeighbourSelector = getOnNewNeighbourSelector(IStore(getRegistryAddress()), neighbourBodyTypeId);
          if (onNewNeighbourSelector != bytes4(0)) {
            safeCall(
              _world(),
              abi.encodeWithSelector(onNewNeighbourSelector, caNeighbourEntityIds[i], caInteractEntity),
              "onNewNeighbourSelector"
            );
          }
        }

        // Call body interaction
        bytes32[] memory changedCANeighbourEntities = callBodyRunInteraction(
          bytes4(0),
          neighbourBodyTypeId,
          caInteractEntity,
          caNeighbourEntityIds,
          childEntityIds,
          parentEntity
        );

        for (uint256 j = 0; j < changedCANeighbourEntities.length; j++) {
          if (changedCAEntities[j] == 0 && changedCANeighbourEntities[j] != 0) {
            changedCAEntities[j] = changedCANeighbourEntities[j];
          }
        }
      }
    }

    changedEntities = caEntityArrayToEntityArray(changedCAEntities);
    // Update body types after interaction
    updateBodyTypes(callerAddress, changedEntities);

    return changedEntities;
  }

  function updateBodyTypes(address callerAddress, bytes32[] memory changedEntities) internal {
    for (uint256 i = 0; i < changedEntities.length; i++) {
      bytes32 changedEntity = changedEntities[i];
      if (changedEntity != 0) {
        bytes32 changedBodyTypeId = CABodyType.getBodyTypeId(callerAddress, changedEntity);
        uint32 scale = BodyTypeRegistry.getScale(IStore(getRegistryAddress()), changedBodyTypeId);
        bytes32 bodyVariantId = callGetBodyVariant(
          changedBodyTypeId,
          entityToCAEntity(callerAddress, changedEntity),
          entityArrayToCAEntityArray(
            callerAddress,
            getNeighbourEntitiesFromCaller(callerAddress, scale, changedEntity)
          ),
          getChildEntitiesFromCaller(callerAddress, scale, changedEntity),
          getParentEntityFromCaller(callerAddress, scale, changedEntity)
        );
        CABodyType.set(callerAddress, changedEntity, changedBodyTypeId, bodyVariantId);
      }
    }
  }

  function activateBody(bytes32 entity) public returns (string memory) {
    address callerAddress = _msgSender();
    bytes32 bodyTypeId = CABodyType.getBodyTypeId(callerAddress, entity);
    bytes4 bodyActivateSelector = getActivateSelector(IStore(getRegistryAddress()), bodyTypeId);
    bytes32 caEntity = entityToCAEntity(callerAddress, entity);
    bytes memory returnData = safeCall(
      _world(),
      abi.encodeWithSelector(bodyActivateSelector, caEntity),
      "body activate"
    );
    return abi.decode(returnData, (string));
  }
}
