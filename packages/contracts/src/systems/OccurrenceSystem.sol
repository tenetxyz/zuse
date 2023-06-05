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

  function OBedrock(VoxelCoord memory coord) public view returns (bytes32) {
    return IWorld(_world()).Bedrock(coord);
  }
}
