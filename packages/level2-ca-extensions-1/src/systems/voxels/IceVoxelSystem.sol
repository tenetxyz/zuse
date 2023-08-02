// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
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

contract IceVoxelSystem is System {
  function registerVoxelIce() public {
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
      IceColdVoxelVariantID
    );

    registerCAVoxelType(
      CA_ADDRESS,
      IceVoxelID,
      IWorld(world).enterWorldIce.selector,
      IWorld(world).exitWorldIce.selector,
      IWorld(world).variantSelectorIce.selector,
      IWorld(world).activateSelectorIce.selector,
      IWorld(world).eventHandlerTemperature.selector
    );
  }

  function enterWorldIce(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    Temperature.set(
      callerAddress,
      entity,
      TemperatureData({ temperature: 0, lastUpdateBlock: block.number, hasValue: true })
    );
  }

  function exitWorldIce(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    Temperature.deleteRecord(callerAddress, entity);
  }

  function variantSelectorIce(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    TemperatureData memory temperatureData = Temperature.get(callerAddress, entity);
    if (temperatureData.temperature > 15000) {
      return IceHotVoxelVariantID;
    } else {
      return IceColdVoxelVariantID;
    }
  }

  function activateSelectorIce(address callerAddress, bytes32 entity) public view returns (string memory) {
    TemperatureData memory temperatureData = Temperature.get(callerAddress, entity);
    if (temperatureData.hasValue) {
      return string.concat("temperature: ", Strings.toString(temperatureData.temperature));
    }
  }
}
