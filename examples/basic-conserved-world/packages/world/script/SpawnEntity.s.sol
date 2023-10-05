// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { SHARD_DIM } from "@tenet-level1-ca/src/Constants.sol";
import { BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";
import { TerrainProperties, TerrainPropertiesTableId, VoxelTypeProperties } from "@tenet-world/src/codegen/Tables.sol";
import { FighterVoxelID, GrassVoxelID, AirVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { calculateChildCoords, getEntityAtCoord, calculateParentCoord } from "@tenet-base-world/src/Utils.sol";

contract SpawnEntity is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // Call world init function
    IWorld world = IWorld(worldAddress);
    IStore store = IStore(worldAddress);

    VoxelEntity memory faucetEntity = VoxelEntity({
      scale: 1,
      entityId: bytes32(0x0000000000000000000000000000000000000000000000000000000000000001)
    });

    bytes32 voxelTypeId = FighterVoxelID;
    VoxelCoord memory coord = VoxelCoord({ x: 10, y: 2, z: 11 });
    world.claimAgentFromFaucet(faucetEntity, voxelTypeId, coord);
    // uint256 initMass = VoxelTypeProperties.get(store, voxelTypeId);
    // uint256 initEnergy = 100;
    // VoxelCoord memory initVelocity = VoxelCoord({ x: 0, y: 0, z: 0 });
    // world.spawnBody(voxelTypeId, coord, bytes4(0), initMass, initEnergy, initVelocity);

    // TODO: remove, were used for testing collision
    // world.spawnBody(GrassVoxelID, VoxelCoord(10, 2, 11), bytes4(0));
    // world.spawnBody(GrassVoxelID, VoxelCoord(10, 2, 13), bytes4(0));
    // world.moveWithAgent(GrassVoxelID, VoxelCoord(10, 2, 15), VoxelCoord(10, 2, 16), grassEntity);

    vm.stopBroadcast();
  }
}
