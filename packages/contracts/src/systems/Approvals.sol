// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { query, QueryFragment, QueryType } from "@latticexyz/world/src/modules/keysintable/query.sol";
import { OwnedBy, VoxelType, OwnedByTableId, VoxelTypeTableId, Player } from "@tenet-contracts/src/codegen/Tables.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { removeDuplicates } from "@tenet-utils/src/Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { console } from "forge-std/console.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

contract ApprovalsSystem is System {
  // right now, the only way for approval functions to have the same signature is to have them follow the contract interface
  // this isn't enforced right now, but it probably should be. (annoying part is solidity doesn't have function interfaces, only contract interfaces)

  // approvals may need to have params passed in
  //
  function approveMine(
    address caller,
    bytes4 callee,
    bytes4 playerId,
    VoxelCoord memory position
  ) public returns (bool) {
    // uint32 stamina = Player.getStamina(playerId);
    // if (stamina > 0) {
    //   return true;
    // }
    return true;
  }
}
