// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // Call world init function
    IWorld world = IWorld(worldAddress);
    world.registerMassSelectors();
    world.registerEnergySelectors();
    world.registerVelocitySelectors();

    world.registerHealthSelectors();
    world.registerStaminaSelectors();
    world.registerObjectSelectors();
    world.registerActionSelectors();
    world.registerNutrientsSelectors();
    world.registerElixirSelectors();
    world.registerProteinSelectors();
    world.registerNitrogenSelectors();
    world.registerPhosphorousSelectors();
    world.registerPotassiumSelectors();
    world.registerTemperatureSelectors();

    vm.stopBroadcast();
  }
}
