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

bytes32 constant PowerWireOffID = bytes32(keccak256("powerwire.off"));
bytes32 constant PowerWireOnID = bytes32(keccak256("powerwire.on"));
bytes32 constant PowerWireBrokenID = bytes32(keccak256("powerwire.broken"));

string constant PowerWireOnTexture = "bafkreibmk2qi52v4atyfka3x5ygj44vfig7ks4jz6xzxqfdzduux3fqifa";
string constant PowerWireOffTexture = "bafkreia5773gxqcwqxaumba55oqhtpxc2rkfe7ztq32kcjimbmat36lsau";
string constant PowerWireBrokenTexture = "bafkreif52wl2kr4tjvzr2nou3vxwhswjrkknqdc3g7c4pyquiuhlcplw5a";

contract PowerWireVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory powerWireOffVariant;
    powerWireOffVariant.blockType = NoaBlockType.MESH;
    powerWireOffVariant.opaque = false;
    powerWireOffVariant.solid = false;
    powerWireOffVariant.frames = 1;
    string[] memory powerWireOffMaterials = new string[](1);
    powerWireOffMaterials[0] = PowerWireOffTexture;
    powerWireOffVariant.materials = abi.encode(powerWireOffMaterials);
    registerVoxelVariant(world, PowerWireOffID, powerWireOffVariant);

    VoxelVariantsData memory powerWireOnVariant;
    powerWireOnVariant.blockType = NoaBlockType.MESH;
    powerWireOnVariant.opaque = false;
    powerWireOnVariant.solid = false;
    powerWireOnVariant.frames = 1;
    string[] memory powerWireOnMaterials = new string[](1);
    powerWireOnMaterials[0] = PowerWireOnTexture;
    powerWireOnVariant.materials = abi.encode(powerWireOnMaterials);
    registerVoxelVariant(world, PowerWireOnID, powerWireOnVariant);

    VoxelVariantsData memory powerWireBrokenVariant;
    powerWireBrokenVariant.blockType = NoaBlockType.MESH;
    powerWireBrokenVariant.opaque = false;
    powerWireBrokenVariant.solid = false;
    powerWireBrokenVariant.frames = 1;
    string[] memory powerWireBrokenMaterials = new string[](1);
    powerWireBrokenMaterials[0] = PowerWireBrokenTexture;
    powerWireBrokenVariant.materials = abi.encode(powerWireBrokenMaterials);
    registerVoxelVariant(world, PowerWireBrokenID, powerWireBrokenVariant);

    registerVoxelType(
      world,
      "Power Wire",
      PowerWireID,
      EXTENSION_NAMESPACE,
      PowerWireOffID,
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
      PowerWireData({
        source: _source,
        destination: _destination,
        transferRate: 0,
        maxTransferRate: 30000,
        lastUpdateBlock: block.number,
        sourceDirection: BlockDirection.None,
        destinationDirection: BlockDirection.None,
        isBroken: false,
        hasValue: true
      })
    );
  }

  function exitWorld(bytes32 entity) public override {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    PowerWire.deleteRecord(callerNamespace, entity);
  }

  function variantSelector(bytes32 entity) public view override returns (VoxelVariantsKey memory) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    PowerWireData memory powerWireData = PowerWire.get(callerNamespace, entity);
    if (powerWireData.isBroken) {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: PowerWireBrokenID });
    } else {
      if (powerWireData.transferRate > 0) {
        return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: PowerWireOnID });
      } else {
        return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: PowerWireOffID });
      }
    }
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
