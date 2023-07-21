// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { CATypes, VoxelTypeData, Position, PositionData, BasePosition } from "@tenet-contracts/src/codegen/Tables.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { BlockDirection } from "@tenet-contracts/src/Types.sol";

contract ComposedCASystem is System {
  function defineChildTypes() public {
    // Called once to populate ChildType for this CA
    VoxelTypeData[] memory roadVoxels = new VoxelTypeData[](4);
    VoxelCoord[] memory roadVoxelCoords = new VoxelCoord[](4);
    CATypes.set(LaneID, roadVoxels, roadVoxelCoords);

    // require statement on the number of child voxels
  }

  function enterWorld(VoxelTypeData memory voxelType, bytes32 entity, bytes32[] memory childEntities) public {
    address callerAddress = msg.sender;

    VoxelVariantsKey memory voxelVariantData = updateVoxelVariant(entity);
    ComposedType.set(callerAddress, entity, voxelVariantData);

    ChildEntities.set(callerAddress, entity, childEntities);
  }

  function exitWorld(bytes32 entity) public {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    // call exitWorld() in other contracts
    ComposedType.deleteRecord(callerNamespace, entity);
    ChildEntities.deleteRecord(callerNamespace, entity);
  }

  // called by world
  function runInteraction(
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32[] memory parentEntityIds
  ) public {
    // update ComposedType
    address callerAddress = msg.sender;
    VoxelType entityType = ComposedType.get(calledAddress, interactEntity);
    if(entityType == Gold){
        bytes32 particleEntities = ChildEntities.get(callerAddress, interactEntity);
        for(particleEntity in particleEntities) {
            VoxelType particleType = callerAddress.readVoxelType(particleEntity);
            // do logic, update state
            // ComposedType.set()

        }

        // define valid movements
        // request world to move child entities
        callerAddress.changeType(interactEntity, direction);
    }

  }
}
