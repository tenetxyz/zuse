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
    bytes32[] memory caBodyTypes = new bytes32[](2);
    caBodyTypes[0] = AirVoxelID;
    caBodyTypes[1] = ElectronVoxelID;

    safeCall(
      getRegistryAddress(),
      abi.encodeWithSignature(REGISTER_CA_SIG, "Base CA", "Has electrons", caBodyTypes),
      "registerCA"
    );
  }

  function emptyBodyId() internal pure override returns (bytes32) {
    return AirVoxelID;
  }

  function terrainGen(
    address callerAddress,
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) internal override {
    revert("BaseCA: Terrain gen not implemented");
  }

  function callBodyEnterWorld(bytes32 bodyTypeId, VoxelCoord memory coord, bytes32 caEntity) internal override {
    IWorld(_world()).bodyEnterWorld(bodyTypeId, coord, caEntity);
  }

  function callBodyExitWorld(bytes32 bodyTypeId, VoxelCoord memory coord, bytes32 caEntity) internal override {
    IWorld(_world()).bodyExitWorld(bodyTypeId, coord, caEntity);
  }

  function callBodyRunInteraction(
    bytes4 interactionSelector,
    bytes32 bodyTypeId,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bytes32[] memory) {
    return
      IWorld(_world()).bodyRunInteraction(
        interactionSelector,
        bodyTypeId,
        caInteractEntity,
        caNeighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }

  function callGetBodyVariant(
    bytes32 bodyTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bytes32) {
    return IWorld(_world()).getBodyVariant(bodyTypeId, caEntity, caNeighbourEntityIds, childEntityIds, parentEntity);
  }
}
