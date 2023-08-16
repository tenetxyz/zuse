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

  function bodyEnterWorld(bytes32 bodyTypeId, VoxelCoord memory coord, bytes32 caEntity) public override {
    super.bodyEnterWorld(bodyTypeId, coord, caEntity);
  }

  function getBodyVariant(
    bytes32 bodyTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32) {
    return super.getBodyVariant(bodyTypeId, caEntity, caNeighbourEntityIds, childEntityIds, parentEntity);
  }

  function bodyExitWorld(bytes32 bodyTypeId, VoxelCoord memory coord, bytes32 caEntity) public override {
    super.bodyExitWorld(bodyTypeId, coord, caEntity);
  }

  function bodyRunInteraction(
    bytes4 interactionSelector,
    bytes32 bodyTypeId,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32[] memory) {
    return
      super.bodyRunInteraction(
        interactionSelector,
        bodyTypeId,
        caInteractEntity,
        caNeighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }
}
