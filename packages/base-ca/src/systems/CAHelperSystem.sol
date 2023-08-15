// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-ca/src/codegen/world/IWorld.sol";
import { CAHelper } from "../prototypes/CAHelper.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, AirVoxelID, ElectronVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { REGISTER_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract CAHelperSystem is CAHelper {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function voxelEnterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) public override {
    super.voxelEnterWorld(voxelTypeId, coord, caEntity);
  }

  function getVoxelVariant(
    bytes32 voxelTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32) {
    return super.getVoxelVariant(voxelTypeId, caEntity, caNeighbourEntityIds, childEntityIds, parentEntity);
  }

  function voxelExitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) public override {
    super.voxelExitWorld(voxelTypeId, coord, caEntity);
  }

  function voxelRunInteraction(
    bytes4 interactionSelector,
    bytes32 voxelTypeId,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32[] memory) {
    return
      super.voxelRunInteraction(
        interactionSelector,
        voxelTypeId,
        caInteractEntity,
        caNeighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }
}
