// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelVariantsKey } from "../Types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData, VoxelTypeRegistry } from "../codegen/Tables.sol";
import { AirID } from "./voxels/AirVoxelSystem.sol";
import { enterVoxelIntoWorld, exitVoxelFromWorld, updateVoxelVariant, addressToEntityKey, getEntitiesAtCoord, safeStaticCallFunctionSelector, getVoxelVariant } from "../Utils.sol";
import { Utils } from "@latticexyz/world/src/Utils.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { Occurrence } from "../codegen/Tables.sol";
import { console } from "forge-std/console.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "../Constants.sol";

contract ActivateSystem is System {
  function activate(bytes32 entity) public returns (bytes32) {
    // Actually, I don't think we need this restriction
    // require(Position.has(entity), "The entity must be placed in the world");
  }
}
