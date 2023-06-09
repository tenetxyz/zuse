// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IWorld } from "../codegen/world/IWorld.sol";
import {Occurrence, VoxelPrototype} from "../codegen/Tables.sol";

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
    VoxelPrototype.set(bytes32(GrassID), true);
    Occurrence.set(GrassID, world.OGrass.selector);

    VoxelPrototype.set(bytes32(DirtID), true);
    Occurrence.set(DirtID, world.ODirt.selector);

    VoxelPrototype.set(bytes32(BedrockID), true);
    Occurrence.set(BedrockID, world.OBedrock.selector);

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

    VoxelPrototype.set(bytes32(AirID), true);
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
