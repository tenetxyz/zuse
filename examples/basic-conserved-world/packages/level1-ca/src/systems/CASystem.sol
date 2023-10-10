// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { CA } from "@tenet-base-ca/src/prototypes/CA.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID, FighterVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { REGISTER_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { EMPTY_ID } from "./LibTerrainSystem.sol";
import { REGISTRY_ADDRESS } from "../Constants.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { TerrainGenType } from "@tenet-base-ca/src/Constants.sol";

contract CASystem is CA {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function emptyVoxelId() internal pure override returns (bytes32) {
    return AirVoxelID;
  }

  function registerCA() public override {
    bytes32[] memory caVoxelTypes = new bytes32[](5);
    caVoxelTypes[0] = AirVoxelID;
    caVoxelTypes[1] = GrassVoxelID;
    caVoxelTypes[2] = DirtVoxelID;
    caVoxelTypes[3] = BedrockVoxelID;
    caVoxelTypes[4] = FighterVoxelID;

    safeCall(
      getRegistryAddress(),
      abi.encodeWithSignature(REGISTER_CA_SIG, "Level 1 CA", "Has grass, dirt, bedrock, and fighter", caVoxelTypes),
      "registerCA"
    );
  }

  function getTerrainVoxelId(VoxelCoord memory coord) public view override returns (bytes32) {
    address callerAddress = _msgSender();
    bytes memory returnData = safeStaticCall(
      callerAddress,
      abi.encodeWithSignature("getTerrainVoxel((int32,int32,int32))", coord),
      "terrainSelector"
    );
    return abi.decode(returnData, (bytes32));
  }

  function terrainGen(
    address callerAddress,
    TerrainGenType terrainGenType,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) internal override returns (bytes32) {
    bytes32 caEntity = super.terrainGen(callerAddress, terrainGenType, voxelTypeId, coord, entity);
    // Notify world of terrain gen
    // TODO: Should this be in base-ca?
    safeCall(
      callerAddress,
      abi.encodeWithSignature("onTerrainGen(bytes32,(int32,int32,int32))", voxelTypeId, coord),
      "onTerrainGen"
    );
    return caEntity;
  }

  function callVoxelEnterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) internal override {
    IWorld(_world()).voxelEnterWorld(voxelTypeId, coord, caEntity);
  }

  function callVoxelExitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) internal override {
    IWorld(_world()).voxelExitWorld(voxelTypeId, coord, caEntity);
  }

  function callGetVoxelVariant(
    bytes32 voxelTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bytes32) {
    return IWorld(_world()).getVoxelVariant(voxelTypeId, caEntity, caNeighbourEntityIds, childEntityIds, parentEntity);
  }
}
