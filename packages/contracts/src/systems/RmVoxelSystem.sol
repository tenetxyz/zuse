// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { OwnedBy, OwnedByTableId, BodyType } from "@tenet-contracts/src/codegen/Tables.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

// If we call this RemoveVoxelSystem, the foundry codegen fails cause they set a limit on the number of chars for an interface
contract RmVoxelSystem is System {
  function removeVoxels(uint32[] memory scales, bytes32[] memory voxels) public {
    require(scales.length == voxels.length, "scales and voxels must be the same length");
    // for each voxel, require it to be owned by the _msgSender
    for (uint i = 0; i < voxels.length; i++) {
      require(OwnedBy.get(scales[i], voxels[i]) == tx.origin, "Voxel not owned by sender");
      // delete the voxel
      // TODO: delete all values in relevant components as well
      OwnedBy.deleteRecord(scales[i], voxels[i]);
      BodyType.deleteRecord(scales[i], voxels[i]);
    }
  }

  function removeAllOwnedVoxels() public {
    bytes32[][] memory entitiesOwnedBySender = getKeysWithValue(OwnedByTableId, OwnedBy.encode(tx.origin));
    for (uint256 i = 0; i < entitiesOwnedBySender.length; i++) {
      bytes32[] memory entity = entitiesOwnedBySender[i];
      uint32 scale = uint32(uint256(entity[0]));
      OwnedBy.deleteRecord(scale, entity[1]);
      BodyType.deleteRecord(scale, entity[1]);
    }
  }
}
