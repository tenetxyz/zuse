// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Temperature, TemperatureData } from "../../codegen/Tables.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { VoxelType } from "@tenetxyz/contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";
import { registerVoxelVariant, registerVoxelType, entityHasTemperature } from "../../Utils.sol";
import { VoxelVariantsData, VoxelVariantsKey } from "../../Types.sol";


bytes32 constant IceID = bytes32(keccak256("ice"));

bytes32 constant IceHotID = bytes32(keccak256("ice.hot"));
bytes32 constant IceColdID = bytes32(keccak256("ice.cold"));

string constant IceHotTexture = "bafkreiem2v2nzjci4iratopyk2b37mzhbjj6cgwgrtpec5kr5vm5mm2tma";
string constant IceColdTexture = "bafkreihwvfsy3l3ubp4hfbqrp3byjcftzcqxzgiolf3c7ggkgo22zvouxq";

string constant IceHotUVWrap = "bafkreifzspflrxdiofxp4iczayi2nqszvwipceblpoywspylt7anh3dcu4";
string constant IceColdUVWrap = "bafkreicso63lyy5mj4krdwsmbd7tox5pzscgazvbbk4cz37v7vxr42azjq";

contract IceVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory iceHotVariant;
    iceHotVariant.blockType = NoaBlockType.BLOCK;
    iceHotVariant.opaque = true;
    iceHotVariant.solid = true;
    string[] memory iceHotMaterials = new string[](1);
    iceHotMaterials[0] = IceHotTexture;
    iceHotVariant.materials = abi.encode(iceHotMaterials);
    iceHotVariant.uvWrap = IceHotUVWrap;
    registerVoxelVariant(world, IceHotID, iceHotVariant);

    VoxelVariantsData memory iceColdVariant;
    iceColdVariant.blockType = NoaBlockType.BLOCK;
    iceColdVariant.opaque = true;
    iceColdVariant.solid = true;
    string[] memory iceColdMaterials = new string[](1);
    iceColdMaterials[0] = IceColdTexture;
    iceColdVariant.materials = abi.encode(iceColdMaterials);
    iceColdVariant.uvWrap = IceColdUVWrap;
    registerVoxelVariant(world, IceColdID, iceColdVariant);

    registerVoxelType(
      world,
      "Ice",
      IceID,
      IceColdTexture,
      IWorld(world).extension_IceVoxelSystem_signalVariantSelector.selector
    );
  }

  function signalVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    TemperatureData memory temperatureData = getOrCreateTemperature(entity);
    if (temperatureData.temperature > 15000) {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: IceHotID });
    } else {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: IceColdID });
    }
  }

  function getOrCreateTemperature(bytes32 entity) public returns (TemperatureData memory) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    if (!entityHasTemperature(entity, callerNamespace)) {
      Temperature.set(
        callerNamespace,
        entity,
        TemperatureData({ temperature: 0, lastUpdateBlock: block.number, hasValue: true })
      );
    }

    return Temperature.get(callerNamespace, entity);
  }
}
