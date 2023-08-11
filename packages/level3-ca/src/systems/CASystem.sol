// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { CA } from "@tenet-base-ca/src/prototypes/CA.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { Level3AirVoxelID, RoadVoxelID } from "@tenet-level3-ca/src/Constants.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { REGISTER_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_ADDRESS } from "../Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract CASystem is CA {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function emptyVoxelId() internal pure override returns (bytes32) {
    return Level3AirVoxelID;
  }

  function registerCA() public override {
    bytes32[] memory caVoxelTypes = new bytes32[](2);
    caVoxelTypes[0] = Level3AirVoxelID;
    caVoxelTypes[1] = RoadVoxelID;

    safeCall(
      getRegistryAddress(),
      abi.encodeWithSignature(REGISTER_CA_SIG, "Level 3 CA", "Has road", caVoxelTypes),
      "registerCA"
    );
  }

  function terrainGen(
    address callerAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) internal override {
    revert("Level2CA: Terrain gen not implemented");
  }
}
