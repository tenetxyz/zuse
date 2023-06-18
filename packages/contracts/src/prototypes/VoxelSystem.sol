// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IWorld } from "../codegen/world/IWorld.sol";
import {Occurrence, VoxelPrototype} from "../codegen/Tables.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";

bytes32 constant AirID = bytes32(keccak256("voxel.Air"));
bytes32 constant GrassID = bytes32(keccak256("voxel.Grass"));
bytes32 constant DirtID = bytes32(keccak256("voxel.Dirt"));
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
bytes32 constant BedrockID = bytes32(keccak256("voxel.Bedrock"));
bytes32 constant BricksID = bytes32(keccak256("voxel.Bricks"));


contract VoxelSystem is System {
    function defineVoxels() public {
        IWorld world = IWorld(_world());
        IStore store = IStore(_world());
        VoxelPrototype.set(store, bytes32(GrassID), true);
        Occurrence.set(store, GrassID, world.tenet_OccurrenceSystem_OGrass.selector);

        VoxelPrototype.set(store, bytes32(DirtID), true);
        Occurrence.set(store, DirtID, world.tenet_OccurrenceSystem_ODirt.selector);

        VoxelPrototype.set(store, bytes32(BedrockID), true);
        Occurrence.set(store, BedrockID, world.tenet_OccurrenceSystem_OBedrock.selector);

        VoxelPrototype.set(store, bytes32(LogID), true);

        VoxelPrototype.set(store, bytes32(StoneID), true);

        VoxelPrototype.set(store, bytes32(SandID), true);

        VoxelPrototype.set(store, bytes32(WaterID), true);

        VoxelPrototype.set(store, bytes32(DiamondID), true);

        VoxelPrototype.set(store, bytes32(CoalID), true);

        VoxelPrototype.set(store, bytes32(LeavesID), true);

        VoxelPrototype.set(store, bytes32(WoolID), true);

        VoxelPrototype.set(store, bytes32(SnowID), true);

        VoxelPrototype.set(store, bytes32(ClayID), true);

        VoxelPrototype.set(store, bytes32(RedFlowerID), true);

        VoxelPrototype.set(store, bytes32(GrassPlantID), true);

        VoxelPrototype.set(store, bytes32(OrangeFlowerID), true);

        VoxelPrototype.set(store, bytes32(MagentaFlowerID), true);

        VoxelPrototype.set(store, bytes32(LightBlueFlowerID), true);

        VoxelPrototype.set(store, bytes32(LimeFlowerID), true);

        VoxelPrototype.set(store, bytes32(PinkFlowerID), true);

        VoxelPrototype.set(store, bytes32(GrayFlowerID), true);

        VoxelPrototype.set(store, bytes32(LightGrayFlowerID), true);

        VoxelPrototype.set(store, bytes32(CyanFlowerID), true);

        VoxelPrototype.set(store, bytes32(PurpleFlowerID), true);

        VoxelPrototype.set(store, bytes32(BlueFlowerID), true);

        VoxelPrototype.set(store, bytes32(GreenFlowerID), true);

        VoxelPrototype.set(store, bytes32(BlackFlowerID), true);

        VoxelPrototype.set(store, bytes32(KelpID), true);

        VoxelPrototype.set(store, bytes32(AirID), true);
        VoxelPrototype.set(store, bytes32(GlassID), true);
        VoxelPrototype.set(store, bytes32(SpongeID), true);
        VoxelPrototype.set(store, bytes32(CobblestoneID), true);
        VoxelPrototype.set(store, bytes32(CoalID), true);
        VoxelPrototype.set(store, bytes32(CraftingID), true);
        VoxelPrototype.set(store, bytes32(IronID), true);
        VoxelPrototype.set(store, bytes32(GoldID), true);
        VoxelPrototype.set(store, bytes32(PlanksID), true);
        VoxelPrototype.set(store, bytes32(OrangeWoolID), true);
        VoxelPrototype.set(store, bytes32(MagentaWoolID), true);
        VoxelPrototype.set(store, bytes32(LightBlueWoolID), true);
        VoxelPrototype.set(store, bytes32(YellowWoolID), true);
        VoxelPrototype.set(store, bytes32(LimeWoolID), true);
        VoxelPrototype.set(store, bytes32(PinkWoolID), true);
        VoxelPrototype.set(store, bytes32(GrayWoolID), true);
        VoxelPrototype.set(store, bytes32(LightGrayWoolID), true);
        VoxelPrototype.set(store, bytes32(CyanWoolID), true);
        VoxelPrototype.set(store, bytes32(PurpleWoolID), true);
        VoxelPrototype.set(store, bytes32(BlueWoolID), true);
        VoxelPrototype.set(store, bytes32(BrownWoolID), true);
        VoxelPrototype.set(store, bytes32(GreenWoolID), true);
        VoxelPrototype.set(store, bytes32(RedWoolID), true);
        VoxelPrototype.set(store, bytes32(BlackWoolID), true);
    }
}
