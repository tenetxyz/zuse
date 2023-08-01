// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig, Consumer, ConsumerData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, LightBulbVoxelID, Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant LightBulbOffVoxelVariantID = bytes32(keccak256("lightbulb.off"));
bytes32 constant LightBulbOnVoxelVariantID = bytes32(keccak256("lightbulb.on"));

string constant LightBulbOffTexture = "bafkreihaz4jaes4rix623okfyvai64jnkqwofpffamje7kgkfwemvrpiha";
string constant LightBulbOnTexture = "bafkreifcm3mxlydwxpsflgvmltyyalpus24fo2tm7dmervb2z3hwt5juuu";

contract LightBulbVoxelSystem is System {
  function registerVoxelLightBulb() public {
    address world = _world();

    VoxelVariantsRegistryData memory lightBulbOffVariant;
    lightBulbOffVariant.blockType = NoaBlockType.MESH;
    lightBulbOffVariant.opaque = false;
    lightBulbOffVariant.solid = false;
    lightBulbOffVariant.frames = 1;
    string[] memory lightBulbOffMaterials = new string[](1);
    lightBulbOffMaterials[0] = LightBulbOffTexture;
    lightBulbOffVariant.materials = abi.encode(lightBulbOffMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, LightBulbOffVoxelVariantID, lightBulbOffVariant);

    VoxelVariantsRegistryData memory lightBulbOnVariant;
    lightBulbOnVariant.blockType = NoaBlockType.MESH;
    lightBulbOnVariant.opaque = false;
    lightBulbOnVariant.solid = false;
    lightBulbOnVariant.frames = 1;
    string[] memory lightBulbOnMaterials = new string[](1);
    lightBulbOnMaterials[0] = LightBulbOnTexture;
    lightBulbOnVariant.materials = abi.encode(lightBulbOnMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, LightBulbOnVoxelVariantID, lightBulbOnVariant);

    bytes32[] memory lightBulbChildVoxelTypes = VoxelTypeRegistry.getChildVoxelTypeIds(IStore(REGISTRY_ADDRESS), Level2AirVoxelID);
    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Light Bulb",
      LightBulbVoxelID,
      baseVoxelTypeId,
      lightBulbChildVoxelTypes,
      lightBulbChildVoxelTypes,
      LightBulbOffVoxelVariantID
    );

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      LightBulbVoxelID,
      IWorld(world).enterWorldLightBulb.selector,
      IWorld(world).exitWorldLightBulb.selector,
      IWorld(world).variantSelectorLightBulb.selector,
      IWorld(world).activateSelectorLightBulb.selector,
      IWorld(world).eventHandlerConsumer.selector
    );
  }

  function enterWorldLightBulb(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    Consumer.set(
      callerAddress,
      entity,
      ConsumerData({
        source: bytes32(0),
        sourceDirection: BlockDirection.None,
        inRate: 0,
        lastUpdateBlock: block.number,
        hasValue: true
      })
    );
  }

  function exitWorldLightBulb(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    Consumer.deleteRecord(callerAddress, entity);
  }

  function variantSelectorLightBulb(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    ConsumerData memory consumerData = Consumer.get(callerAddress, entity);
    if (consumerData.inRate > 0) {
      return LightBulbOnVoxelVariantID;
    } else {
      return LightBulbOffVoxelVariantID;
    }
  }

  function activateSelectorLightBulb(address callerAddress, bytes32 entity) public view returns (string memory) {}
}
