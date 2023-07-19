// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { VoxelTypeData, VoxelVariantsData, Car, CarData, Position, PositionData, PositionTableId, VoxelType } from "@tenet-contracts/src/codegen/Tables.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";
import { VoxelVariantsKey, BlockDirection, VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { TENET_NAMESPACE } from "../../Constants.sol";
import { getPositionAtDirection, calculateBlockDirection } from "@tenet-contracts/src/Utils.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { RoadID } from "./RoadVoxelSystem.sol";
import { VoxelType as VoxelTypeContract } from "@tenet-contracts/src/prototypes/VoxelType.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

bytes32 constant CarID = bytes32(keccak256("car"));
uint256 constant MAX_TRAVEL_DIST = 30;

string constant CarTexture = "bafkreieq2ss2t4u32hye2mrkfdb3rgzlp64b4nqhhpseb5w7ntx2w6vhnq";

contract CarVoxelSystem is VoxelTypeContract {
  function registerVoxel() public override {
    IWorld world = IWorld(_world());

    VoxelVariantsData memory carVariant;
    carVariant.blockType = NoaBlockType.MESH;
    carVariant.opaque = false;
    carVariant.solid = false;
    carVariant.frames = 1;
    string[] memory carMaterials = new string[](1);
    carMaterials[0] = CarTexture;
    carVariant.materials = abi.encode(carMaterials);

    world.tenet_VoxelRegistrySys_registerVoxelVariant(CarID, carVariant);

    world.tenet_VoxelRegistrySys_registerVoxelType(
      "Car",
      CarID,
      TENET_NAMESPACE,
      CarID,
      world.tenet_CarVoxelSystem_variantSelector.selector,
      world.tenet_CarVoxelSystem_enterWorld.selector,
      world.tenet_CarVoxelSystem_exitWorld.selector,
      world.tenet_CarVoxelSystem_activate.selector
    );
  }

  function enterWorld(bytes32 entity) public override {
    Car.set(
      entity,
      CarData({
        velocity: 1,
        acceleration: 0,
        blockNumber: block.number,
        prevDirection: uint8(BlockDirection.None),
        hasValue: true
      })
    );
  }

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public pure override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: CarID });
  }

  function activate(bytes32 entity) public override returns (bytes memory) {
    CarData memory car = Car.get(entity);
    uint256 dist = Math.min(car.velocity * (block.number - car.blockNumber), MAX_TRAVEL_DIST);
    if (dist > 0) {
      uint256 distTraveled = travelDist(entity, dist - 1);
      Car.setBlockNumber(entity, block.number);
      return abi.encodePacked("moved ", Strings.toString(distTraveled), " steps");
    } else {
      return abi.encodePacked("car couldn't move :(");
    }
  }

  // returns number of blocks travelled
  function travelDist(bytes32 entity, uint256 dist) public returns (uint256) {
    PositionData memory position = Position.get(entity);
    VoxelCoord memory coord = VoxelCoord(position.x, position.y, position.z);
    BlockDirection prevDirection = BlockDirection(Car.getPrevDirection(entity));
    for (uint direction = 0; direction < 7; direction++) {
      BlockDirection blockDirection = BlockDirection(direction);
      if (
        blockDirection == BlockDirection.Up ||
        blockDirection == BlockDirection.Down ||
        blockDirection == BlockDirection.None
      ) {
        // do nothing since we can't travel in these directions
        continue;
      }
      if (blockDirection == prevDirection) {
        // this is the way we can from, so don't do anything
        continue;
      }
      // if the block underneath is a road, we can move there
      VoxelCoord memory neighbourCoord = getPositionAtDirection(coord, blockDirection);
      VoxelCoord memory coordUnderNeighbor = getPositionAtDirection(neighbourCoord, BlockDirection.Down);
      bytes32[] memory entitiesAtPosition = getKeysWithValue(
        PositionTableId,
        Position.encode(coordUnderNeighbor.x, coordUnderNeighbor.y, coordUnderNeighbor.z)
      );

      if (entitiesAtPosition.length != 1) {
        // there is no way this voxel is a road, so don't do anything
        continue;
      }
      if (VoxelType.get(entitiesAtPosition[0]).voxelTypeId == RoadID) {
        // move the car to the new position
        IWorld(_world()).tenet_MoveSystem_tryMove(entity, blockDirection);
        Car.setPrevDirection(entity, uint8(calculateBlockDirection(neighbourCoord, coord)));
        if (dist > 0) {
          return 1 + travelDist(entity, dist - 1);
        }
        return 1;
      }
    }
    return 0;
  }
}
