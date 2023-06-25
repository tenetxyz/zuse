// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IWorld } from "../codegen/world/IWorld.sol";
import {Occurrence, VoxelPrototype, VoxelTypeData, VoxelVariantsData} from "../codegen/Tables.sol";
import { NoaBlockType } from "../codegen/Types.sol";

bytes32 constant AirID = bytes32(keccak256("air"));
bytes32 constant GrassID = bytes32(keccak256("grass"));
bytes32 constant DirtID = bytes32(keccak256("dirt"));
bytes32 constant BedrockID = bytes32(keccak256("bedrock"));

// TODO: remove
bytes32 constant LogID = bytes32(keccak256("voxel.Log"));
bytes32 constant StoneID = bytes32(keccak256("voxel.Stone"));
bytes32 constant SandID = bytes32(keccak256("voxel.Sand"));
bytes32 constant GlassID = bytes32(keccak256("voxel.Glass"));
bytes32 constant WaterID = bytes32(keccak256("voxel.Water"));
bytes32 constant CobblestoneID = bytes32(keccak256("voxel.Cobblestone"));
bytes32 constant MossyCobblestoneID = bytes32(keccak256("voxel.MossyCobblestone"));
bytes32 constant CoalID = bytes32(keccak256("voxel.Coal"));
bytes32 constant CraftingID = bytes32(keccak256("voxel.Crafting"));
bytes32 constant IronID = bytes32(keccak256("voxel.Iron"));
bytes32 constant GoldID = bytes32(keccak256("voxel.Gold"));
bytes32 constant DiamondID = bytes32(keccak256("voxel.Diamond"));
bytes32 constant LeavesID = bytes32(keccak256("voxel.Leaves"));
bytes32 constant PlanksID = bytes32(keccak256("voxel.Planks"));
bytes32 constant RedFlowerID = bytes32(keccak256("voxel.RedFlower"));
bytes32 constant GrassPlantID = bytes32(keccak256("voxel.GrassPlant"));
bytes32 constant OrangeFlowerID = bytes32(keccak256("voxel.OrangeFlower"));
bytes32 constant MagentaFlowerID = bytes32(keccak256("voxel.MagentaFlower"));
bytes32 constant LightBlueFlowerID = bytes32(keccak256("voxel.LightBlueFlower"));
bytes32 constant LimeFlowerID = bytes32(keccak256("voxel.LimeFlower"));
bytes32 constant PinkFlowerID = bytes32(keccak256("voxel.PinkFlower"));
bytes32 constant GrayFlowerID = bytes32(keccak256("voxel.GrayFlower"));
bytes32 constant LightGrayFlowerID = bytes32(keccak256("voxel.LightGrayFlower"));
bytes32 constant CyanFlowerID = bytes32(keccak256("voxel.CyanFlower"));
bytes32 constant PurpleFlowerID = bytes32(keccak256("voxel.PurpleFlower"));
bytes32 constant BlueFlowerID = bytes32(keccak256("voxel.BlueFlower"));
bytes32 constant GreenFlowerID = bytes32(keccak256("voxel.GreenFlower"));
bytes32 constant BlackFlowerID = bytes32(keccak256("voxel.BlackFlower"));
bytes32 constant KelpID = bytes32(keccak256("voxel.Kelp"));
bytes32 constant WoolID = bytes32(keccak256("voxel.Wool"));
bytes32 constant OrangeWoolID = bytes32(keccak256("voxel.OrangeWool"));
bytes32 constant MagentaWoolID = bytes32(keccak256("voxel.MagentaWool"));
bytes32 constant LightBlueWoolID = bytes32(keccak256("voxel.LightBlueWool"));
bytes32 constant YellowWoolID = bytes32(keccak256("voxel.YellowWool"));
bytes32 constant LimeWoolID = bytes32(keccak256("voxel.LimeWool"));
bytes32 constant PinkWoolID = bytes32(keccak256("voxel.PinkWool"));
bytes32 constant GrayWoolID = bytes32(keccak256("voxel.GrayWool"));
bytes32 constant LightGrayWoolID = bytes32(keccak256("voxel.LightGrayWool"));
bytes32 constant CyanWoolID = bytes32(keccak256("voxel.CyanWool"));
bytes32 constant PurpleWoolID = bytes32(keccak256("voxel.PurpleWool"));
bytes32 constant BlueWoolID = bytes32(keccak256("voxel.BlueWool"));
bytes32 constant BrownWoolID = bytes32(keccak256("voxel.BrownWool"));
bytes32 constant GreenWoolID = bytes32(keccak256("voxel.GreenWool"));
bytes32 constant RedWoolID = bytes32(keccak256("voxel.RedWool"));
bytes32 constant BlackWoolID = bytes32(keccak256("voxel.BlackWool"));
bytes32 constant SpongeID = bytes32(keccak256("voxel.Sponge"));
bytes32 constant SnowID = bytes32(keccak256("voxel.Snow"));
bytes32 constant ClayID = bytes32(keccak256("voxel.Clay"));
bytes32 constant BricksID = bytes32(keccak256("voxel.Bricks"));

