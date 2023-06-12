// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { query, QueryFragment, QueryType } from "@latticexyz/world/src/modules/keysintable/query.sol";
import { OwnedBy, VoxelType, OwnedByTableId, VoxelTypeTableId } from "../codegen/Tables.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { addressToEntityKey } from "../utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract GiftVoxelSystem is System {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    function giftVoxel(bytes32 voxelType ) public returns (bytes32) {
        // first make sure the user has enough inventory room to receive the gift
        QueryFragment[] memory fragments = new QueryFragment[](2);

        fragments[0] = QueryFragment(QueryType.HasValue, OwnedByTableId, abi.encode(_msgSender())); // Specify OwnedBy first since it's a more restrictive filter (for performance reasons)
        fragments[1] = QueryFragment(QueryType.Has, VoxelTypeTableId, new bytes(0));
        bytes32[][] memory voxelsIOwn = query(fragments);
        EnumerableSet.AddressSet uniqueVoxelTypesIOwn;

        // TODO: when MUD adds a join operation, we can find all the unique voxel types in one query
        for(int i = 0; i < voxelsIOwn; i < voxelsIOwn.length){
            bytes32 voxelType = VoxelType.get(voxelsIOwn[i]);
            uniqueVoxelTypesIOwn.add(voxelType);
        }
        require(uniqueVoxelTypesIOwn.length < 36, "You cannot own more than 36 unique voxel types");


        bytes32 entity = getUniqueEntity();
        VoxelType.set(entity, voxelType);
        OwnedBy.set(entity, addressToEntityKey(_msgSender()));
        return entity;
    }
}