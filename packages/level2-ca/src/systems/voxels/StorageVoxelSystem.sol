// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig, Storage, StorageData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, StorageVoxelID, Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection, BlockHeightUpdate } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant StorageVoxelVariantID = bytes32(keccak256("storage"));

string constant StorageTexture = "bafkreidq36bqpc6fno5vtoafgn7zhyrin2v5wkjfybhqfnrgec4pmlf5we";

string constant StorageUVWrap = "bafkreifdtu65gok35bevprpupxucirs2tan2k77444sl67stdhdgzwffra";

contract StorageVoxelSystem is System {
  function registerVoxelStorage() public {
    address world = _world();

    VoxelVariantsRegistryData memory storageVariant;
    storageVariant.blockType = NoaBlockType.BLOCK;
    storageVariant.opaque = true;
    storageVariant.solid = true;
    string[] memory storageMaterials = new string[](1);
    storageMaterials[0] = StorageTexture;
    storageVariant.materials = abi.encode(storageMaterials);
    storageVariant.uvWrap = StorageUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, StorageVoxelVariantID, storageVariant);

    bytes32[] memory storageChildVoxelTypes = VoxelTypeRegistry.getChildVoxelTypeIds(
      IStore(REGISTRY_ADDRESS),
      Level2AirVoxelID
    );
    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Storage",
      StorageVoxelID,
      baseVoxelTypeId,
      storageChildVoxelTypes,
      storageChildVoxelTypes,
      StorageVoxelVariantID
    );

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      StorageVoxelID,
      IWorld(world).enterWorldStorage.selector,
      IWorld(world).exitWorldStorage.selector,
      IWorld(world).variantSelectorStorage.selector,
      IWorld(world).activateSelectorStorage.selector,
      IWorld(world).eventHandlerStorage.selector
    );
  }

  function enterWorldStorage(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    Storage.set(
      callerAddress,
      entity,
      StorageData({
        maxStorage: 5000000,
        energyStored: 0,
        inRate: 0,
        outRate: 0,
        inBlockHeightUpdate: abi.encode(
          BlockHeightUpdate({ blockNumber: block.number, lastUpdateBlock: block.number, blockHeightDelta: 0 })
        ),
        outBlockHeightUpdate: abi.encode(
          BlockHeightUpdate({ blockNumber: block.number, lastUpdateBlock: block.number, blockHeightDelta: 0 })
        ),
        source: bytes32(0),
        destination: bytes32(0),
        sourceDirection: BlockDirection.None,
        destinationDirection: BlockDirection.None,
        hasValue: true
      })
    );
  }

  function exitWorldStorage(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    Storage.deleteRecord(callerAddress, entity);
  }

  function variantSelectorStorage(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    return StorageVoxelVariantID;
  }

  function activateSelectorStorage(address callerAddress, bytes32 entity) public view returns (string memory) {}
}
