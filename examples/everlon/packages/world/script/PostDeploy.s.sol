// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Script } from "forge-std/Script.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    IWorld world = IWorld(worldAddress);

    world.initRecipes();
    world.initRecipesTwo();
    world.initRecipesThree();
    world.initRecipeSysDye();

    world.world_AirObjectSystem_registerObject();

    world.world_SnowObjectSystem_registerObject();
    world.world_AsphaltObjectSys_registerObject();
    world.world_BasaltObjectSyst_registerObject();
    world.world_ClayBrickObjectS_registerObject();
    world.world_CottonObjectSyst_registerObject();

    world.world_StoneObjectSyste_registerObject();
    world.world_EmberstoneObject_registerObject();
    world.world_CobblestoneObjec_registerObject();
    world.world_MoonstoneObjectS_registerObject();
    world.world_QuartziteObjectS_registerObject();
    world.world_GraniteObjectSys_registerObject();
    world.world_LimestoneObjectS_registerObject();
    world.world_SunstoneObjectSy_registerObject();

    world.world_OakLogObjectSyst_registerObject();
    world.world_OakLeafObjectSys_registerObject();
    world.world_OakLumberObjectS_registerObject();
    world.world_BirchLogObjectSy_registerObject();
    world.world_BirchLeafObjectS_registerObject();
    world.world_SakuraLogObjectS_registerObject();
    world.world_SakuraLeafObject_registerObject();
    world.world_RubberLogObjectS_registerObject();
    world.world_RubberLeafObject_registerObject();

    world.world_CottonBushObject_registerObject();
    world.world_MossGrassObjectS_registerObject();
    world.world_SwitchGrassObjec_registerObject();

    world.world_GrassObjectSyste_registerObject();
    world.world_MuckGrassObjectS_registerObject();
    world.world_DirtObjectSystem_registerObject();
    world.world_MuckDirtObjectSy_registerObject();
    world.world_MossObjectSystem_registerObject();

    world.world_SoilObjectSystem_registerObject();
    world.world_ClayObjectSystem_registerObject();
    world.world_GravelObjectSyst_registerObject();

    world.world_CoalOreObjectSys_registerObject();
    world.world_SilverOreObjectS_registerObject();
    world.world_GoldOreObjectSys_registerObject();
    world.world_NeptuniumOreObje_registerObject();
    world.world_DiamondOreObject_registerObject();

    world.world_LavaObjectSystem_registerObject();
    world.world_BedrockObjectSys_registerObject();

    world.world_ChestObjectSyste_registerObject();

    // Items
    world.world_WoodenPickObject_registerObject();

    // Agents
    world.world_BuilderObjectSys_registerObject();
    world.world_FaucetObjectSyst_registerObject();
    world.world_RunnerObjectSyst_registerObject();

    world.spawnInitialFaucets();

    vm.stopBroadcast();
  }
}
