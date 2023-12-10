// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    IWorld world = IWorld(worldAddress);

    world.farming_FarmerObjectSyst_registerObject();
    world.farming_ConcentrativeSoi_registerObject();
    world.farming_DiffusiveSoilObj_registerObject();
    world.farming_ProteinSoilObjec_registerObject();
    world.farming_ElixirSoilObject_registerObject();
    world.farming_PlantObjectSyste_registerObject();

    world.farming_FarmingTerrainSy_initFarmingTerrain();

    vm.stopBroadcast();
  }
}
