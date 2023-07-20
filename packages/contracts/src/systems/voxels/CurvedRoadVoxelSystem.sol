// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "../../prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Occurrence, VoxelTypeData, VoxelVariantsData, CurvedRoad, CurvedRoadData } from "@tenet-contracts/src/codegen/Tables.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";
import { VoxelVariantsKey, BlockDirection } from "@tenet-contracts/src/Types.sol";
import { getBlockDirectionStr } from "@tenet-contracts/src/Utils.sol";
import { TENET_NAMESPACE } from "../../Constants.sol";

bytes32 constant CurvedRoadID = bytes32(keccak256("curvedroad"));

bytes32 constant CurvedRoadEastID = bytes32(keccak256("curvedroad.east"));
bytes32 constant CurvedRoadSouthID = bytes32(keccak256("curvedroad.south"));
bytes32 constant CurvedRoadWestID = bytes32(keccak256("curvedroad.west"));
bytes32 constant CurvedRoadNorthID = bytes32(keccak256("curvedroad.north"));

string constant CurvedRoadEastTexture = "bafkreiandudlqsnhgmayd7nmmmzz44qhhysfeg7kkcqi6qk3m6toy5hxfq";
string constant CurvedRoadSouthTexture = "bafkreic52rkouzu2pcibatfew2umufogplzj2geu75c5qyid7c5wshjwdq";
string constant CurvedRoadWestTexture = "bafkreidzp7rxbrmlu6bu65bgzh3mi6yharhzshvcpdok7lgjwkjgjte4uq";
string constant CurvedRoadNorthTexture = "bafkreibhbp5yxgfpqe5hzojp6iquusiuouo36lwp2bxpk6522cl4kprwvm";

// TODO: make uvwrap
string constant CurvedRoadEastUVWrap = "bafkreiei537c72c3vktatoegeoaa4jfig4z7ddib4nzohnf4tjk2uo45xu";
string constant CurvedRoadSouthUVWrap = "bafkreibbwelrf5znljt2xgjn42rpkcnrcb2bnm2pwj66r74dfiqmnsinem";
string constant CurvedRoadWestUVWrap = "bafkreiecjopkcrxut6ndxuxnp522xjmsr6qvmrmrl7pawf5jptlykgivu4";
string constant CurvedRoadNorthUVWrap = "bafkreidhlj2ydby35yhxn52sldydwofzsqaiy3dsff7lzmhksyqzv45yha";

