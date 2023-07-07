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


bytes32 constant LavaID = bytes32(keccak256("lava"));

bytes32 constant LavaHotID = bytes32(keccak256("lava.hot"));
bytes32 constant LavaColdID = bytes32(keccak256("lava.cold"));

string constant LavaHotTexture = "bafkreib4fqqy6y52ng6hupeu5gfxegoh5imbddutfsr7bbkzgfxdhvlmzu";
string constant LavaColdTexture = "bafkreie4o6lycwzopnlwclm2aq2erodgjhu6dmmcfdpgwpyyubnnllu67a";

string constant LavaHotUVWrap = "bafkreic7cbg2d5llpndtr4svt447egqyazffj54ztjwrwx665tl2ghw2gu";
string constant LavaColdUVWrap = "bafkreigqpljgmycgnw5qdelq6vz2g43ximv54xqgilrjoejembqwgkix5e";

contract LavaVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory lavaHotVariant;
    lavaHotVariant.blockType = NoaBlockType.BLOCK;
    lavaHotVariant.opaque = true;
    lavaHotVariant.solid = true;
    string[] memory lavaHotMaterials = new string[](1);
    lavaHotMaterials[0] = LavaHotTexture;
    lavaHotVariant.materials = abi.encode(lavaHotMaterials);
    lavaHotVariant.uvWrap = LavaHotUVWrap;
    registerVoxelVariant(world, LavaHotID, lavaHotVariant);

    VoxelVariantsData memory lavaColdVariant;
    lavaColdVariant.blockType = NoaBlockType.BLOCK;
    lavaColdVariant.opaque = true;
    lavaColdVariant.solid = true;
    string[] memory lavaColdMaterials = new string[](1);
    lavaColdMaterials[0] = LavaColdTexture;
    lavaColdVariant.materials = abi.encode(lavaColdMaterials);
    lavaColdVariant.uvWrap = LavaColdUVWrap;
    registerVoxelVariant(world, LavaColdID, lavaColdVariant);

    registerVoxelType(
      world,
      "Lava",
      LavaID,
      LavaHotTexture,
      IWorld(world).extension_LavaVoxelSystem_signalVariantSelector.selector
    );
  }

  function signalVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    TemperatureData memory temperatureData = getOrCreateTemperature(entity);
    if (temperatureData.temperature > 30000) {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: LavaHotID });
    } else {
      return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: LavaColdID });
    }
  }

  function getOrCreateTemperature(bytes32 entity) public returns (TemperatureData memory) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    if (!entityHasTemperature(entity, callerNamespace)) {
      Temperature.set(
        callerNamespace,
        entity,
        TemperatureData({ temperature: 92000, lastUpdateBlock: block.number, hasValue: true })
      );
    }

    return Temperature.get(callerNamespace, entity);
  }
}
