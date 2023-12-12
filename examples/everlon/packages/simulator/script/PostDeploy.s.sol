// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    IWorld world = IWorld(worldAddress);

    // Register constraints
    world.registerElementSelector();
    world.registerElixirHealthSelector();
    world.registerEnergyElixirSelector();
    world.registerEnergyHealthSelector();
    world.registerEnergyNutrientsSelector();
    world.registerEnergyProteinSelector();
    world.registerEnergyStaminaSelector();
    world.registerEnergyTemperatureSelector();
    world.registerHealthSelector();
    world.registerMassSelector();
    world.registerNitrogenSelector();
    world.registerNutrientsSelector();
    world.registerNutrientsElixirSelector();
    world.registerNutrientsProteinSelector();
    world.registerPhosphorusSelector();
    world.registerPotassiumSelector();
    world.registerProteinStaminaSelector();
    world.registerStaminaCombatMoveSelector();
    world.registerStaminaSelector();
    world.registerStaminaVelocitySelector();
    world.registerTemperatureSelector();
    world.registerTemperatureVelocitySelector();

    vm.stopBroadcast();
  }
}
