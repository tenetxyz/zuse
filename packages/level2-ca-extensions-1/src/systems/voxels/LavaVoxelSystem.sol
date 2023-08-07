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
import { CA_ADDRESS, REGISTRY_ADDRESS, LavaVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant LavaHotVoxelVariantID = bytes32(keccak256("lava.hot"));
bytes32 constant LavaColdVoxelVariantID = bytes32(keccak256("lava.cold"));

string constant LavaHotTexture = "bafkreib4fqqy6y52ng6hupeu5gfxegoh5imbddutfsr7bbkzgfxdhvlmzu";
string constant LavaColdTexture = "bafkreie4o6lycwzopnlwclm2aq2erodgjhu6dmmcfdpgwpyyubnnllu67a";

string constant LavaHotUVWrap = "bafkreic7cbg2d5llpndtr4svt447egqyazffj54ztjwrwx665tl2ghw2gu";
string constant LavaColdUVWrap = "bafkreigqpljgmycgnw5qdelq6vz2g43ximv54xqgilrjoejembqwgkix5e";

contract LavaVoxelSystem is VoxelType {
  function registerVoxel() public override {
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

    bytes32[] memory lavaChildVoxelTypes = VoxelTypeRegistry.getChildVoxelTypeIds(
      IStore(REGISTRY_ADDRESS),
      Level2AirVoxelID
    );
    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Lava",
      LavaVoxelID,
      baseVoxelTypeId,
      lavaChildVoxelTypes,
      lavaChildVoxelTypes,
      LavaHotVoxelVariantID
    );

    registerCAVoxelType(
      CA_ADDRESS,
      LavaVoxelID,
      IWorld(world).extension1_LavaVoxelSystem_enterWorld.selector,
      IWorld(world).extension1_LavaVoxelSystem_exitWorld.selector,
      IWorld(world).extension1_LavaVoxelSystem_variantSelector.selector,
      IWorld(world).extension1_LavaVoxelSystem_activate.selector,
      IWorld(world).extension1_LavaVoxelSystem_eventHandler.selector
    );
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Temperature.set(
      callerAddress,
      entity,
      TemperatureData({ temperature: 92000, lastUpdateBlock: block.number, hasValue: true })
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
    if (temperatureData.temperature > 30000) {
      return LavaHotVoxelVariantID;
    } else {
      return LavaColdVoxelVariantID;
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