function defineVoxels(IWorld world) {
    VoxelVariantsData memory airVariant = VoxelVariantsData({
        variantId: 0,
        material: "",
        uvWrap: "",
        blockType: NoaBlockType.BLOCK,
        frames: 0,
        opaque: false,
        fluid: false,
        solid: true
    });
    world.tenet_VoxelRegistrySys_registerVoxelVariant(bytes32(keccak256("air")), airVariant);

    VoxelVariantsData memory dirtVariant = VoxelVariantsData({
            variantId: 1,
            material: "bafkreibzraiuk6hgngtfczn57sivuqf3nv77twi6g3ftas2umjnbf6jefe",
            uvWrap: "bafkreifbshwckn4pgw5ew2obz3i74eujzpcomatus5gu2tk7mms373gqme",
            blockType: NoaBlockType.BLOCK,
            frames: 0,
            opaque: true,
            fluid: false,
            solid: true
    });
    world.tenet_VoxelRegistrySys_registerVoxelVariant(bytes32(keccak256("dirt")), dirtVariant);

    VoxelVariantsData memory grassVariant = VoxelVariantsData({
            variantId: 2,
            material: "bafkreifmvm3yxzbkzcb2r7m6gavjhe22n4p3o36lz2ypkgf5v6i6zzhv4a",
            // TODO: make grass use an array of 3 materials, not a single one
            uvWrap: "bafkreihaagdyqnbie3eyx6upmoul2zb4qakubxg6bcha6k5ebp4fbsd3am",
            blockType: NoaBlockType.BLOCK,
            frames: 0,
            opaque: true,
            fluid: false,
            solid: true
    });
    world.tenet_VoxelRegistrySys_registerVoxelVariant(bytes32(keccak256("grass")), grassVariant);

    VoxelVariantsData memory bedrockVariant = VoxelVariantsData({
            variantId: 3,
            material: "bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a",
            uvWrap: "bafkreihdit6glam7sreijo7itbs7uwc2ltfeuvcfaublxf6rjo24hf6t4y",
            blockType: NoaBlockType.BLOCK,
            frames: 0,
            opaque: true,
            fluid: false,
            solid: true
    });
    world.tenet_VoxelRegistrySys_registerVoxelVariant(bytes32(keccak256("bedrock")), bedrockVariant);

    VoxelPrototype.set(bytes32(GrassID), true);
    Occurrence.set(GrassID, world.tenet_OccurrenceSystem_OGrass.selector);
    world.tenet_VoxelRegistrySys_registerVoxelType(GrassID, "bafkreifmvm3yxzbkzcb2r7m6gavjhe22n4p3o36lz2ypkgf5v6i6zzhv4a", world.tenet_VoxelRegistrySys_grassVariantSelector.selector);

    VoxelPrototype.set(bytes32(DirtID), true);
    Occurrence.set(DirtID, world.tenet_OccurrenceSystem_ODirt.selector);
    world.tenet_VoxelRegistrySys_registerVoxelType(DirtID, "bafkreibzraiuk6hgngtfczn57sivuqf3nv77twi6g3ftas2umjnbf6jefe", world.tenet_VoxelRegistrySys_dirtVariantSelector.selector);

    VoxelPrototype.set(bytes32(BedrockID), true);
    Occurrence.set(BedrockID, world.tenet_OccurrenceSystem_OBedrock.selector);
    world.tenet_VoxelRegistrySys_registerVoxelType(BedrockID, "bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a", world.tenet_VoxelRegistrySys_bedrockVariantSelector.selector);

    VoxelPrototype.set(bytes32(AirID), true);
    world.tenet_VoxelRegistrySys_registerVoxelType(AirID, "", world.tenet_VoxelRegistrySys_airVariantSelector.selector);

    VoxelPrototype.set(bytes32(LogID), true);

    VoxelPrototype.set(bytes32(StoneID), true);

    VoxelPrototype.set(bytes32(SandID), true);

    VoxelPrototype.set(bytes32(WaterID), true);

    VoxelPrototype.set(bytes32(DiamondID), true);

    VoxelPrototype.set(bytes32(CoalID), true);

    VoxelPrototype.set(bytes32(LeavesID), true);

    VoxelPrototype.set(bytes32(WoolID), true);

    VoxelPrototype.set(bytes32(SnowID), true);

    VoxelPrototype.set(bytes32(ClayID), true);

    VoxelPrototype.set(bytes32(RedFlowerID), true);

    VoxelPrototype.set(bytes32(GrassPlantID), true);

    VoxelPrototype.set(bytes32(OrangeFlowerID), true);

    VoxelPrototype.set(bytes32(MagentaFlowerID), true);

    VoxelPrototype.set(bytes32(LightBlueFlowerID), true);

    VoxelPrototype.set(bytes32(LimeFlowerID), true);

    VoxelPrototype.set(bytes32(PinkFlowerID), true);

    VoxelPrototype.set(bytes32(GrayFlowerID), true);

    VoxelPrototype.set(bytes32(LightGrayFlowerID), true);

    VoxelPrototype.set(bytes32(CyanFlowerID), true);

    VoxelPrototype.set(bytes32(PurpleFlowerID), true);

    VoxelPrototype.set(bytes32(BlueFlowerID), true);

    VoxelPrototype.set(bytes32(GreenFlowerID), true);

    VoxelPrototype.set(bytes32(BlackFlowerID), true);

    VoxelPrototype.set(bytes32(KelpID), true);

    VoxelPrototype.set(bytes32(GlassID), true);
    VoxelPrototype.set(bytes32(SpongeID), true);
    VoxelPrototype.set(bytes32(CobblestoneID), true);
    VoxelPrototype.set(bytes32(CoalID), true);
    VoxelPrototype.set(bytes32(CraftingID), true);
    VoxelPrototype.set(bytes32(IronID), true);
    VoxelPrototype.set(bytes32(GoldID), true);
    VoxelPrototype.set(bytes32(PlanksID), true);
    VoxelPrototype.set(bytes32(OrangeWoolID), true);
    VoxelPrototype.set(bytes32(MagentaWoolID), true);
    VoxelPrototype.set(bytes32(LightBlueWoolID), true);
    VoxelPrototype.set(bytes32(YellowWoolID), true);
    VoxelPrototype.set(bytes32(LimeWoolID), true);
    VoxelPrototype.set(bytes32(PinkWoolID), true);
    VoxelPrototype.set(bytes32(GrayWoolID), true);
    VoxelPrototype.set(bytes32(LightGrayWoolID), true);
    VoxelPrototype.set(bytes32(CyanWoolID), true);
    VoxelPrototype.set(bytes32(PurpleWoolID), true);
    VoxelPrototype.set(bytes32(BlueWoolID), true);
    VoxelPrototype.set(bytes32(BrownWoolID), true);
    VoxelPrototype.set(bytes32(GreenWoolID), true);
    VoxelPrototype.set(bytes32(RedWoolID), true);
    VoxelPrototype.set(bytes32(BlackWoolID), true);
}
