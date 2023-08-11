// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-ca/src/codegen/world/IWorld.sol";
import { CA } from "../prototypes/CA.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, AirVoxelID, ElectronVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { REGISTER_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract CASystem is CA {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function registerCA() public override {
    bytes32[] memory caVoxelTypes = new bytes32[](2);
    caVoxelTypes[0] = AirVoxelID;
    caVoxelTypes[1] = ElectronVoxelID;

    safeCall(
      getRegistryAddress(),
      abi.encodeWithSignature(REGISTER_CA_SIG, "Base CA", "Has electrons", caVoxelTypes),
      "registerCA"
    );
  }

  function emptyVoxelId() internal pure override returns (bytes32) {
    return AirVoxelID;
  }

  function terrainGen(
    address callerAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) internal override {
    revert("BaseCA: Terrain gen not implemented");
  }
}
