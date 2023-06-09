// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IWorld } from "../codegen/world/IWorld.sol";
import {Occurrence, VoxelTypePrototype} from "../codegen/Tables.sol";

bytes32 constant AirID = bytes32(keccak256("block.Air"));
bytes32 constant GrassID = bytes32(keccak256("block.Grass"));
bytes32 constant DirtID = bytes32(keccak256("block.Dirt"));
bytes32 constant LogID = bytes32(keccak256("block.Log"));
bytes32 constant StoneID = bytes32(keccak256("block.Stone"));
bytes32 constant SandID = bytes32(keccak256("block.Sand"));
bytes32 constant GlassID = bytes32(keccak256("block.Glass"));
bytes32 constant WaterID = bytes32(keccak256("block.Water"));
bytes32 constant CobblestoneID = bytes32(keccak256("block.Cobblestone"));
bytes32 constant MossyCobblestoneID = bytes32(keccak256("block.MossyCobblestone"));
bytes32 constant CoalID = bytes32(keccak256("block.Coal"));
bytes32 constant CraftingID = bytes32(keccak256("block.Crafting"));
bytes32 constant IronID = bytes32(keccak256("block.Iron"));
bytes32 constant GoldID = bytes32(keccak256("block.Gold"));
bytes32 constant DiamondID = bytes32(keccak256("block.Diamond"));
bytes32 constant LeavesID = bytes32(keccak256("block.Leaves"));
bytes32 constant PlanksID = bytes32(keccak256("block.Planks"));
bytes32 constant RedFlowerID = bytes32(keccak256("block.RedFlower"));
bytes32 constant GrassPlantID = bytes32(keccak256("block.GrassPlant"));
bytes32 constant OrangeFlowerID = bytes32(keccak256("block.OrangeFlower"));
bytes32 constant MagentaFlowerID = bytes32(keccak256("block.MagentaFlower"));
bytes32 constant LightBlueFlowerID = bytes32(keccak256("block.LightBlueFlower"));
bytes32 constant LimeFlowerID = bytes32(keccak256("block.LimeFlower"));
bytes32 constant PinkFlowerID = bytes32(keccak256("block.PinkFlower"));
bytes32 constant GrayFlowerID = bytes32(keccak256("block.GrayFlower"));
bytes32 constant LightGrayFlowerID = bytes32(keccak256("block.LightGrayFlower"));
bytes32 constant CyanFlowerID = bytes32(keccak256("block.CyanFlower"));
bytes32 constant PurpleFlowerID = bytes32(keccak256("block.PurpleFlower"));
bytes32 constant BlueFlowerID = bytes32(keccak256("block.BlueFlower"));
bytes32 constant GreenFlowerID = bytes32(keccak256("block.GreenFlower"));
bytes32 constant BlackFlowerID = bytes32(keccak256("block.BlackFlower"));
bytes32 constant KelpID = bytes32(keccak256("block.Kelp"));
bytes32 constant WoolID = bytes32(keccak256("block.Wool"));
bytes32 constant OrangeWoolID = bytes32(keccak256("block.OrangeWool"));
bytes32 constant MagentaWoolID = bytes32(keccak256("block.MagentaWool"));
bytes32 constant LightBlueWoolID = bytes32(keccak256("block.LightBlueWool"));
bytes32 constant YellowWoolID = bytes32(keccak256("block.YellowWool"));
bytes32 constant LimeWoolID = bytes32(keccak256("block.LimeWool"));
bytes32 constant PinkWoolID = bytes32(keccak256("block.PinkWool"));
bytes32 constant GrayWoolID = bytes32(keccak256("block.GrayWool"));
bytes32 constant LightGrayWoolID = bytes32(keccak256("block.LightGrayWool"));
bytes32 constant CyanWoolID = bytes32(keccak256("block.CyanWool"));
bytes32 constant PurpleWoolID = bytes32(keccak256("block.PurpleWool"));
bytes32 constant BlueWoolID = bytes32(keccak256("block.BlueWool"));
bytes32 constant BrownWoolID = bytes32(keccak256("block.BrownWool"));
bytes32 constant GreenWoolID = bytes32(keccak256("block.GreenWool"));
bytes32 constant RedWoolID = bytes32(keccak256("block.RedWool"));
bytes32 constant BlackWoolID = bytes32(keccak256("block.BlackWool"));
bytes32 constant SpongeID = bytes32(keccak256("block.Sponge"));
bytes32 constant SnowID = bytes32(keccak256("block.Snow"));
bytes32 constant ClayID = bytes32(keccak256("block.Clay"));
bytes32 constant BedrockID = bytes32(keccak256("block.Bedrock"));
bytes32 constant BricksID = bytes32(keccak256("block.Bricks"));

