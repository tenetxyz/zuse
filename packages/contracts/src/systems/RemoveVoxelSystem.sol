// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { OwnedBy, Item } from "../codegen/Tables.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { addressToEntityKey } from "../utils.sol";

contract RemoveVoxelSystem is System {
    function removeVoxels(bytes32[] memory voxels) public {
        // for each voxel, require it to be owned by the _msgSender
        for (uint i = 0; i < voxels.length; i++) {
            require(OwnedBy.get(voxels[i]) == addressToEntityKey(msg.sender), "Voxel not owned by sender");
            // delete the voxel
            // TODO: delete all values in relevant components as well
            OwnedBy.deleteRecord(voxels[i]);
            Item.deleteRecord(voxels[i]);
        }
    }
}