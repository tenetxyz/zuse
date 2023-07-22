// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { AirVoxelID, AirVoxelVariantID, DirtVoxelID, DirtVoxelVariantID, DirtTexture, DirtUVWrap, GrassVoxelID, GrassVoxelVariantID } from "@base-ca/src/Constants.sol";

address constant REGISTRY_WORLD = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
string constant REGISTER_VOXEL_TYPE_SIG = "registerVoxelType(string,bytes32,bytes32,address)";
string constant REGISTER_VOXEL_VARIANT_SIG = "registerVoxelVariant(bytes32,(uint256,uint32,bool,bool,bool,uint8,bytes,string))";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // Register Air
    VoxelVariantsRegistryData memory airVariant;
    airVariant.blockType = NoaBlockType.BLOCK;
    REGISTRY_WORLD.call(abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, AirVoxelVariantID, airVariant));
    REGISTRY_WORLD.call(
      abi.encodeWithSignature(REGISTER_VOXEL_TYPE_SIG, "Air", AirVoxelID, AirVoxelVariantID, worldAddress)
    );

    // Register Dirt
    VoxelVariantsRegistryData memory dirtVariant;
    dirtVariant.blockType = NoaBlockType.BLOCK;
    dirtVariant.opaque = true;
    dirtVariant.solid = true;
    string[] memory dirtMaterials = new string[](1);
    dirtMaterials[0] = DirtTexture;
    dirtVariant.materials = abi.encode(dirtMaterials);
    dirtVariant.uvWrap = DirtUVWrap;
    REGISTRY_WORLD.call(abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, DirtVoxelVariantID, dirtVariant));
    REGISTRY_WORLD.call(
      abi.encodeWithSignature(REGISTER_VOXEL_TYPE_SIG, "Dirt", DirtVoxelID, DirtVoxelVariantID, worldAddress)
    );

    vm.stopBroadcast();
  }
}
