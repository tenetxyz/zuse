// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { InitWorldSystem } from "@tenet-base-world/src/prototypes/InitWorldSystem.sol";
import { WorldRegistry } from "@tenet-registry/src/codegen/tables/WorldRegistry.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { REGISTER_WORLD_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS } from "../Constants.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { FighterVoxelID, GrassVoxelID, AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { WorldConfig, WorldConfigTableId } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelType, Position, VoxelTypeProperties, BodyPhysics, BodyPhysicsData } from "@tenet-world/src/codegen/Tables.sol";
import { BuildEventData } from "@tenet-base-world/src/Types.sol";

contract InitSystem is InitWorldSystem {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function registerWorld() public {
    address[] memory caAddresses = new address[](1);
    caAddresses[0] = BASE_CA_ADDRESS;

    safeCall(
      REGISTRY_ADDRESS,
      abi.encodeWithSignature(REGISTER_WORLD_SIG, "Tenet Basic World", "Very simple. Very nice.", caAddresses),
      "registerCA"
    );
  }

  function initWorldVoxelTypes() public override {
    super.initWorldVoxelTypes();

    // Set mass voxel types for voxels
    VoxelTypeProperties.set(GrassVoxelID, 5);
    VoxelTypeProperties.set(FighterVoxelID, 10);
  }

  function initWorldState() public {
    // TODO: require only called once by world deployer
    IWorld(_world()).spawnBody(
      FighterVoxelID,
      VoxelCoord(10, 2, 10),
      bytes4(0),
      BodyPhysicsData({ mass: 5, energy: 10, velocity: abi.encode(bytes32(0)), gravity: abi.encode(bytes32(0)) })
    );
  }

  function onNewCAVoxelType(address caAddress, bytes32 voxelTypeId) public override {
    super.onNewCAVoxelType(caAddress, voxelTypeId);
  }

  function isCAAllowed(address caAddress) public view override returns (bool) {
    return super.isCAAllowed(caAddress);
  }

  function isVoxelTypeAllowed(bytes32 voxelTypeId) public view override returns (bool) {
    return super.isVoxelTypeAllowed(voxelTypeId);
  }
}