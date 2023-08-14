// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { CA } from "@tenet-base-ca/src/prototypes/CA.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { Level2AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID, FighterVoxelID } from "@tenet-level2-ca/src/Constants.sol";
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
    bytes32[] memory caVoxelTypes = new bytes32[](5);
    caVoxelTypes[0] = Level2AirVoxelID;
    caVoxelTypes[1] = GrassVoxelID;
    caVoxelTypes[2] = DirtVoxelID;
    caVoxelTypes[3] = BedrockVoxelID;
    caVoxelTypes[4] = FighterVoxelID;

    safeCall(
      getRegistryAddress(),
      abi.encodeWithSignature(REGISTER_CA_SIG, "Level 2 CA", "Has road and signal", caVoxelTypes),
      "registerCA"
    );
  }

  function terrainGen(
    address callerAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) internal override {
    // If there is no entity at this position, try mining the terrain voxel at this position
    bytes32 terrainVoxelTypeId = IWorld(_world()).ca_LibTerrainSystem_getTerrainVoxel(coord);
    require(terrainVoxelTypeId != EMPTY_ID && terrainVoxelTypeId == voxelTypeId, "invalid terrain voxel type");
    super.terrainGen(callerAddress, voxelTypeId, coord, entity);
  }
}
