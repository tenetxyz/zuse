// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IWorld } from "../codegen/world/IWorld.sol";
import {Occurrence, VoxelTypeData, VoxelVariantsData} from "../codegen/Tables.sol";
import { NoaBlockType } from "../codegen/Types.sol";
import { materialsArrToString } from "../SharedUtils.sol";

bytes32 constant AirID = bytes32(keccak256("air"));
bytes32 constant GrassID = bytes32(keccak256("grass"));
bytes32 constant DirtID = bytes32(keccak256("dirt"));
bytes32 constant BedrockID = bytes32(keccak256("bedrock"));

string constant DirtTexture = "bafkreibzraiuk6hgngtfczn57sivuqf3nv77twi6g3ftas2umjnbf6jefe";
string constant GrassTexture = "bafkreifmvm3yxzbkzcb2r7m6gavjhe22n4p3o36lz2ypkgf5v6i6zzhv4a";
string constant GrassSideTexture = "bafkreibp5wefex2cunqz5ffwt3ucw776qthwl6y6pswr2j2zuzldrv6bqa";
string constant BedrockTexture = "bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a";

string constant DirtUVWrap = "bafkreifbshwckn4pgw5ew2obz3i74eujzpcomatus5gu2tk7mms373gqme";
string constant GrassUVWrap = "bafkreihaagdyqnbie3eyx6upmoul2zb4qakubxg6bcha6k5ebp4fbsd3am";
string constant BedrockUVWrap = "bafkreihdit6glam7sreijo7itbs7uwc2ltfeuvcfaublxf6rjo24hf6t4y";

function defineVoxels(IWorld world) {

    VoxelVariantsData memory airVariant;
    airVariant.blockType = NoaBlockType.BLOCK;
    world.tenet_VoxelRegistrySys_registerVoxelVariant(AirID, airVariant);

    VoxelVariantsData memory dirtVariant;
    dirtVariant.blockType = NoaBlockType.BLOCK;
    dirtVariant.opaque = true;
    dirtVariant.solid = true;
    dirtVariant.materialArr = DirtTexture;
    dirtVariant.uvWrap = DirtUVWrap;
    world.tenet_VoxelRegistrySys_registerVoxelVariant(DirtID, dirtVariant);

    string[] memory grassMaterials = new string[](3);
    grassMaterials[0] = GrassTexture;
    grassMaterials[1] = DirtTexture;
    grassMaterials[2] = GrassSideTexture;

    VoxelVariantsData memory grassVariant;
    grassVariant.blockType = NoaBlockType.BLOCK;
    grassVariant.opaque = true;
    grassVariant.solid = true;
    grassVariant.materialArr = materialsArrToString(grassMaterials);
    grassVariant.uvWrap = GrassUVWrap;

    world.tenet_VoxelRegistrySys_registerVoxelVariant(GrassID, grassVariant);

    VoxelVariantsData memory bedrockVariant;
    bedrockVariant.blockType = NoaBlockType.BLOCK;
    bedrockVariant.opaque = true;
    bedrockVariant.solid = true;
    bedrockVariant.materialArr = BedrockTexture;
    bedrockVariant.uvWrap = BedrockUVWrap;

    world.tenet_VoxelRegistrySys_registerVoxelVariant(BedrockID, bedrockVariant);

    Occurrence.set(GrassID, world.tenet_OccurrenceSystem_OGrass.selector);
    world.tenet_VoxelRegistrySys_registerVoxelType(GrassID, GrassTexture, world.tenet_VoxelRegistrySys_grassVariantSelector.selector);

    Occurrence.set(DirtID, world.tenet_OccurrenceSystem_ODirt.selector);
    world.tenet_VoxelRegistrySys_registerVoxelType(DirtID, DirtTexture, world.tenet_VoxelRegistrySys_dirtVariantSelector.selector);

    Occurrence.set(BedrockID, world.tenet_OccurrenceSystem_OBedrock.selector);
    world.tenet_VoxelRegistrySys_registerVoxelType(BedrockID, BedrockTexture, world.tenet_VoxelRegistrySys_bedrockVariantSelector.selector);

    world.tenet_VoxelRegistrySys_registerVoxelType(AirID, "", world.tenet_VoxelRegistrySys_airVariantSelector.selector);
}
