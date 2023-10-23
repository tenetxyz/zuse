// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { CAPosition, CAPositionData, CAPositionTableId } from "@tenet-base-ca/src/codegen/tables/CAPosition.sol";
import { CAMind, CAMindTableId } from "@tenet-base-ca/src/codegen/tables/CAMind.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { CAEntityReverseMapping } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { CAVoxelType, CAVoxelTypeTableId } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelCoord, InteractionSelector } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, entityArrayToCAEntityArray, entityToCAEntity, caEntityArrayToEntityArray } from "@tenet-base-ca/src/Utils.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { getPreviewVoxelVariantId, getEnterWorldSelector, getExitWorldSelector, getVoxelVariantSelector, getActivateSelector, getInteractionSelectors, getOnNewNeighbourSelector } from "@tenet-registry/src/Utils.sol";

abstract contract CAHelper is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function voxelEnterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) public virtual {
    bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(getRegistryAddress()), voxelTypeId);
    if (baseVoxelTypeId != voxelTypeId) {
      voxelEnterWorld(baseVoxelTypeId, coord, caEntity); // recursive, so we get the entire stack of russian dolls
    }
    bytes4 voxelEnterWorldSelector = getEnterWorldSelector(IStore(getRegistryAddress()), voxelTypeId);
    if (voxelEnterWorldSelector != bytes4(0)) {
      safeCall(_world(), abi.encodeWithSelector(voxelEnterWorldSelector, coord, caEntity), "voxel enter world");
    }
  }

  function getVoxelVariant(
    bytes32 voxelTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public virtual returns (bytes32) {
    bytes4 voxelVariantSelector = getVoxelVariantSelector(IStore(getRegistryAddress()), voxelTypeId);
    if (voxelVariantSelector == bytes4(0)) {
      return getPreviewVoxelVariantId(IStore(getRegistryAddress()), voxelTypeId);
    }
    bytes memory returnData = safeStaticCall(
      _world(),
      abi.encodeWithSelector(voxelVariantSelector, caEntity, caNeighbourEntityIds, childEntityIds, parentEntity),
      "voxel variant selector"
    );
    return abi.decode(returnData, (bytes32));
  }

  function voxelExitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) public virtual {
    bytes4 voxelExitWorldSelector = getExitWorldSelector(IStore(getRegistryAddress()), voxelTypeId);
    if (voxelExitWorldSelector != bytes4(0)) {
      safeCall(_world(), abi.encodeWithSelector(voxelExitWorldSelector, coord, caEntity), "voxel exit world");
    }

    bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(getRegistryAddress()), voxelTypeId);
    if (baseVoxelTypeId != voxelTypeId) {
      voxelExitWorld(baseVoxelTypeId, coord, caEntity); // recursive, so we get the entire stack of russian dolls
    }
  }
}
