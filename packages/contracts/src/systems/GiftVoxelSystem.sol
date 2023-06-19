// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { query, QueryFragment, QueryType } from "@latticexyz/world/src/modules/keysintable/query.sol";
import { OwnedBy, VoxelType, OwnedByTableId, VoxelTypeTableId } from "../codegen/Tables.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { addressToEntityKey, removeDuplicates } from "../utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { console } from "forge-std/console.sol";

contract GiftVoxelSystem is System {
    function giftVoxel(bytes32 voxelType ) public returns (bytes32) {

        // even if they request an entity of a type they already own, it's okay to disallow it since they would still have that entity type
        require(numUniqueVoxelTypesIOwn() <= 36, "You can only own 36 unique voxel types at a time");
        bytes32 entity = getUniqueEntity();
        VoxelType.set(entity, voxelType);
        OwnedBy.set(entity, addressToEntityKey(_msgSender()));
        return entity;
    }

    function numUniqueVoxelTypesIOwn() public view returns (uint) {
        // first make sure the user has enough inventory room to receive the gift
        QueryFragment[] memory fragments = new QueryFragment[](2);
        fragments[0] = QueryFragment(QueryType.HasValue, OwnedByTableId, abi.encode(addressToEntityKey(_msgSender()))); // Specify OwnedBy first since it's a more restrictive filter (for performance reasons)
        fragments[1] = QueryFragment(QueryType.Has, VoxelTypeTableId, new bytes(0));

        bytes32[][] memory voxelsIOwnTuples = query(fragments); // an array of 1-tuple keys are returned e.g. [[key1], [key2], [key3]]
        if(voxelsIOwnTuples.length == 0){
            return 0;
        }
        // since mud doesn't have a JOIN operation, we have to manually loop through each entity to get their types
        bytes32[] memory voxelTypesIOwn = new bytes32[](voxelsIOwnTuples.length);
        for(uint i = 0; i < voxelsIOwnTuples.length; i++){
            bytes32 entityId = voxelsIOwnTuples[i][0];
            voxelTypesIOwn[i] = VoxelType.get(entityId);
        }

        return removeDuplicates(voxelTypesIOwn).length;
    }
}