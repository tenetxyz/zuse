// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenet-contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerWire, PowerWireData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { getCallerNamespace } from "@tenet-contracts/src/Utils.sol";
import { registerVoxelType, registerVoxelVariant, entityIsGenerator } from "../../Utils.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { VoxelVariantsData } from "@tenet-contracts/src/codegen/tables/VoxelVariants.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";

bytes32 constant PowerWireID = bytes32(keccak256("powerwire"));

string constant PowerWireTexture = "bafkreidq36bqpc6fno5vtoafgn7zhyrin2v5wkjfybhqfnrgec4pmlf5we";

string constant PowerWireUVWrap = "bafkreifdtu65gok35bevprpupxucirs2tan2k77444sl67stdhdgzwffra";

contract PowerWireVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory signalSourceVariant;
    signalSourceVariant.blockType = NoaBlockType.MESH;
    signalSourceVariant.opaque = false;
    signalSourceVariant.solid = false;
    signalSourceVariant.frames = 1;
    string[] memory signalSourceMaterials = new string[](1);
    signalSourceMaterials[0] = PowerWireTexture;
    signalSourceVariant.materials = abi.encode(signalSourceMaterials);
    signalSourceVariant.uvWrap = PowerWireUVWrap;
    registerVoxelVariant(world, PowerWireID, signalSourceVariant);

    registerVoxelType(
      world,
      "Power Wire",
      PowerWireID,
      EXTENSION_NAMESPACE,
      PowerWireID,
      IWorld(world).extension_PowerWireVoxelSy_variantSelector.selector,
      IWorld(world).extension_PowerWireVoxelSy_enterWorld.selector,
      IWorld(world).extension_PowerWireVoxelSy_exitWorld.selector,
      IWorld(world).extension_PowerWireVoxelSy_activate.selector
    );
  }

  function enterWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    
    bytes32 _source = bytes32(0);
    bytes32 _destination = bytes32(0);

    PowerWire.set(
      callerNamespace,
      entity,
      PowerWireData({ source: _source, destination: _destination, transferRate: 0, maxTransferRate: 30000, direction: BlockDirection.None, hasValue: true })
    );
  }

  function exitWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    PowerWire.deleteRecord(callerNamespace, entity);
  }

  function variantSelector(bytes32 entity) public view override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: PowerWireID });
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
