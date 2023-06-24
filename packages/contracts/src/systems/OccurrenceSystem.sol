// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IWorld } from "../codegen/world/IWorld.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { AirID, GrassID, DirtID, LogID, StoneID, SandID, WaterID, CobblestoneID, CoalID, CraftingID, IronID, GoldID, DiamondID, LeavesID, PlanksID, RedFlowerID, GrassPlantID, OrangeFlowerID, MagentaFlowerID, LightBlueFlowerID, LimeFlowerID, PinkFlowerID, GrayFlowerID, LightGrayFlowerID, CyanFlowerID, PurpleFlowerID, BlueFlowerID, GreenFlowerID, BlackFlowerID, KelpID, WoolID, SnowID, ClayID, BedrockID } from "../prototypes/Voxels.sol";
import { VoxelCoord, VoxelVariantsKey } from "../types.sol";
import { System } from "@latticexyz/world/src/System.sol";

// This system is used to check whether a given voxel occurs at a given location.
// For voxels added after deployment of the core contracts, a new contract with a function
// returning the occurrence of that voxel can be deployed and linked with the voxel's Occurrence component.
contract OccurrenceSystem is System {

  function execute(bytes memory arguments) public view returns (bytes memory) {
    (bytes32 voxelType, VoxelCoord memory coord) = abi.decode(arguments, (bytes32, VoxelCoord));

    if (voxelType == GrassID) return abi.encode(OGrass(coord));
    if (voxelType == DirtID) return abi.encode(ODirt(coord));
    if (voxelType == BedrockID) return abi.encode(OBedrock(coord));

    return abi.encode(bytes32(0));
  }

  function executeTyped(bytes32 voxelType, VoxelCoord memory coord) public view returns (bytes32) {
    return abi.decode(execute(abi.encode(voxelType, coord)), (bytes32));
  }

  // Occurence functions
  function OGrass(VoxelCoord memory coord) public view returns (VoxelVariantsKey memory) {
    // TODO: Figure out why cant just call it once and store it in memory
    return VoxelVariantsKey({
      namespace: IWorld(_world()).tenet_LibTerrainSystem_Grass(coord).namespace,
      voxelVariantId: IWorld(_world()).tenet_LibTerrainSystem_Grass(coord).voxelVariantId
    });
  }

  function ODirt(VoxelCoord memory coord) public view returns (VoxelVariantsKey memory) {
    // TODO: Figure out why cant just call it once and store it in memory
    return VoxelVariantsKey({
      namespace: IWorld(_world()).tenet_LibTerrainSystem_Dirt(coord).namespace,
      voxelVariantId: IWorld(_world()).tenet_LibTerrainSystem_Dirt(coord).voxelVariantId
    });
  }

  function OBedrock(VoxelCoord memory coord) public view returns (VoxelVariantsKey memory) {
    // TODO: Figure out why cant just call it once and store it in memory
    return VoxelVariantsKey({
      namespace: IWorld(_world()).tenet_LibTerrainSystem_Bedrock(coord).namespace,
      voxelVariantId: IWorld(_world()).tenet_LibTerrainSystem_Bedrock(coord).voxelVariantId
    });
  }
}
