// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { RoadVoxelID, RoadVoxelVariantID, RoadVoxelTexture, RoadVoxelUVWrap } from "@composed-ca/src/Constants.sol";

address constant REGISTRY_WORLD = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
string constant REGISTER_VOXEL_TYPE_SIG = "registerVoxelType(string,bytes32,bytes32,address)";
string constant REGISTER_VOXEL_VARIANT_SIG = "registerVoxelVariant(bytes32,(uint256,uint32,bool,bool,bool,uint8,bytes,string))";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    IWorld(worldAddress).defineVoxelTypeDefs();

    // Register Road
    VoxelVariantsRegistryData memory roadVariant;
    roadVariant.blockType = NoaBlockType.BLOCK;
    roadVariant.opaque = true;
    roadVariant.solid = true;
    string[] memory roadMaterials = new string[](1);
    roadMaterials[0] = RoadVoxelTexture;
    roadVariant.materials = abi.encode(roadMaterials);
    roadVariant.uvWrap = RoadVoxelUVWrap;
    REGISTRY_WORLD.call(abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, RoadVoxelVariantID, roadVariant));
    REGISTRY_WORLD.call(
      abi.encodeWithSignature(REGISTER_VOXEL_TYPE_SIG, "Road", RoadVoxelID, RoadVoxelVariantID, worldAddress)
    );

    vm.stopBroadcast();
  }
}
