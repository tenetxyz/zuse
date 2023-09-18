// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { CA } from "@tenet-base-ca/src/prototypes/CA.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { REGISTRY_ADDRESS, AirVoxelID, ElectronVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { REGISTER_CA_SIG } from "@tenet-registry/src/Constants.sol";
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

  function getTerrainVoxelId(VoxelCoord memory coord) internal pure override returns (bytes32) {
    revert("BaseCA: Terrain gen not implemented");
  }

  function callVoxelEnterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) internal override {
    IWorld(_world()).voxelEnterWorld(voxelTypeId, coord, caEntity);
  }

  function callVoxelExitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) internal override {
    IWorld(_world()).voxelExitWorld(voxelTypeId, coord, caEntity);
  }

  function callVoxelRunInteraction(
    bytes4 interactionSelector,
    bytes32 voxelTypeId,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bytes32[] memory) {
    return
      IWorld(_world()).voxelRunInteraction(
        interactionSelector,
        voxelTypeId,
        caInteractEntity,
        caNeighbourEntityIds,
        childEntityIds,
        parentEntity
      );
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
