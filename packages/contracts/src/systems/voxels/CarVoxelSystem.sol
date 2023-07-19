// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { VoxelTypeData, VoxelVariantsData, Car, Position, PositionData, PositionTableId, VoxelType } from "@tenet-contracts/src/codegen/Tables.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";
import { VoxelVariantsKey, BlockDirection, VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { TENET_NAMESPACE } from "../../Constants.sol";
import { getPositionAtDirection, calculateBlockDirection } from "@tenet-contracts/src/Utils.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { VoxelInteraction } from "@tenet-contracts/src/prototypes/VoxelInteraction.sol";
import { RoadID } from "./RoadVoxelSystem.sol";

bytes32 constant CarID = bytes32(keccak256("car"));

string constant CarTexture = "bafkreieq2ss2t4u32hye2mrkfdb3rgzlp64b4nqhhpseb5w7ntx2w6vhnq";

contract CarVoxelSystem is VoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    // registerExtension(world, "CarSystem", IWorld(world).tenet_CarVoxelSystem_eventHandler.selector);
  }

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

  function enterWorld(bytes32 entity) public override {}

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public pure override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: CarID });
  }

  function activate(bytes32 entity) public override returns (bytes memory) {
    uint16 velocity = Car.getVelocity(entity);
    travelDist(entity, velocity);
  }

  function travelDist(bytes32 entity, uint16 dist) public view returns (uint256) {
    PositionData memory position = Position.get(entity);
    VoxelCoord memory coord = VoxelCoord(position.x, position.y, position.z);
    BlockDirection prevDirection = BlockDirection(Car.getPrevDirection(entity));
    for (uint direction = 0; direction < 6; direction++) {
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
      VoxelCoord memory underneathCoord = getPositionAtDirection(neighbourCoord, BlockDirection.Down);
      bytes32[] memory entitiesAtPosition = getKeysWithValue(
        PositionTableId,
        Position.encode(underneathCoord.x, underneathCoord.y, underneathCoord.z)
      );

      if (entitiesAtPosition.length != 1) {
        // there is no way this voxel is a road, so don't do anything
        continue;
      }
      if (VoxelType.get(entitiesAtPosition[0]).voxelTypeId == RoadID) {
        // move the car to the new position
        IWorld(_world()).tenet_MoveSystem_tryMove(entity, blockDirection);
        Car.setPrevDirection(entity, uint8(calculateBlockDirection(coord, neighbourCoord)));
      }
    }
    if (dist > 0) {
      travelDist(entity, dist - 1);
    }
  }

  function onNewNeighbour(
    bytes16 callerNamespace,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal override returns (bool changedEntity) {}

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return Car.get(entityId).hasValue;
  }

  function runInteraction(
    // bytes16 callerNamespace,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections
  ) internal override returns (bool changedEntity) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public override returns (bytes32, bytes32[] memory) {
    return super.eventHandler(centerEntityId, neighbourEntityIds);
  }
}
