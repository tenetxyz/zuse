// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { Temperature, TemperatureData } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, IceVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant IceHotVoxelVariantID = bytes32(keccak256("ice.hot"));
bytes32 constant IceColdVoxelVariantID = bytes32(keccak256("ice.cold"));

string constant IceHotTexture = "bafkreiem2v2nzjci4iratopyk2b37mzhbjj6cgwgrtpec5kr5vm5mm2tma";
string constant IceColdTexture = "bafkreihwvfsy3l3ubp4hfbqrp3byjcftzcqxzgiolf3c7ggkgo22zvouxq";

string constant IceHotUVWrap = "bafkreifzspflrxdiofxp4iczayi2nqszvwipceblpoywspylt7anh3dcu4";
string constant IceColdUVWrap = "bafkreicso63lyy5mj4krdwsmbd7tox5pzscgazvbbk4cz37v7vxr42azjq";

contract IceVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsRegistryData memory iceHotVariant;
    iceHotVariant.blockType = NoaBlockType.BLOCK;
    iceHotVariant.opaque = true;
    iceHotVariant.solid = true;
    string[] memory iceHotMaterials = new string[](1);
    iceHotMaterials[0] = IceHotTexture;
    iceHotVariant.materials = abi.encode(iceHotMaterials);
    iceHotVariant.uvWrap = IceHotUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, IceHotVoxelVariantID, iceHotVariant);

    VoxelVariantsRegistryData memory iceColdVariant;
    iceColdVariant.blockType = NoaBlockType.BLOCK;
    iceColdVariant.opaque = true;
    iceColdVariant.solid = true;
    string[] memory iceColdMaterials = new string[](1);
    iceColdMaterials[0] = IceColdTexture;
    iceColdVariant.materials = abi.encode(iceColdMaterials);
    iceColdVariant.uvWrap = IceColdUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, IceColdVoxelVariantID, iceColdVariant);

    bytes32[] memory iceChildVoxelTypes = VoxelTypeRegistry.getChildVoxelTypeIds(
      IStore(REGISTRY_ADDRESS),
      Level2AirVoxelID
    );
    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Ice",
      IceVoxelID,
      baseVoxelTypeId,
      iceChildVoxelTypes,
      iceChildVoxelTypes,
      IceColdVoxelVariantID,
      world
    );

    registerCAVoxelType(
      CA_ADDRESS,
      IceVoxelID,
      IWorld(world).extension1_IceVoxelSystem_enterWorld.selector,
      IWorld(world).extension1_IceVoxelSystem_exitWorld.selector,
      IWorld(world).extension1_IceVoxelSystem_variantSelector.selector,
      IWorld(world).extension1_IceVoxelSystem_activate.selector,
      IWorld(world).extension1_IceVoxelSystem_eventHandler.selector
    );
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Temperature.set(
      callerAddress,
      entity,
      TemperatureData({ temperature: 0, lastUpdateBlock: block.number, hasValue: true })
    );
  }

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Temperature.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    address callerAddress = super.getCallerAddress();
    TemperatureData memory temperatureData = Temperature.get(callerAddress, entity);
    if (temperatureData.temperature > 15000) {
      return IceHotVoxelVariantID;
    } else {
      return IceColdVoxelVariantID;
    }
  }

  function activate(bytes32 entity) public view override returns (string memory) {
    address callerAddress = super.getCallerAddress();
    TemperatureData memory temperatureData = Temperature.get(callerAddress, entity);
    if (temperatureData.hasValue) {
      return string.concat("temperature: ", Strings.toString(temperatureData.temperature));
    }
  }

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory) {
    address callerAddress = super.getCallerAddress();

    return
      IWorld(_world()).extension1_TemperatureSyste_eventHandlerTemperature(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }
}
