// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig, Signal, SignalData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, SignalVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant SignalOffVoxelVariantID = bytes32(keccak256("signal.off"));
bytes32 constant SignalOnVoxelVariantID = bytes32(keccak256("signal.on"));

string constant SignalOffTexture = "bafkreihofjdel3lyz2vbqq6txdujbjvg2mqsaeczxeb7gszj2ltmhpinui";
string constant SignalOnTexture = "bafkreihitx2k2hpnqnxmdpc5qgsuexeqkvshlezzfwzdh7u3av6x3ar7qy";

string constant SignalOffUVWrap = "bafkreifdtu65gok35bevprpupxucirs2tan2k77444sl67stdhdgzwffra";
string constant SignalOnUVWrap = "bafkreib3vwppyquoziyisfjz3eodmtg6nneenkp2ejy7e3itycdfamm2ye";

contract SignalVoxelSystem is System {
  function registerVoxelSignal() public {
    address world = _world();

    VoxelVariantsRegistryData memory signalOffVariant;
    signalOffVariant.blockType = NoaBlockType.BLOCK;
    signalOffVariant.opaque = true;
    signalOffVariant.solid = true;
    string[] memory signalOffMaterials = new string[](1);
    signalOffMaterials[0] = SignalOffTexture;
    signalOffVariant.materials = abi.encode(signalOffMaterials);
    signalOffVariant.uvWrap = SignalOffUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, SignalOffVoxelVariantID, signalOffVariant);

    VoxelVariantsRegistryData memory signalOnVariant;
    signalOnVariant.blockType = NoaBlockType.BLOCK;
    signalOnVariant.opaque = true;
    signalOnVariant.solid = true;
    string[] memory signalOnMaterials = new string[](1);
    signalOnMaterials[0] = SignalOnTexture;
    signalOnVariant.materials = abi.encode(signalOnMaterials);
    signalOnVariant.uvWrap = SignalOnUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, SignalOnVoxelVariantID, signalOnVariant);

    bytes32[] memory signalChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      signalChildVoxelTypes[i] = AirVoxelID;
    }
    registerVoxelType(REGISTRY_ADDRESS, "Signal", SignalVoxelID, signalChildVoxelTypes, SignalOffVoxelVariantID);

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      SignalVoxelID,
      IWorld(world).enterWorldSignal.selector,
      IWorld(world).exitWorldSignal.selector,
      IWorld(world).variantSelectorSignal.selector
    );
  }

  function enterWorldSignal(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    Signal.set(callerAddress, entity, SignalData({ isActive: false, direction: BlockDirection.None, hasValue: true }));
  }

  function exitWorldSignal(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    Signal.deleteRecord(callerAddress, entity);
  }

  function variantSelectorSignal(address callerAddress, bytes32 entity) public view returns (bytes32) {
    SignalData memory signalData = Signal.get(callerAddress, entity);
    if (signalData.isActive) {
      return SignalOnVoxelVariantID;
    } else {
      return SignalOffVoxelVariantID;
    }
  }
}
