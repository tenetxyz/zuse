// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { query, QueryFragment, QueryType } from "@latticexyz/world/src/modules/keysintable/query.sol";
import { OwnedBy, VoxelType, OwnedByTableId, VoxelTypeTableId, VoxelTypeRegistry, VoxelTypeRegistryTableId } from "../codegen/Tables.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { addressToEntityKey, removeDuplicates, staticcallFunctionSelector } from "../Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { console } from "forge-std/console.sol";
import { VoxelVariantsKey } from "../Types.sol";

contract GiftVoxelSystem is System {
  function giftVoxel(bytes16 voxelTypeNamespace, bytes32 voxelTypeId) public returns (bytes32) {
    //  assert this exists in the registry
    bytes32[] memory keyTuple = new bytes32[](2);
    keyTuple[0] = bytes32((voxelTypeNamespace));
    keyTuple[1] = voxelTypeId;
    require(hasKey(VoxelTypeRegistryTableId, keyTuple), "Voxel type does not exist in the registry");

    // even if they request an entity of a type they already own, it's okay to disallow it since they would still have that entity type
    // Since numUniqueVoxelTypesIOwn is quadratic in gas (based on how many voxels you own), running this function could use up all your gas. So it's commented
    // require(numUniqueVoxelTypesIOwn() <= 36, "You can only own 36 unique voxel types at a time");
    bytes32 entity = getUniqueEntity();
    // When a voxel is in your inventory, it's not in the world so it should have no voxel variant
    VoxelType.set(entity, voxelTypeNamespace, voxelTypeId, "", "");

    OwnedBy.set(entity, addressToEntityKey(_msgSender()));

    return entity;
  }

  function numUniqueVoxelTypesIOwn() public view returns (uint) {
    // first make sure the user has enough inventory room to receive the gift
    QueryFragment[] memory fragments = new QueryFragment[](2);
    fragments[0] = QueryFragment(QueryType.HasValue, OwnedByTableId, abi.encode(addressToEntityKey(_msgSender()))); // Specify OwnedBy first since it's a more restrictive filter (for performance reasons)
    fragments[1] = QueryFragment(QueryType.Has, VoxelTypeTableId, new bytes(0));

    bytes32[][] memory voxelsIOwnTuples = query(fragments); // an array of 1-tuple keys are returned e.g. [[key1], [key2], [key3]]
    if (voxelsIOwnTuples.length == 0) {
      return 0;
    }
    // since mud doesn't have a JOIN operation, we have to manually loop through each entity to get their types
    bytes[] memory voxelTypesIOwn = new bytes[](voxelsIOwnTuples.length);
    for (uint i = 0; i < voxelsIOwnTuples.length; i++) {
      //            console.log("voxelsIOwnTuples.length", voxelsIOwnTuples.length);
      //            console.log("voxelsIOwnTuples[0].length", voxelsIOwnTuples[i].length);
      bytes32 entityId = voxelsIOwnTuples[i][0];
      voxelTypesIOwn[i] = abi.encode(VoxelType.get(entityId));
    }

    return removeDuplicates(voxelTypesIOwn).length;
  }
}
