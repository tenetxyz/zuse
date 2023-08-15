// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { PowerWire, PowerWireData } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, PowerWireVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant PowerWireOffVoxelVariantID = bytes32(keccak256("powerwire.off"));
bytes32 constant PowerWireOnVoxelVariantID = bytes32(keccak256("powerwire.on"));
bytes32 constant PowerWireBrokenVoxelVariantID = bytes32(keccak256("powerwire.broken"));

string constant PowerWireOnTexture = "bafkreibmk2qi52v4atyfka3x5ygj44vfig7ks4jz6xzxqfdzduux3fqifa";
string constant PowerWireOffTexture = "bafkreia5773gxqcwqxaumba55oqhtpxc2rkfe7ztq32kcjimbmat36lsau";
string constant PowerWireBrokenTexture = "bafkreif52wl2kr4tjvzr2nou3vxwhswjrkknqdc3g7c4pyquiuhlcplw5a";

contract PowerWireVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsRegistryData memory powerWireOffVariant;
    powerWireOffVariant.blockType = NoaBlockType.MESH;
    powerWireOffVariant.opaque = false;
    powerWireOffVariant.solid = false;
    powerWireOffVariant.frames = 1;
    string[] memory powerWireOffMaterials = new string[](1);
    powerWireOffMaterials[0] = PowerWireOffTexture;
    powerWireOffVariant.materials = abi.encode(powerWireOffMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, PowerWireOffVoxelVariantID, powerWireOffVariant);

    VoxelVariantsRegistryData memory powerWireOnVariant;
    powerWireOnVariant.blockType = NoaBlockType.MESH;
    powerWireOnVariant.opaque = false;
    powerWireOnVariant.solid = false;
    powerWireOnVariant.frames = 1;
    string[] memory powerWireOnMaterials = new string[](1);
    powerWireOnMaterials[0] = PowerWireOnTexture;
    powerWireOnVariant.materials = abi.encode(powerWireOnMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, PowerWireOnVoxelVariantID, powerWireOnVariant);

    VoxelVariantsRegistryData memory powerWireBrokenVariant;
    powerWireBrokenVariant.blockType = NoaBlockType.MESH;
    powerWireBrokenVariant.opaque = false;
    powerWireBrokenVariant.solid = false;
    powerWireBrokenVariant.frames = 1;
    string[] memory powerWireBrokenMaterials = new string[](1);
    powerWireBrokenMaterials[0] = PowerWireBrokenTexture;
    powerWireBrokenVariant.materials = abi.encode(powerWireBrokenMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, PowerWireBrokenVoxelVariantID, powerWireBrokenVariant);

    bytes32[] memory powerWireChildVoxelTypes = VoxelTypeRegistry.getChildVoxelTypeIds(
      IStore(REGISTRY_ADDRESS),
      Level2AirVoxelID
    );

    registerVoxelType(
      REGISTRY_ADDRESS,
      "Power Wire",
      PowerWireVoxelID,
      Level2AirVoxelID,
      powerWireChildVoxelTypes,
      powerWireChildVoxelTypes,
      PowerWireOffVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).extension1_PowerWireVoxelSy_enterWorld.selector,
        IWorld(world).extension1_PowerWireVoxelSy_exitWorld.selector,
        IWorld(world).extension1_PowerWireVoxelSy_variantSelector.selector,
        IWorld(world).extension1_PowerWireVoxelSy_activate.selector,
        IWorld(world).extension1_PowerWireVoxelSy_eventHandler.selector
      )
    );

    registerCAVoxelType(CA_ADDRESS, PowerWireVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    bytes32 _source = bytes32(0);
    bytes32 _destination = bytes32(0);

    PowerWire.set(
      callerAddress,
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

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    PowerWire.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    address callerAddress = super.getCallerAddress();
    PowerWireData memory powerWireData = PowerWire.get(callerAddress, entity);
    if (powerWireData.isBroken) {
      return PowerWireBrokenVoxelVariantID;
    } else {
      if (powerWireData.transferRate > 0) {
        return PowerWireOnVoxelVariantID;
      } else {
        return PowerWireOffVoxelVariantID;
      }
    }
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory) {
    address callerAddress = super.getCallerAddress();

    return
      IWorld(_world()).extension1_PowerWireSystem_eventHandlerPowerWire(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }
}
