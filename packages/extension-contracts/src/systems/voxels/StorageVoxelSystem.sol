// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenet-contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Storage, StorageData } from "@tenet-extension-contracts/src/codegen/Tables.sol";
import { getCallerNamespace } from "@tenet-contracts/src/Utils.sol";
import { registerVoxelType, registerVoxelVariant, entityIsStorage } from "../../Utils.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { VoxelVariantsData } from "@tenet-contracts/src/codegen/tables/VoxelVariants.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";

bytes32 constant StorageID = bytes32(keccak256("storage"));

string constant StorageTexture = "bafkreidq36bqpc6fno5vtoafgn7zhyrin2v5wkjfybhqfnrgec4pmlf5we";

string constant StorageUVWrap = "bafkreifdtu65gok35bevprpupxucirs2tan2k77444sl67stdhdgzwffra";

contract SignalSourceVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory signalSourceVariant;
    signalSourceVariant.blockType = NoaBlockType.BLOCK;
    signalSourceVariant.opaque = true;
    signalSourceVariant.solid = true;
    string[] memory signalSourceMaterials = new string[](1);
    signalSourceMaterials[0] = SignalSourceTexture;
    signalSourceVariant.materials = abi.encode(signalSourceMaterials);
    signalSourceVariant.uvWrap = StorageUVWrap;
    registerVoxelVariant(world, SignalSourceID, signalSourceVariant);

    registerVoxelType(
      world,
      "Storage",
      StorageID,
      EXTENSION_NAMESPACE,
      StorageID,
      IWorld(world).extension_StorageVoxel_variantSelector.selector,
      IWorld(world).extension_StorageVoxel_enterWorld.selector,
      IWorld(world).extension_StorageVoxel_exitWorld.selector,
      IWorld(world).extension_StorageVoxel_activate.selector
    );
  }

  function enterWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    StorageData({ maxStorage: 5000000,
                  energyStored: 0,
                  lastInRate: 0,
                  lastOutRate: 0,
                  lastUpdateBlock: block.number,
                  source: bytes32(0),
                  destination: bytes32(0),
                  sourceDirection: BlockDirection.NONE,
                  destinationDirection: BlockDirection.NONE,
                  hasValue: true })}

  function exitWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    Storage.deleteRecord(callerNamespace, entity);
  }

  function variantSelector(bytes32 entity) public view override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: StorageID });
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
