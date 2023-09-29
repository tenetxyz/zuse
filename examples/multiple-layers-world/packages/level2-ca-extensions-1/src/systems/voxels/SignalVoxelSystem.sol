// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { Signal, SignalData } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, SignalVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection, ComponentDef } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant SignalOffVoxelVariantID = bytes32(keccak256("signal.off"));
bytes32 constant SignalOnVoxelVariantID = bytes32(keccak256("signal.on"));

string constant SignalOffTexture = "bafkreihofjdel3lyz2vbqq6txdujbjvg2mqsaeczxeb7gszj2ltmhpinui";
string constant SignalOnTexture = "bafkreihitx2k2hpnqnxmdpc5qgsuexeqkvshlezzfwzdh7u3av6x3ar7qy";

string constant SignalOffUVWrap = "bafkreifdtu65gok35bevprpupxucirs2tan2k77444sl67stdhdgzwffra";
string constant SignalOnUVWrap = "bafkreib3vwppyquoziyisfjz3eodmtg6nneenkp2ejy7e3itycdfamm2ye";

contract SignalVoxelSystem is VoxelType {
  function registerBody() public override {
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

    bytes32[] memory signalChildVoxelTypes = VoxelTypeRegistry.getChildVoxelTypeIds(
      IStore(REGISTRY_ADDRESS),
      Level2AirVoxelID
    );
    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Signal",
      SignalVoxelID,
      baseVoxelTypeId,
      signalChildVoxelTypes,
      signalChildVoxelTypes,
      SignalOffVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).extension1_SignalVoxelSyste_enterWorld.selector,
        IWorld(world).extension1_SignalVoxelSyste_exitWorld.selector,
        IWorld(world).extension1_SignalVoxelSyste_variantSelector.selector,
        IWorld(world).extension1_SignalVoxelSyste_activate.selector,
        IWorld(world).extension1_SignalVoxelSyste_eventHandler.selector,
        IWorld(world).extension1_SignalVoxelSyste_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs)
    );

    registerCAVoxelType(CA_ADDRESS, SignalVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Signal.set(callerAddress, entity, SignalData({ isActive: false, direction: BlockDirection.None, hasValue: true }));
  }

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Signal.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    address callerAddress = super.getCallerAddress();
    SignalData memory signalData = Signal.get(callerAddress, entity);
    if (signalData.isActive) {
      return SignalOnVoxelVariantID;
    } else {
      return SignalOffVoxelVariantID;
    }
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).extension1_SignalSystem_eventHandlerSignal(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();

    return
      IWorld(_world()).extension1_SignalSystem_neighbourEventHandlerSignal(
        callerAddress,
        neighbourEntityId,
        centerEntityId
      );
  }
}
