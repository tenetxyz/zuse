// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { OwnedBy, VoxelType } from "../codegen/Tables.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { addressToEntityKey } from "../utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

contract GiftVoxelSystem is System {
    function giftVoxel(bytes32 voxelType ) public returns (bytes32) {
        bytes32 entity = getUniqueEntity();
        VoxelType.set(entity, voxelType);
        OwnedBy.set(entity, addressToEntityKey(msg.sender));
        return entity;
    }
}