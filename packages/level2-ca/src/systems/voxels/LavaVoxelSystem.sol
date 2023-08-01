// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig, Temperature, TemperatureData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, LavaVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

bytes32 constant LavaHotVoxelVariantID = bytes32(keccak256("lava.hot"));
bytes32 constant LavaColdVoxelVariantID = bytes32(keccak256("lava.cold"));

string constant LavaHotTexture = "bafkreib4fqqy6y52ng6hupeu5gfxegoh5imbddutfsr7bbkzgfxdhvlmzu";
string constant LavaColdTexture = "bafkreie4o6lycwzopnlwclm2aq2erodgjhu6dmmcfdpgwpyyubnnllu67a";

string constant LavaHotUVWrap = "bafkreic7cbg2d5llpndtr4svt447egqyazffj54ztjwrwx665tl2ghw2gu";
string constant LavaColdUVWrap = "bafkreigqpljgmycgnw5qdelq6vz2g43ximv54xqgilrjoejembqwgkix5e";

contract LavaVoxelSystem is System {
  function registerVoxelLava() public {
    address world = _world();

    VoxelVariantsRegistryData memory lavaHotVariant;
    lavaHotVariant.blockType = NoaBlockType.BLOCK;
    lavaHotVariant.opaque = true;
    lavaHotVariant.solid = true;
    string[] memory lavaHotMaterials = new string[](1);
    lavaHotMaterials[0] = LavaHotTexture;
    lavaHotVariant.materials = abi.encode(lavaHotMaterials);
    lavaHotVariant.uvWrap = LavaHotUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, LavaHotVoxelVariantID, lavaHotVariant);

    VoxelVariantsRegistryData memory lavaColdVariant;
    lavaColdVariant.blockType = NoaBlockType.BLOCK;
    lavaColdVariant.opaque = true;
    lavaColdVariant.solid = true;
    string[] memory lavaColdMaterials = new string[](1);
    lavaColdMaterials[0] = LavaColdTexture;
    lavaColdVariant.materials = abi.encode(lavaColdMaterials);
    lavaColdVariant.uvWrap = LavaColdUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, LavaColdVoxelVariantID, lavaColdVariant);

    bytes32[] memory lavaChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      lavaChildVoxelTypes[i] = AirVoxelID;
    }
    bytes32 baseVoxelTypeId = LavaVoxelID;
    registerVoxelType(REGISTRY_ADDRESS, "Lava", LavaVoxelID, baseVoxelTypeId, lavaChildVoxelTypes, lavaChildVoxelTypes, LavaHotVoxelVariantID);

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      LavaVoxelID,
      IWorld(world).enterWorldLava.selector,
      IWorld(world).exitWorldLava.selector,
      IWorld(world).variantSelectorLava.selector,
      IWorld(world).activateSelectorLava.selector
    );
  }

  function enterWorldLava(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    Temperature.set(
      callerAddress,
      entity,
      TemperatureData({ temperature: 92000, lastUpdateBlock: block.number, hasValue: true })
    );
  }

  function exitWorldLava(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    Temperature.deleteRecord(callerAddress, entity);
  }

  function variantSelectorLava(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    TemperatureData memory temperatureData = Temperature.get(callerAddress, entity);
    if (temperatureData.temperature > 30000) {
      return LavaHotVoxelVariantID;
    } else {
      return LavaColdVoxelVariantID;
    }
  }

  function activateSelectorLava(address callerAddress, bytes32 entity) public view returns (string memory) {
    TemperatureData memory temperatureData = Temperature.get(callerAddress, entity);
    if (temperatureData.hasValue) {
      return string.concat("temperature: ", Strings.toString(temperatureData.temperature));
    }
  }
}