contract CurvedRoadVoxelSystem is VoxelType {
  function registerVoxel() public override {
    IWorld world = IWorld(_world());

    VoxelVariantsData memory curvedRoadEastVariant;
    curvedRoadEastVariant.blockType = NoaBlockType.BLOCK;
    curvedRoadEastVariant.opaque = true;
    curvedRoadEastVariant.solid = true;
    string[] memory curvedRoadEastMaterials = new string[](1);
    curvedRoadEastMaterials[0] = CurvedRoadEastTexture;
    curvedRoadEastVariant.materials = abi.encode(curvedRoadEastMaterials);
    curvedRoadEastVariant.uvWrap = CurvedRoadEastUVWrap;
    world.tenet_VoxelRegistrySys_registerVoxelVariant(CurvedRoadEastID, curvedRoadEastVariant);

    VoxelVariantsData memory curvedRoadSouthVariant;
    curvedRoadSouthVariant.blockType = NoaBlockType.BLOCK;
    curvedRoadSouthVariant.opaque = true;
    curvedRoadSouthVariant.solid = true;
    string[] memory curvedRoadSouthMaterials = new string[](1);
    curvedRoadSouthMaterials[0] = CurvedRoadSouthTexture;
    curvedRoadSouthVariant.materials = abi.encode(curvedRoadSouthMaterials);
    curvedRoadSouthVariant.uvWrap = CurvedRoadSouthUVWrap;
    world.tenet_VoxelRegistrySys_registerVoxelVariant(CurvedRoadSouthID, curvedRoadSouthVariant);

    VoxelVariantsData memory curvedRoadWestVariant;
    curvedRoadWestVariant.blockType = NoaBlockType.BLOCK;
    curvedRoadWestVariant.opaque = true;
    curvedRoadWestVariant.solid = true;
    string[] memory curvedRoadWestMaterials = new string[](1);
    curvedRoadWestMaterials[0] = CurvedRoadWestTexture;
    curvedRoadWestVariant.materials = abi.encode(curvedRoadWestMaterials);
    curvedRoadWestVariant.uvWrap = CurvedRoadWestUVWrap;
    world.tenet_VoxelRegistrySys_registerVoxelVariant(CurvedRoadWestID, curvedRoadWestVariant);

    VoxelVariantsData memory curvedRoadNorthVariant;
    curvedRoadNorthVariant.blockType = NoaBlockType.BLOCK;
    curvedRoadNorthVariant.opaque = true;
    curvedRoadNorthVariant.solid = true;
    string[] memory curvedRoadNorthMaterials = new string[](1);
    curvedRoadNorthMaterials[0] = CurvedRoadNorthTexture;
    curvedRoadNorthVariant.materials = abi.encode(curvedRoadNorthMaterials);
    curvedRoadNorthVariant.uvWrap = CurvedRoadNorthUVWrap;
    world.tenet_VoxelRegistrySys_registerVoxelVariant(CurvedRoadNorthID, curvedRoadNorthVariant);

    world.tenet_VoxelRegistrySys_registerVoxelType(
      "CurvedRoad",
      CurvedRoadID,
      TENET_NAMESPACE,
      CurvedRoadEastID,
      world.tenet_CurvedRoadVoxelS_variantSelector.selector,
      world.tenet_CurvedRoadVoxelS_enterWorld.selector,
      world.tenet_CurvedRoadVoxelS_exitWorld.selector,
      world.tenet_CurvedRoadVoxelS_activate.selector
    );
  }

  function enterWorld(bytes32 entity) public override {
    CurvedRoad.set(
      entity,
      CurvedRoadData({
        onDirection: uint8(BlockDirection.East),
        offDirection: uint8(BlockDirection.East),
        hasValue: true
      })
    );
  }

  function exitWorld(bytes32 entity) public override {
    CurvedRoad.deleteRecord(entity);
  }

  function variantSelector(bytes32 entity) public view override returns (VoxelVariantsKey memory) {
    (BlockDirection direction, bool isActive) = getDirection(entity);
    BlockDirection newDirection;

    if (direction == BlockDirection.East) {
      return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: CurvedRoadEastID });
    } else if (direction == BlockDirection.South) {
      return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: CurvedRoadSouthID });
    } else if (direction == BlockDirection.West) {
      return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: CurvedRoadWestID });
    } else if (direction == BlockDirection.North) {
      return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: CurvedRoadNorthID });
    }
  }

  function activate(bytes32 entity) public override returns (bytes memory) {
    (BlockDirection direction, bool isActive) = getDirection(entity);
    BlockDirection newDirection;

    if (direction == BlockDirection.East) {
      newDirection = BlockDirection.South;
    } else if (direction == BlockDirection.South) {
      newDirection = BlockDirection.West;
    } else if (direction == BlockDirection.West) {
      newDirection = BlockDirection.North;
    } else if (direction == BlockDirection.North) {
      newDirection = BlockDirection.East;
    }
    if (isActive) {
      CurvedRoad.setOnDirection(entity, uint8(newDirection));
    } else {
      CurvedRoad.setOffDirection(entity, uint8(newDirection));
    }
    return abi.encodePacked("Now facing: ", getBlockDirectionStr(newDirection));
  }

  function getDirection(bytes32 entity) private view returns (BlockDirection, bool) {
    uint8 direction;
    CurvedRoadData memory curvedRoad = CurvedRoad.get(entity);
    // bool isActive = Signal.getActive(entity);
    bool isActive = true;
    if (isActive) {
      direction = curvedRoad.onDirection;
    } else {
      direction = curvedRoad.offDirection;
    }
    return (BlockDirection(direction), isActive);
  }
}
