// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { FaucetVoxelID, GrassVoxelID, AirVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { GrassPokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

contract SpawnEntity is Script {
  function giveComponents(address worldAddress, bytes32 entity) private {
    Health.set(IStore(SIMULATOR_ADDRESS), worldAddress, 1, entity, 90);
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, 1, entity, 9000);
  }

  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // Call world init function
    IWorld world = IWorld(worldAddress);
    IStore store = IStore(worldAddress);

    bytes32 voxelTypeId = GrassVoxelID;
    VoxelCoord memory coord = VoxelCoord({ x: 12, y: 2, z: 10 });
    uint256 initMass = VoxelTypeRegistry.getMass(IStore(REGISTRY_ADDRESS), voxelTypeId);
    uint256 initEnergy = 100;
    VoxelCoord memory initVelocity = VoxelCoord({ x: 0, y: 0, z: 0 });
    uint256 initStamina = 9000;
    Velocity.setVelocity(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      1,
      bytes32(uint256(0x2a8)),
      abi.encode(VoxelCoord(0, 0, 0))
    );
    Velocity.setVelocity(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      1,
      bytes32(uint256(0x278)),
      abi.encode(VoxelCoord(0, 0, 0))
    );
    // world.spawnBody(voxelTypeId, coord, bytes4(0), initMass, initEnergy, initVelocity, initStamina);
    // world.spawnBody(GrassPokemonVoxelID, VoxelCoord(13, 2, 13), bytes4(0), initMass, initEnergy, initVelocity, initStamina);
    // giveComponents(worldAddress, bytes32(uint256(0xc)));
    // giveComponents(worldAddress, bytes32(uint256(0x2)));

    // TODO: remove, were used for testing collision
    // world.spawnBody(GrassVoxelID, VoxelCoord(10, 2, 13), bytes4(0), 100);
    // world.moveWithAgent(GrassVoxelID, VoxelCoord(10, 2, 15), VoxelCoord(10, 2, 16), grassEntity);

    vm.stopBroadcast();
  }
}
