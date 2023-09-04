// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { System } from "@latticexyz/world/src/System.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelType, Position } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelTypeData } from "@tenet-utils/src/Types.sol";
import { PositionData } from "@tenet-world/src/codegen/tables/Position.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { BaseCreationInWorld } from "@tenet-utils/src/Types.sol";
import { registerCreation as registerCreationToRegistry } from "@tenet-registry/src/Utils.sol";

contract CreationSystem is System {
  function registerCreation(
    string memory name,
    string memory description,
    VoxelEntity[] memory voxels,
    BaseCreationInWorld[] memory baseCreationsInWorld
  ) public returns (bytes32) {
    VoxelTypeData[] memory voxelTypes = getVoxelTypes(voxels);
    for (uint256 i = 0; i < voxelTypes.length; i++) {
      require(
        IWorld(_world()).isVoxelTypeAllowed(voxelTypes[i].voxelTypeId),
        "Register Voxel type not allowed in this world"
      );
    }
    VoxelCoord[] memory voxelCoords = getVoxelCoords(voxels); // NOTE: we do not know the relative position of these voxelCoords yet (since we don't know the coords of the voxels in the base creations). So we will reposition them later

    // Call registry
    (
      bytes32 creationId,
      VoxelCoord memory lowerSouthwestCorner,
      VoxelTypeData[] memory allVoxelTypes,
      VoxelCoord[] memory allVoxelCoordsInWorld
    ) = registerCreationToRegistry(REGISTRY_ADDRESS, name, description, voxelTypes, voxelCoords, baseCreationsInWorld);

    // Replace the voxels in the registration with a spawn!
    // delete the voxels at this coord
    for (uint256 i; i < allVoxelCoordsInWorld.length; i++) {
      IWorld(_world()).mineVoxelType(allVoxelTypes[i].voxelTypeId, allVoxelCoordsInWorld[i], true, true, abi.encode(0));
    }

    IWorld(_world()).spawn(lowerSouthwestCorner, creationId); // make this creation a spawn
    return creationId;
  }

  function getVoxelTypes(VoxelEntity[] memory voxels) internal view returns (VoxelTypeData[] memory) {
    VoxelTypeData[] memory voxelTypeData = new VoxelTypeData[](voxels.length);
    for (uint32 i = 0; i < voxels.length; i++) {
      voxelTypeData[i] = VoxelType.get(voxels[i].scale, voxels[i].entityId);
    }
    return voxelTypeData;
  }

  function getVoxelCoords(VoxelEntity[] memory voxels) internal view returns (VoxelCoord[] memory) {
    VoxelCoord[] memory voxelCoords = new VoxelCoord[](voxels.length);
    for (uint32 i = 0; i < voxels.length; i++) {
      PositionData memory position = Position.get(voxels[i].scale, voxels[i].entityId);
      voxelCoords[i] = VoxelCoord(position.x, position.y, position.z);
    }
    return voxelCoords;
  }
}
