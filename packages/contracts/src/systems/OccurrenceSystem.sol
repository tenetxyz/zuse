// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IWorld } from "../codegen/world/IWorld.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { AirID, GrassID, DirtID, LogID, StoneID, SandID, WaterID, CobblestoneID, CoalID, CraftingID, IronID, GoldID, DiamondID, LeavesID, PlanksID, RedFlowerID, GrassPlantID, OrangeFlowerID, MagentaFlowerID, LightBlueFlowerID, LimeFlowerID, PinkFlowerID, GrayFlowerID, LightGrayFlowerID, CyanFlowerID, PurpleFlowerID, BlueFlowerID, GreenFlowerID, BlackFlowerID, KelpID, WoolID, SnowID, ClayID, BedrockID } from "../prototypes/Blocks.sol";
import { VoxelCoord } from "../types.sol";
import { System } from "@latticexyz/world/src/System.sol";

// This system is used to check whether a given block occurs at a given location.
// For blocks added after deployment of the core contracts, a new contract with a function
// returning the occurrence of that block can be deployed and linked with the block's Occurrence component.
contract OccurrenceSystem is System {

  function execute(bytes memory arguments) public view returns (bytes memory) {
    (bytes32 blockType, VoxelCoord memory coord) = abi.decode(arguments, (bytes32, VoxelCoord));

    if (blockType == GrassID) return abi.encode(OGrass(coord));
    if (blockType == DirtID) return abi.encode(ODirt(coord));
    if (blockType == LogID) return abi.encode(OLog(coord));
    if (blockType == StoneID) return abi.encode(OStone(coord));
    if (blockType == SandID) return abi.encode(OSand(coord));
    if (blockType == WaterID) return abi.encode(OWater(coord));
    if (blockType == DiamondID) return abi.encode(ODiamond(coord));
    if (blockType == CoalID) return abi.encode(OCoal(coord));
    if (blockType == LeavesID) return abi.encode(OLeaves(coord));
    if (blockType == RedFlowerID) return abi.encode(ORedFlower(coord));
    if (blockType == GrassPlantID) return abi.encode(OGrassPlant(coord));
    if (blockType == OrangeFlowerID) return abi.encode(OOrangeFlower(coord));
    if (blockType == MagentaFlowerID) return abi.encode(OMagentaFlower(coord));
    if (blockType == LightBlueFlowerID) return abi.encode(OLightBlueFlower(coord));
    if (blockType == LimeFlowerID) return abi.encode(OLimeFlower(coord));
    if (blockType == PinkFlowerID) return abi.encode(OPinkFlower(coord));
    if (blockType == GrayFlowerID) return abi.encode(OGrayFlower(coord));
    if (blockType == LightGrayFlowerID) return abi.encode(OLightGrayFlower(coord));
    if (blockType == CyanFlowerID) return abi.encode(OCyanFlower(coord));
    if (blockType == PurpleFlowerID) return abi.encode(OPurpleFlower(coord));
    if (blockType == BlueFlowerID) return abi.encode(OBlueFlower(coord));
    if (blockType == GreenFlowerID) return abi.encode(OGreenFlower(coord));
    if (blockType == BlackFlowerID) return abi.encode(OBlackFlower(coord));
    if (blockType == KelpID) return abi.encode(OKelp(coord));
    if (blockType == WoolID) return abi.encode(OWool(coord));
    if (blockType == SnowID) return abi.encode(OSnow(coord));
    if (blockType == ClayID) return abi.encode(OClay(coord));
    if (blockType == BedrockID) return abi.encode(OBedrock(coord));
    return abi.encode(bytes32(0));
  }

  function executeTyped(bytes32 blockType, VoxelCoord memory coord) public view returns (bytes32) {
    return abi.decode(execute(abi.encode(blockType, coord)), (bytes32));
  }

  // Occurence functions
  function OGrass(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Grass(coord);
  }

  function ODirt(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Dirt(coord);
  }

  function OLog(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Structure(coord);
  }

  function OStone(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Stone(coord);
  }

  function OSand(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Sand(coord);
  }

  function OWater(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Water(coord);
  }

  function ODiamond(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Diamond(coord);
  }

  function OCoal(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Coal(coord);
  }

  function OLeaves(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Structure(coord);
  }

  function ORedFlower(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OGrassPlant(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OOrangeFlower(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OMagentaFlower(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OLightBlueFlower(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OLimeFlower(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OPinkFlower(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OGrayFlower(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OLightGrayFlower(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OCyanFlower(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OPurpleFlower(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OBlueFlower(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OGreenFlower(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OBlackFlower(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OKelp(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).SmallPlant(coord);
  }

  function OWool(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Structure(coord);
  }

  function OSnow(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Snow(coord);
  }

  function OClay(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Clay(coord);
  }

  function OBedrock(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Bedrock(coord);
  }
}
