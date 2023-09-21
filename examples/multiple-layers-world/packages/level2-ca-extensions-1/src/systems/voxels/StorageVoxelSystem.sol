// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { Storage, StorageData } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, StorageVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection, BlockHeightUpdate, ComponentDef } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant StorageVoxelVariantID = bytes32(keccak256("storage"));

string constant StorageTexture = "bafkreidq36bqpc6fno5vtoafgn7zhyrin2v5wkjfybhqfnrgec4pmlf5we";

string constant StorageUVWrap = "bafkreifdtu65gok35bevprpupxucirs2tan2k77444sl67stdhdgzwffra";

contract StorageVoxelSystem is VoxelType {
  function registerBody() public override {
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
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Storage",
      StorageVoxelID,
      baseVoxelTypeId,
      storageChildVoxelTypes,
      storageChildVoxelTypes,
      StorageVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).extension1_StorageVoxelSyst_enterWorld.selector,
        IWorld(world).extension1_StorageVoxelSyst_exitWorld.selector,
        IWorld(world).extension1_StorageVoxelSyst_variantSelector.selector,
        IWorld(world).extension1_StorageVoxelSyst_activate.selector,
        IWorld(world).extension1_StorageVoxelSyst_eventHandler.selector
      ),
      abi.encode(componentDefs)
    );

    registerCAVoxelType(CA_ADDRESS, StorageVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
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

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Storage.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return StorageVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory, bytes[] memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).extension1_StorageSystem_eventHandlerStorage(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }
}
