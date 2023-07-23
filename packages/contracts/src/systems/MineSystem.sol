// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { VoxelCoord } from "@tenet-registry/src/Types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData, OfSpawn, Spawn, SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { AirID } from "./voxels/AirVoxelSystem.sol";
import { safeCall, isCAAllowed, enterVoxelIntoWorld, exitVoxelFromWorld, updateVoxelVariant, addressToEntityKey, safeStaticCallFunctionSelector, getVoxelVariant, removeEntityFromArray } from "@tenet-contracts/src/Utils.sol";
import { Utils } from "@latticexyz/world/src/Utils.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { Occurrence } from "@tenet-contracts/src/codegen/Tables.sol";
import { console } from "forge-std/console.sol";
import { CAVoxelType, CAVoxelTypeData, CAVoxelTypeDefs } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y, REGISTRY_WORLD_STORE, BASE_CA_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { getEntitiesAtCoord } from "./VoxelInteractionSystem.sol";
import { add } from "./VoxelInteractionSystem.sol";

contract MineSystem is System {
  function mine(VoxelCoord memory coord, bytes32 voxelTypeId) public returns (bytes32) {
    uint256 scaleId = 0;

    // Check ECS blocks at coord
    bytes32[][] memory entitiesAtPosition = getEntitiesAtCoord(coord);
    bytes32 voxelToMine;
    if (entitiesAtPosition.length == 0) {
      revert("Not supported yet");
    } else {
      for (uint256 i = 0; i < entitiesAtPosition.length; i++) {
        uint256 entityScaleId = uint256(entitiesAtPosition[i][0]);
        if (entityScaleId == scaleId) {
          voxelToMine = entitiesAtPosition[i][1];
          break;
        }
      }
      require(voxelToMine != 0, "No voxels found at that position and scale");
      VoxelTypeData memory voxelTypeData = VoxelType.get(scaleId, voxelToMine);
      require(
        voxelTypeData.voxelTypeId == voxelTypeId,
        "The voxel at this position is not the same as the voxel you are trying to mine"
      );

      address caAddress = VoxelTypeRegistry.get(REGISTRY_WORLD_STORE, voxelTypeId).caAddress;
      require(isCAAllowed(caAddress), "Invalid CA address");

      address workingCaAddress = caAddress;
      if (workingCaAddress != BASE_CA_ADDRESS) {
        scaleId += 1;
        // Read the ChildTypes in this CA address
        bytes32[] childVoxelTypeIds = CAVoxelTypeDefs.get(IStore(caAddress), voxelTypeId);
        require(childVoxelTypeIds.length == 8, "Invalid length of child voxel type ids");

        // TODO: move this to a library
        VoxelCoord[] memory eightBlockVoxelCoords = new VoxelCoord[](8);
        eightBlockVoxelCoords[0] = VoxelCoord({ x: 0, y: 0, z: 0 });
        eightBlockVoxelCoords[1] = VoxelCoord({ x: 1, y: 0, z: 0 });
        eightBlockVoxelCoords[2] = VoxelCoord({ x: 0, y: 1, z: 0 });
        eightBlockVoxelCoords[3] = VoxelCoord({ x: 1, y: 1, z: 0 });
        eightBlockVoxelCoords[4] = VoxelCoord({ x: 0, y: 0, z: 1 });
        eightBlockVoxelCoords[5] = VoxelCoord({ x: 1, y: 0, z: 1 });
        eightBlockVoxelCoords[6] = VoxelCoord({ x: 0, y: 1, z: 1 });
        eightBlockVoxelCoords[7] = VoxelCoord({ x: 1, y: 1, z: 1 });

        for (uint8 i = 0; i < 8; i++) {
          VoxelCoord useCoord = buildVoxelType(childVoxelTypeIds[i], add(coord, eightBlockVoxelCoords[i]));
          mine(useCoord, childVoxelTypeIds[i]);
        }
      }

      // Exit World
      IWorld(_world()).tenet_VoxInteractSys_exitCA(caAddress, voxelToMine);

      // Set initial voxel type
      // TODO: Need to use _world() instead of address(this) here
      CAVoxelTypeData memory entityCAVoxelType = IWorld(_world()).tenet_VoxInteractSys_readCAVoxelTypes(
        caAddress,
        voxelToMine
      );
      VoxelType.set(scaleId, voxelToMine, entityCAVoxelType.voxelTypeId, entityCAVoxelType.voxelVariantId);

      IWorld(_world()).tenet_VoxInteractSys_runCA(caAddress, scaleId, voxelToMine);
    }

    // Need to figure out which CA to call

    // require(voxelTypeId != AirID, "can not mine air");
    // require(coord.y <= CHUNK_MAX_Y && coord.y >= CHUNK_MIN_Y, "out of chunk bounds");

    // bytes32 voxelToMine;
    // bytes32 airEntity;

    // // Create an ECS voxel from this coord's terrain voxel
    // bytes16 namespace = Utils.systemNamespace();

    // if (entitiesAtPosition.length == 0) {
    //   // If there is no entity at this position, try mining the terrain voxel at this position
    //   bytes memory occurrence = safeStaticCallFunctionSelector(
    //     _world(),
    //     Occurrence.get(voxelTypeId),
    //     abi.encode(coord)
    //   );
    //   require(occurrence.length > 0, "invalid terrain voxel type");
    //   VoxelVariantsKey memory occurenceVoxelKey = abi.decode(occurrence, (VoxelVariantsKey));
    //   require(
    //     occurenceVoxelKey.voxelVariantNamespace == voxelVariantNamespace &&
    //       occurenceVoxelKey.voxelVariantId == voxelVariantId,
    //     "invalid terrain voxel variant"
    //   );

    //   // Create an ECS voxel from this coord's terrain voxel
    //   voxelToMine = getUniqueEntity();
    //   // in terrain gen, we know its our system namespace and we validated it above using the Occurrence table
    //   VoxelType.set(0, voxelToMine, voxelTypeId, voxelVariantId);
    // } else {
    //   // Else, mine the non-air entity voxel at this position
    //   require(entitiesAtPosition.length == 1, "there should only be one entity at this position");
    //   voxelToMine = entitiesAtPosition[0];
    //   VoxelTypeData memory voxelTypeData = VoxelType.get(0, voxelToMine);
    //   require(voxelToMine != 0, "We found no voxels at that position");
    //   require(
    //     bytes16(0) == voxelTypeNamespace &&
    //       voxelTypeData.voxelTypeId == voxelTypeId &&
    //       // voxelTypeData.voxelVariantNamespace == voxelVariantNamespace &&
    //       voxelTypeData.voxelVariantId == voxelVariantId,
    //     "The voxel at this position is not the same as the voxel you are trying to mine"
    //   );
    //   tryRemoveVoxelFromSpawn(voxelToMine);
    //   Position.deleteRecord(0, voxelToMine);
    //   exitVoxelFromWorld(_world(), voxelToMine);
    //   VoxelType.set(0, voxelToMine, voxelTypeData.voxelTypeId, "");
    // }

    // // Place an air voxel at this position
    // airEntity = getUniqueEntity();
    // // TODO: We don't need necessarily need to get the air voxel type from the registry, we could just use the AirID
    // // Maybe consider doing this for performance reasons
    // VoxelType.set(0, airEntity, AirID, "");
    // Position.set(0, airEntity, coord.x, coord.y, coord.z);
    // enterVoxelIntoWorld(_world(), airEntity);
    // updateVoxelVariant(_world(), airEntity);

    // OwnedBy.set(voxelToMine, addressToEntityKey(_msgSender()));
    // // Since numUniqueVoxelTypesIOwn is quadratic in gas (based on how many voxels you own), running this function could use up all your gas. So it's commented
    // //    require(IWorld(_world()).tenet_GiftVoxelSystem_numUniqueVoxelTypesIOwn() <= 36, "you can only own 36 voxel types at a time");

    // // Run voxel interaction logic
    // IWorld(_world()).tenet_VoxInteractSys_runInteractionSystems(airEntity);

    return voxelToMine;
  }

  function tryRemoveVoxelFromSpawn(bytes32 voxel) internal {
    bytes32 spawnId = OfSpawn.get(voxel);
    if (spawnId == 0) {
      return;
    }

    OfSpawn.deleteRecord(voxel);
    SpawnData memory spawn = Spawn.get(spawnId);
    // should we check to see if the entity is in the array before trying to remove it?
    // I think it's ok to assume it's there, since this is the only way to remove a voxel from a spawn
    bytes32[] memory newVoxels = removeEntityFromArray(spawn.voxels, voxel);

    if (newVoxels.length == 0) {
      // no more voxels of this spawn are in the world, so delete it
      Spawn.deleteRecord(spawnId);
    } else {
      // This spawn is still in the world, but it has been modified (since a voxel was removed)
      Spawn.setVoxels(spawnId, newVoxels);
      Spawn.setIsModified(spawnId, true);
    }
  }

  function clearCoord(VoxelCoord memory coord) public returns (bytes32) {
    bytes32[][] memory entitiesAtPosition = getEntitiesAtCoord(coord);
    bytes32 minedEntity = 0;
    for (uint256 i = 0; i < entitiesAtPosition.length; i++) {
      bytes32 entity = entitiesAtPosition[0][i];

      VoxelTypeData memory voxelTypeData = VoxelType.get(0, entity);
      if (voxelTypeData.voxelTypeId == AirID) {
        // if it's air, then it's already clear
        continue;
      }
      minedEntity = mine(coord, voxelTypeData.voxelTypeId);
    }
    return minedEntity;
  }
}
