// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { CA } from "@tenet-base-ca/src/prototypes/CA.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { Level2AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { REGISTER_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { EMPTY_ID } from "./LibTerrainSystem.sol";
import { REGISTRY_ADDRESS } from "../Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract CASystem is CA {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function emptyVoxelId() internal pure override returns (bytes32) {
    return Level2AirVoxelID;
  }

  function registerCA() public override {
    bytes32[] memory caVoxelTypes = new bytes32[](4);
    caVoxelTypes[0] = Level2AirVoxelID;
    caVoxelTypes[1] = GrassVoxelID;
    caVoxelTypes[2] = DirtVoxelID;
    caVoxelTypes[3] = BedrockVoxelID;

    safeCall(
      getRegistryAddress(),
      abi.encodeWithSignature(REGISTER_CA_SIG, "Level 2 CA", "Has road and signal", caVoxelTypes),
      "registerCA"
    );
  }

  function getTerrainVoxelId(VoxelCoord memory coord) public view override returns (bytes32) {
    return IWorld(_world()).ca_LibTerrainSystem_getTerrainVoxel(coord);
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
