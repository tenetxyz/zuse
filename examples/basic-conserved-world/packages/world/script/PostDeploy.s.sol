// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { Script } from "forge-std/Script.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { SHARD_DIM } from "@tenet-level1-ca/src/Constants.sol";
import { BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";
import { TerrainProperties, TerrainPropertiesTableId, VoxelTypeProperties } from "@tenet-world/src/codegen/Tables.sol";
import { FighterVoxelID, GrassVoxelID, AirVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // Call world init function
    IWorld world = IWorld(worldAddress);
    IStore store = IStore(worldAddress);

    world.registerWorld();
    world.initWorldVoxelTypes();

    // Set the same terrain selector for 8 cubes around the origin
    VoxelCoord[8] memory specifiedCoords = [
      VoxelCoord({ x: 0, y: 0, z: 0 }),
      VoxelCoord({ x: -1, y: 0, z: 0 }),
      VoxelCoord({ x: 0, y: -1, z: 0 }),
      VoxelCoord({ x: -1, y: -1, z: 0 }),
      VoxelCoord({ x: 0, y: 0, z: -1 }),
      VoxelCoord({ x: -1, y: 0, z: -1 }),
      VoxelCoord({ x: 0, y: -1, z: -1 }),
      VoxelCoord({ x: -1, y: -1, z: -1 })
    ];

    for (uint8 i = 0; i < 8; i++) {
      bytes4 selector = world.getTerrainVoxel.selector;
      world.setTerrainSelector(specifiedCoords[i], worldAddress, selector);
    }

    // TODO: remove when we add buckets
    bytes32 voxelTypeId = FighterVoxelID;
    VoxelCoord memory coord = VoxelCoord({ x: 10, y: 2, z: 10 });
    uint256 initMass = VoxelTypeProperties.get(store, voxelTypeId);
    uint256 initEnergy = 1000;
    VoxelCoord memory initVelocity = VoxelCoord({ x: 0, y: 0, z: 0 });
    world.spawnBody(voxelTypeId, coord, bytes4(0), initMass, initEnergy, initVelocity);

    vm.stopBroadcast();
  }
}
