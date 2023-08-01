// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig, PowerWire, PowerWireData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, PowerWireVoxelID, Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant PowerWireOffVoxelVariantID = bytes32(keccak256("powerwire.off"));
bytes32 constant PowerWireOnVoxelVariantID = bytes32(keccak256("powerwire.on"));
bytes32 constant PowerWireBrokenVoxelVariantID = bytes32(keccak256("powerwire.broken"));

string constant PowerWireOnTexture = "bafkreibmk2qi52v4atyfka3x5ygj44vfig7ks4jz6xzxqfdzduux3fqifa";
string constant PowerWireOffTexture = "bafkreia5773gxqcwqxaumba55oqhtpxc2rkfe7ztq32kcjimbmat36lsau";
string constant PowerWireBrokenTexture = "bafkreif52wl2kr4tjvzr2nou3vxwhswjrkknqdc3g7c4pyquiuhlcplw5a";

contract PowerWireVoxelSystem is System {
  function registerVoxelPowerWire() public {
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

    bytes32[] memory powerWireChildVoxelTypes = VoxelTypeRegistry.getChildVoxelTypeIds(IStore(REGISTRY_ADDRESS), Level2AirVoxelID);
    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Power Wire",
      PowerWireVoxelID,
      baseVoxelTypeId,
      powerWireChildVoxelTypes,
      powerWireChildVoxelTypes,
      PowerWireOffVoxelVariantID
    );

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      PowerWireVoxelID,
      IWorld(world).enterWorldPowerWire.selector,
      IWorld(world).exitWorldPowerWire.selector,
      IWorld(world).variantSelectorPowerWire.selector,
      IWorld(world).activateSelectorPowerWire.selector,
      IWorld(world).eventHandlerPowerWire.selector
    );
  }

  function enterWorldPowerWire(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
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

  function exitWorldPowerWire(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    PowerWire.deleteRecord(callerAddress, entity);
  }

  function variantSelectorPowerWire(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
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

  function activateSelectorPowerWire(address callerAddress, bytes32 entity) public view returns (string memory) {}
}
