// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { WorldRegistryTableId, WorldRegistry, BodyTypeRegistry, BodyTypeRegistryData, BodyTypeRegistryTableId, BodyVariantsRegistry, BodyVariantsRegistryData, BodyVariantsRegistryTableId } from "../codegen/Tables.sol";
import { entityArraysAreEqual } from "@tenet-utils/src/Utils.sol";
import { CreationMetadata, CreationSpawns, BodySelectors } from "@tenet-utils/src/Types.sol";

contract BodyRegistrySystem is System {
  function registerBodyType(
    string memory bodyTypeName,
    bytes32 bodyTypeId,
    bytes32 baseBodyTypeId,
    bytes32[] memory childBodyTypeIds,
    bytes32[] memory schemaBodyTypeIds,
    bytes32 previewBodyVariantId,
    BodySelectors memory bodySelectors
  ) public {
    require(
      !hasKey(BodyTypeRegistryTableId, BodyTypeRegistry.encodeKeyTuple(bodyTypeId)),
      "Body type ID has already been registered"
    );
    require(
      hasKey(BodyVariantsRegistryTableId, BodyVariantsRegistry.encodeKeyTuple(previewBodyVariantId)),
      "Preview body variant ID has not been registered"
    );
    require(bytes(bodyTypeName).length > 0, "Name cannot be empty");

    uint32 scale;
    if (childBodyTypeIds.length == 1) {
      scale = 1;
      require(
        childBodyTypeIds[0] == bodyTypeId,
        "Child body type ID must be the same as parent body type ID for scale 1"
      );
    } else if (childBodyTypeIds.length == 8) {
      for (uint256 i; i < childBodyTypeIds.length; i++) {
        if (childBodyTypeIds[i] == 0) {
          continue;
        }
        require(
          hasKey(BodyTypeRegistryTableId, BodyTypeRegistry.encodeKeyTuple(childBodyTypeIds[i])),
          "Child body type ID has not been registered"
        );
        if (scale == 0) {
          scale = BodyTypeRegistry.getScale(childBodyTypeIds[i]) + 1;
        } else {
          require(scale == BodyTypeRegistry.getScale(childBodyTypeIds[i]) + 1, "All body types must be the same scale");
        }
      }
    } else {
      revert("Invalid number of child body types");
    }

    if (schemaBodyTypeIds.length == 1) {
      require(
        schemaBodyTypeIds[0] == bodyTypeId,
        "Schemal body type ID must be the same as parent body type ID for scale 1"
      );
    } else if (childBodyTypeIds.length == 8) {
      // TODO: Add more checks on schemaBodyTypeIds
      for (uint256 i; i < schemaBodyTypeIds.length; i++) {
        if (schemaBodyTypeIds[i] == 0) {
          continue;
        }
        require(
          hasKey(BodyTypeRegistryTableId, BodyTypeRegistry.encodeKeyTuple(schemaBodyTypeIds[i])),
          "Schema body type ID has not been registered"
        );
      }
    } else {
      revert("Invalid number of schema body types");
    }

    if (baseBodyTypeId != bodyTypeId) {
      // otherwise, this is a base body type, so we don't need any checks
      require(
        hasKey(BodyTypeRegistryTableId, BodyTypeRegistry.encodeKeyTuple(baseBodyTypeId)),
        "Base body type ID has not been registered"
      );

      require(scale == BodyTypeRegistry.getScale(baseBodyTypeId), "Base body type must be the same scale");

      require(
        entityArraysAreEqual(childBodyTypeIds, BodyTypeRegistry.getChildBodyTypeIds(baseBodyTypeId)),
        "Child body type IDs must be the same as base"
      );
      require(
        entityArraysAreEqual(schemaBodyTypeIds, BodyTypeRegistry.getSchemaBodyTypeIds(baseBodyTypeId)),
        "Schema body type IDs must be the same as base"
      );
    }

    BodyTypeRegistryData memory bodyTypeData;
    bodyTypeData.baseBodyTypeId = baseBodyTypeId;
    // TODO: add checks on selectors
    bodyTypeData.selectors = abi.encode(bodySelectors);
    bodyTypeData.childBodyTypeIds = childBodyTypeIds;
    bodyTypeData.schemaBodyTypeIds = schemaBodyTypeIds;
    bodyTypeData.previewBodyVariantId = previewBodyVariantId;
    bodyTypeData.scale = scale;
    {
      bodyTypeData.metadata = getMetadata(bodyTypeName);
    }

    BodyTypeRegistry.set(bodyTypeId, bodyTypeData);
  }

  function getMetadata(string memory name) internal view returns (bytes memory) {
    return
      abi.encode(
        CreationMetadata({ creator: tx.origin, name: name, description: "", spawns: new CreationSpawns[](0) })
      );
  }

  function registerBodyVariant(bytes32 bodyVariantId, BodyVariantsRegistryData memory bodyVariant) public {
    require(
      !hasKey(BodyVariantsRegistryTableId, BodyVariantsRegistry.encodeKeyTuple(bodyVariantId)),
      "Body variant ID has already been registered"
    );

    bytes32[][] memory variants = getKeysInTable(BodyVariantsRegistryTableId);
    uint256 bodyVariantIdCounter = variants.length;
    bodyVariant.variantId = bodyVariantIdCounter;
    BodyVariantsRegistry.set(bodyVariantId, bodyVariant);
  }

  function bodySpawned(bytes32 bodyTypeId) public returns (uint256) {
    address worldAddress = _msgSender();
    require(hasKey(WorldRegistryTableId, WorldRegistry.encodeKeyTuple(worldAddress)), "World has not been registered");
    require(
      hasKey(BodyTypeRegistryTableId, BodyTypeRegistry.encodeKeyTuple(bodyTypeId)),
      "Body type ID has not been registered"
    );
    CreationMetadata memory creationMetadata = abi.decode(BodyTypeRegistry.getMetadata(bodyTypeId), (CreationMetadata));
    CreationSpawns[] memory creationSpawns = creationMetadata.spawns;
    bool found = false;
    uint256 newSpawnCount = 0;
    for (uint256 i = 0; i < creationSpawns.length; i++) {
      if (creationSpawns[i].worldAddress == worldAddress) {
        creationSpawns[i].numSpawns += 1;
        newSpawnCount = creationSpawns[i].numSpawns;
        creationMetadata.spawns = creationSpawns;
        BodyTypeRegistry.setMetadata(bodyTypeId, abi.encode(creationMetadata));
        found = true;
        break;
      }
    }
    if (!found) {
      // this means, this is a new world, and we need to add it to the array
      CreationSpawns[] memory newCreationSpawns = new CreationSpawns[](creationSpawns.length + 1);
      for (uint256 i = 0; i < creationSpawns.length; i++) {
        newCreationSpawns[i] = creationSpawns[i];
      }
      newCreationSpawns[creationSpawns.length] = CreationSpawns({ worldAddress: worldAddress, numSpawns: 1 });
      creationMetadata.spawns = newCreationSpawns;
      newSpawnCount = 1;
      BodyTypeRegistry.setMetadata(bodyTypeId, abi.encode(creationMetadata));
    }

    return newSpawnCount;
  }
}
