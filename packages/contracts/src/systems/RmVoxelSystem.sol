// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { OwnedBy, OwnedByTableId, VoxelType } from "@tenet-contracts/src/codegen/Tables.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

// If we call this RemoveVoxelSystem, the foundry codegen fails cause they set a limit on the number of chars for an interface
contract RmVoxelSystem is System {
  function removeVoxels(bytes32[] memory voxels) public {
    // for each voxel, require it to be owned by the _msgSender
    for (uint i = 0; i < voxels.length; i++) {
      require(OwnedBy.get(voxels[i]) == addressToEntityKey(_msgSender()), "Voxel not owned by sender");
      // delete the voxel
      // TODO: delete all values in relevant components as well
      OwnedBy.deleteRecord(voxels[i]);
      VoxelType.deleteRecord(1, voxels[i]);
    }
  }

  function removeAllOwnedVoxels() public {
    bytes32[][] memory entitiesOwnedBySender = getKeysWithValue(
      OwnedByTableId,
      OwnedBy.encode(addressToEntityKey(_msgSender()))
    );
    for (uint256 i = 0; i < entitiesOwnedBySender.length; i++) {
      OwnedBy.deleteRecord(entitiesOwnedBySender[0][i]);
      VoxelType.deleteRecord(1, entitiesOwnedBySender[0][i]);
    }
  }
}
