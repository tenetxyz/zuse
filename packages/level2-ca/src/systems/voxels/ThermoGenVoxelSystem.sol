// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig, Generator, GeneratorData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, ThermoGenVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

bytes32 constant ThermoGenVoxelVariantID = bytes32(keccak256("thermogen"));

string constant ThermoGenTexture = "bafkreidohfeb5yddppqv6swfjs6s3g7qe44u75ogwaqkky4nolgh7bbafu";

string constant ThermoGenUVWrap = "bafkreigx5gstl4b2fcz62dwex55mstoo7egdcsrmsox6trmiieplcuyalm";

contract ThermoGenVoxelSystem is System {
  function registerVoxelThermoGen() public {
    address world = _world();

    VoxelVariantsRegistryData memory thermoGenVariant;
    thermoGenVariant.blockType = NoaBlockType.BLOCK;
    thermoGenVariant.opaque = true;
    thermoGenVariant.solid = true;
    string[] memory thermoGenMaterials = new string[](1);
    thermoGenMaterials[0] = ThermoGenTexture;
    thermoGenVariant.materials = abi.encode(thermoGenMaterials);
    thermoGenVariant.uvWrap = ThermoGenUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, ThermoGenVoxelVariantID, thermoGenVariant);

    bytes32[] memory thermoGenChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      thermoGenChildVoxelTypes[i] = AirVoxelID;
    }
    registerVoxelType(
      REGISTRY_ADDRESS,
      "ThermoGen",
      ThermoGenVoxelID,
      thermoGenChildVoxelTypes,
      ThermoGenVoxelVariantID
    );

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      ThermoGenVoxelID,
      IWorld(world).enterWorldThermoGen.selector,
      IWorld(world).exitWorldThermoGen.selector,
      IWorld(world).variantSelectorThermoGen.selector,
      IWorld(world).activateSelectorThermoGen.selector
    );
  }

  function enterWorldThermoGen(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
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

  function exitWorldThermoGen(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {
    Generator.deleteRecord(callerAddress, entity);
  }

  function variantSelectorThermoGen(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    return ThermoGenVoxelVariantID;
  }

  function activateSelectorThermoGen(address callerAddress, bytes32 entity) public view returns (string memory) {
    GeneratorData memory generatorData = Generator.get(callerAddress, entity);
    if (generatorData.hasValue) {
      return string.concat("genRate: ", Strings.toString(generatorData.genRate));
    }
  }
}
