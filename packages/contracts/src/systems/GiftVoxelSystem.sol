// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { query, QueryFragment, QueryType } from "@latticexyz/world/src/modules/keysintable/query.sol";
import { OwnedBy, BodyType, OwnedByTableId } from "@tenet-contracts/src/codegen/Tables.sol";
import { BodyTypeRegistry, BodyTypeRegistryData } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { removeDuplicates } from "@tenet-utils/src/Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { console } from "forge-std/console.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { BodyTypeRegistry, BodyTypeRegistryData } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";

contract GiftVoxelSystem is System {
  function giftVoxel(bytes32 bodyTypeId) public returns (bytes32) {
    //  assert this exists in the registry
    require(IWorld(_world()).isBodyTypeAllowed(bodyTypeId), "GiftVoxel: Voxel type not allowed in this world");
    BodyTypeRegistryData memory bodyTypeData = BodyTypeRegistry.get(IStore(REGISTRY_ADDRESS), bodyTypeId);

    bytes32 entity = getUniqueEntity();
    // When a voxel is in your inventory, it's not in the world so it should have no voxel variant
    BodyType.set(bodyTypeData.scale, entity, bodyTypeId, "");

    OwnedBy.set(bodyTypeData.scale, entity, tx.origin);

    return entity;
  }
}