function defineBlocks(IWorld world) {
    VoxelTypePrototype.set(bytes32(GrassID), true);
    Occurrence.set(GrassID, world.OGrass.selector);

    VoxelTypePrototype.set(bytes32(DirtID), true);
    Occurrence.set(DirtID, world.ODirt.selector);

    VoxelTypePrototype.set(bytes32(BedrockID), true);
    Occurrence.set(BedrockID, world.OBedrock.selector);

    VoxelTypePrototype.set(bytes32(LogID), true);

    VoxelTypePrototype.set(bytes32(StoneID), true);

    VoxelTypePrototype.set(bytes32(SandID), true);

    VoxelTypePrototype.set(bytes32(WaterID), true);

    VoxelTypePrototype.set(bytes32(DiamondID), true);

    VoxelTypePrototype.set(bytes32(CoalID), true);

    VoxelTypePrototype.set(bytes32(LeavesID), true);

    VoxelTypePrototype.set(bytes32(WoolID), true);

    VoxelTypePrototype.set(bytes32(SnowID), true);

    VoxelTypePrototype.set(bytes32(ClayID), true);

    VoxelTypePrototype.set(bytes32(RedFlowerID), true);

    VoxelTypePrototype.set(bytes32(GrassPlantID), true);

    VoxelTypePrototype.set(bytes32(OrangeFlowerID), true);

    VoxelTypePrototype.set(bytes32(MagentaFlowerID), true);

    VoxelTypePrototype.set(bytes32(LightBlueFlowerID), true);

    VoxelTypePrototype.set(bytes32(LimeFlowerID), true);

    VoxelTypePrototype.set(bytes32(PinkFlowerID), true);

    VoxelTypePrototype.set(bytes32(GrayFlowerID), true);

    VoxelTypePrototype.set(bytes32(LightGrayFlowerID), true);

    VoxelTypePrototype.set(bytes32(CyanFlowerID), true);

    VoxelTypePrototype.set(bytes32(PurpleFlowerID), true);

    VoxelTypePrototype.set(bytes32(BlueFlowerID), true);

    VoxelTypePrototype.set(bytes32(GreenFlowerID), true);

    VoxelTypePrototype.set(bytes32(BlackFlowerID), true);

    VoxelTypePrototype.set(bytes32(KelpID), true);

    VoxelTypePrototype.set(bytes32(AirID), true);
    VoxelTypePrototype.set(bytes32(GlassID), true);
    VoxelTypePrototype.set(bytes32(SpongeID), true);
    VoxelTypePrototype.set(bytes32(CobblestoneID), true);
    VoxelTypePrototype.set(bytes32(CoalID), true);
    VoxelTypePrototype.set(bytes32(CraftingID), true);
    VoxelTypePrototype.set(bytes32(IronID), true);
    VoxelTypePrototype.set(bytes32(GoldID), true);
    VoxelTypePrototype.set(bytes32(PlanksID), true);
    VoxelTypePrototype.set(bytes32(OrangeWoolID), true);
    VoxelTypePrototype.set(bytes32(MagentaWoolID), true);
    VoxelTypePrototype.set(bytes32(LightBlueWoolID), true);
    VoxelTypePrototype.set(bytes32(YellowWoolID), true);
    VoxelTypePrototype.set(bytes32(LimeWoolID), true);
    VoxelTypePrototype.set(bytes32(PinkWoolID), true);
    VoxelTypePrototype.set(bytes32(GrayWoolID), true);
    VoxelTypePrototype.set(bytes32(LightGrayWoolID), true);
    VoxelTypePrototype.set(bytes32(CyanWoolID), true);
    VoxelTypePrototype.set(bytes32(PurpleWoolID), true);
    VoxelTypePrototype.set(bytes32(BlueWoolID), true);
    VoxelTypePrototype.set(bytes32(BrownWoolID), true);
    VoxelTypePrototype.set(bytes32(GreenWoolID), true);
    VoxelTypePrototype.set(bytes32(RedWoolID), true);
    VoxelTypePrototype.set(bytes32(BlackWoolID), true);
}
