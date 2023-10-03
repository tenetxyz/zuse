// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { Script } from "forge-std/Script.sol";
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

    // BodyPhysicsData memory physicsData;
    // physicsData.mass = 5;
    // physicsData.energy = 1000;
    // physicsData.lastUpdateBlock = block.number;
    // physicsData.velocity = abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 }));
    console.log("init");
    // (bytes32 terrainType, BodyPhysicsData memory terrainData) = IWorld(_world()).getTerrainBodyPhysicsData(
    //   address(0),
    //   VoxelCoord(2, 9, 5)
    // );
    // console.logBytes32(terrainType);
    world.spawnBody(FighterVoxelID, VoxelCoord(-2, -6, 9), bytes4(0), physicsData);

    // world.initWorldState();

    vm.stopBroadcast();
  }
}
