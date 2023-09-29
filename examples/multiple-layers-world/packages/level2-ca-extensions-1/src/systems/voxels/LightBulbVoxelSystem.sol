// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { Consumer, ConsumerData } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, LightBulbVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection, ComponentDef } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant LightBulbOffVoxelVariantID = bytes32(keccak256("lightbulb.off"));
bytes32 constant LightBulbOnVoxelVariantID = bytes32(keccak256("lightbulb.on"));

string constant LightBulbOffTexture = "bafkreihaz4jaes4rix623okfyvai64jnkqwofpffamje7kgkfwemvrpiha";
string constant LightBulbOnTexture = "bafkreifcm3mxlydwxpsflgvmltyyalpus24fo2tm7dmervb2z3hwt5juuu";

contract LightBulbVoxelSystem is VoxelType {
  function registerBody() public override {
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

    bytes32[] memory lightBulbChildVoxelTypes = VoxelTypeRegistry.getChildVoxelTypeIds(
      IStore(REGISTRY_ADDRESS),
      Level2AirVoxelID
    );
    bytes32 baseVoxelTypeId = Level2AirVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Light Bulb",
      LightBulbVoxelID,
      baseVoxelTypeId,
      lightBulbChildVoxelTypes,
      lightBulbChildVoxelTypes,
      LightBulbOffVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).extension1_LightBulbVoxelSy_enterWorld.selector,
        IWorld(world).extension1_LightBulbVoxelSy_exitWorld.selector,
        IWorld(world).extension1_LightBulbVoxelSy_variantSelector.selector,
        IWorld(world).extension1_LightBulbVoxelSy_activate.selector,
        IWorld(world).extension1_LightBulbVoxelSy_eventHandler.selector,
        IWorld(world).extension1_LightBulbVoxelSy_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs)
    );

    registerCAVoxelType(CA_ADDRESS, LightBulbVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
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

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Consumer.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    address callerAddress = super.getCallerAddress();
    ConsumerData memory consumerData = Consumer.get(callerAddress, entity);
    if (consumerData.inRate > 0) {
      return LightBulbOnVoxelVariantID;
    } else {
      return LightBulbOffVoxelVariantID;
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
      IWorld(_world()).extension1_ConsumerSystem_eventHandlerConsumer(
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
      IWorld(_world()).extension1_ConsumerSystem_neighbourEventHandlerConsumer(
        callerAddress,
        neighbourEntityId,
        centerEntityId
      );
  }
}
