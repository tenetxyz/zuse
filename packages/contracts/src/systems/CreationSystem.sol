// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { System } from "@latticexyz/world/src/System.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { BodyType, Position } from "@tenet-contracts/src/codegen/Tables.sol";
import { PositionData } from "@tenet-contracts/src/codegen/tables/Position.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { VoxelCoord, BodyEntity, BodyTypeData } from "@tenet-utils/src/Types.sol";
import { BaseCreationInWorld } from "@tenet-utils/src/Types.sol";
import { registerCreation as registerCreationToRegistry } from "@tenet-registry/src/Utils.sol";

contract CreationSystem is System {
  function registerCreation(
    string memory name,
    string memory description,
    BodyEntity[] memory bodyEntities,
    BaseCreationInWorld[] memory baseCreationsInWorld
  ) public returns (bytes32) {
    BodyTypeData[] memory bodyTypes = getBodyTypes(bodyEntities);
    for (uint256 i = 0; i < bodyTypes.length; i++) {
      require(
        IWorld(_world()).isBodyTypeAllowed(bodyTypes[i].bodyTypeId),
        "Register Voxel type not allowed in this world"
      );
    }
    VoxelCoord[] memory voxelCoords = getVoxelCoords(bodyEntities); // NOTE: we do not know the relative position of these voxelCoords yet (since we don't know the coords of the bodyEntities in the base creations). So we will reposition them later

    // Call registry
    (
      bytes32 creationId,
      VoxelCoord memory lowerSouthwestCorner,
      BodyTypeData[] memory allBodyTypes,
      VoxelCoord[] memory allVoxelCoordsInWorld
    ) = registerCreationToRegistry(REGISTRY_ADDRESS, name, description, bodyTypes, voxelCoords, baseCreationsInWorld);

    // Replace the bodyEntities in the registration with a spawn!
    // delete the bodyEntities at this coord
    for (uint256 i; i < allVoxelCoordsInWorld.length; i++) {
      IWorld(_world()).mineBodyType(allBodyTypes[i].bodyTypeId, allVoxelCoordsInWorld[i], true, true, abi.encode(0));
    }

    IWorld(_world()).spawn(lowerSouthwestCorner, creationId); // make this creation a spawn
    return creationId;
  }

  function getBodyTypes(BodyEntity[] memory bodyEntities) internal view returns (BodyTypeData[] memory) {
    BodyTypeData[] memory bodyTypeData = new BodyTypeData[](bodyEntities.length);
    for (uint32 i = 0; i < bodyEntities.length; i++) {
      bodyTypeData[i] = BodyType.get(bodyEntities[i].scale, bodyEntities[i].entityId);
    }
    return bodyTypeData;
  }

  function getVoxelCoords(BodyEntity[] memory bodyEntities) internal view returns (VoxelCoord[] memory) {
    VoxelCoord[] memory voxelCoords = new VoxelCoord[](bodyEntities.length);
    for (uint32 i = 0; i < bodyEntities.length; i++) {
      PositionData memory position = Position.get(bodyEntities[i].scale, bodyEntities[i].entityId);
      voxelCoords[i] = VoxelCoord(position.x, position.y, position.z);
    }
    return voxelCoords;
  }
}
