// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { BodyTypeRegistry } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";
import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { BodyVariantsRegistryData } from "@tenet-registry/src/codegen/tables/BodyVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerBodyVariant, registerBodyType, bodySelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { Generator, GeneratorData } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, ThermoGenVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";
import { Level2AirVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { registerCABodyType } from "@tenet-base-ca/src/CallUtils.sol";

bytes32 constant ThermoGenVoxelVariantID = bytes32(keccak256("thermogen"));

string constant ThermoGenTexture = "bafkreidohfeb5yddppqv6swfjs6s3g7qe44u75ogwaqkky4nolgh7bbafu";

string constant ThermoGenUVWrap = "bafkreigx5gstl4b2fcz62dwex55mstoo7egdcsrmsox6trmiieplcuyalm";

contract ThermoGenVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    BodyVariantsRegistryData memory thermoGenVariant;
    thermoGenVariant.blockType = NoaBlockType.BLOCK;
    thermoGenVariant.opaque = true;
    thermoGenVariant.solid = true;
    string[] memory thermoGenMaterials = new string[](1);
    thermoGenMaterials[0] = ThermoGenTexture;
    thermoGenVariant.materials = abi.encode(thermoGenMaterials);
    thermoGenVariant.uvWrap = ThermoGenUVWrap;
    registerBodyVariant(REGISTRY_ADDRESS, ThermoGenVoxelVariantID, thermoGenVariant);

    bytes32[] memory thermoGenChildBodyTypes = BodyTypeRegistry.getChildBodyTypeIds(
      IStore(REGISTRY_ADDRESS),
      Level2AirVoxelID
    );
    bytes32 baseBodyTypeId = Level2AirVoxelID;
    registerBodyType(
      REGISTRY_ADDRESS,
      "ThermoGen",
      ThermoGenVoxelID,
      baseBodyTypeId,
      thermoGenChildBodyTypes,
      thermoGenChildBodyTypes,
      ThermoGenVoxelVariantID,
      bodySelectorsForVoxel(
        IWorld(world).extension1_ThermoGenVoxelSy_enterWorld.selector,
        IWorld(world).extension1_ThermoGenVoxelSy_exitWorld.selector,
        IWorld(world).extension1_ThermoGenVoxelSy_variantSelector.selector,
        IWorld(world).extension1_ThermoGenVoxelSy_activate.selector,
        IWorld(world).extension1_ThermoGenVoxelSy_eventHandler.selector
      )
    );

    registerCABodyType(CA_ADDRESS, ThermoGenVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    bytes32[] memory sources = new bytes32[](0);
    BlockDirection[] memory sourceDirections = new BlockDirection[](0);
    uint256 genRate = 0;
    bool hasValue = true;
    Generator.set(
      callerAddress,
      entity,
      GeneratorData({
        genRate: genRate,
        sources: sources,
        sourceDirections: abi.encode(sourceDirections),
        hasValue: true
      })
    );
  }

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Generator.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ThermoGenVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {
    address callerAddress = super.getCallerAddress();
    GeneratorData memory generatorData = Generator.get(callerAddress, entity);
    if (generatorData.hasValue) {
      return string.concat("genRate: ", Strings.toString(generatorData.genRate));
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
      IWorld(_world()).extension1_ThermoGeneratorS_eventHandlerThermoGenerator(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }
}
