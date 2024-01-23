// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { ITerrainSystem } from "@tenet-base-world/src/codegen/world/ITerrainSystem.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

import { ObjectTypeRegistry, ObjectTypeRegistryTableId } from "@tenet-registry/src/codegen/tables/ObjectTypeRegistry.sol";

import { MonumentClaimedArea, MonumentClaimedAreaData, MonumentClaimedAreaTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { MonumentBounties, MonumentBountiesData, MonumentBountiesTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { MonumentToken, MonumentTokenTableId } from "@tenet-derived/src/codegen/Tables.sol";

import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { ObjectEntity, ObjectEntityTableId } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";

import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord, getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";

import { WORLD_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { coordToShardCoord, voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { int32ToUint32, uint32ToInt32 } from "@tenet-utils/src/TypeUtils.sol";
import { SHARD_DIM } from "@tenet-world/src/Constants.sol";
import { REGISTRY_ADDRESS } from "@tenet-derived/src/Constants.sol";

contract MonumentBountiesSystem is System {
  function addMonumentBounty(
    uint256 bountyAmount,
    bytes32[] memory objectTypeIds,
    VoxelCoord[] memory relativePositions,
    string memory name,
    string memory description
  ) public returns (bytes32) {
    uint256 senderTokens = MonumentToken.get(_msgSender());
    require(
      senderTokens >= bountyAmount,
      "MonumentBountiesSystem: You do not have enough tokens to create this bounty"
    );
    require(bytes(name).length > 0, "MonumentBountiesSystem: Name must be non-empty");

    require(objectTypeIds.length > 0, "MonumentBountiesSystem: Must specify at least one object type ID");
    require(
      objectTypeIds.length == relativePositions.length,
      "MonumentBountiesSystem: Number of object type IDs must match number of relative positions"
    );
    for (uint256 i = 0; i < objectTypeIds.length; i++) {
      require(
        hasKey(
          IStore(REGISTRY_ADDRESS),
          ObjectTypeRegistryTableId,
          ObjectTypeRegistry.encodeKeyTuple(objectTypeIds[i])
        ),
        "MonumentBountiesSystem: Object type ID has not been registered"
      );
    }

    require(
      voxelCoordsAreEqual(relativePositions[0], VoxelCoord({ x: 0, y: 0, z: 0 })),
      "MonumentBountiesSystem: First relative position must be (0, 0, 0)"
    );

    bytes32 bountyId = getUniqueEntity();
    address[] memory emptyAddressArray;
    MonumentBounties.set(
      bountyId,
      MonumentBountiesData({
        creator: _msgSender(),
        bountyAmount: bountyAmount,
        claimedBy: address(0),
        claimedAreaX: 0,
        claimedAreaY: 0,
        claimedAreaZ: 0,
        mintedBy: emptyAddressArray,
        objectTypeIds: objectTypeIds,
        relativePositions: abi.encode(relativePositions),
        name: name,
        description: description
      })
    );

    // transfer out from sender
    if (bountyAmount > 0) {
      MonumentToken.set(_msgSender(), senderTokens - bountyAmount);
    }
    return bountyId;
  }

  function boostMonumentBounty(bytes32 bountyId, uint256 numAmount) public {
    require(
      hasKey(MonumentBountiesTableId, MonumentBounties.encodeKeyTuple(bountyId)),
      "MonumentBountiesSystem: Bounty ID does not exist"
    );
    MonumentBountiesData memory bountyData = MonumentBounties.get(bountyId);
    require(bountyData.claimedBy == address(0), "MonumentBountiesSystem: Bounty has already been claimed");
    if (numAmount == 0) {
      // Mint token
      // check if already minted
      address minter = tx.origin;
      for (uint256 i = 0; i < bountyData.mintedBy.length; i++) {
        if (bountyData.mintedBy[i] == minter) {
          revert("MonumentBountiesSystem: You have already minted this bounty");
        }
      }
      // add to mintedby array
      address[] memory newMintedBy = new address[](bountyData.mintedBy.length + 1);
      for (uint256 i = 0; i < bountyData.mintedBy.length; i++) {
        newMintedBy[i] = bountyData.mintedBy[i];
      }
      newMintedBy[bountyData.mintedBy.length] = minter;
      MonumentBounties.setMintedBy(bountyId, newMintedBy);
      MonumentBounties.setBountyAmount(bountyId, bountyData.bountyAmount + 1);
    } else {
      require(
        MonumentToken.get(_msgSender()) >= numAmount,
        "MonumentBountiesSystem: You do not have enough tokens to boost this bounty"
      );

      MonumentBounties.setBountyAmount(bountyId, bountyData.bountyAmount + numAmount);
      MonumentToken.set(_msgSender(), MonumentToken.get(_msgSender()) - numAmount);
    }
  }

  function claimMonumentBounty(
    bytes32 bountyId,
    VoxelCoord memory monumentClaimedArea,
    VoxelCoord memory baseWorldCoord
  ) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    require(
      hasKey(MonumentBountiesTableId, MonumentBounties.encodeKeyTuple(bountyId)),
      "MonumentBountiesSystem: Bounty ID does not exist"
    );
    MonumentBountiesData memory bountyData = MonumentBounties.get(bountyId);
    require(bountyData.claimedBy == address(0), "MonumentBountiesSystem: Bounty has already been claimed");

    require(
      hasKey(
        MonumentClaimedAreaTableId,
        MonumentClaimedArea.encodeKeyTuple(monumentClaimedArea.x, monumentClaimedArea.y, monumentClaimedArea.z)
      ),
      "MonumentBountiesSystem: Monument claimed area does not exist"
    );

    // Assert that baseWorldCoord is within the claimed area, ignore Y values
    VoxelCoord memory monumentClaimedAreaUpperCorner = VoxelCoord(
      monumentClaimedArea.x +
        uint32ToInt32(
          MonumentClaimedArea.getLength(monumentClaimedArea.x, monumentClaimedArea.y, monumentClaimedArea.z)
        ),
      0,
      monumentClaimedArea.z +
        uint32ToInt32(MonumentClaimedArea.getWidth(monumentClaimedArea.x, monumentClaimedArea.y, monumentClaimedArea.z))
    );
    require(
      baseWorldCoord.x >= monumentClaimedArea.x &&
        baseWorldCoord.x < monumentClaimedAreaUpperCorner.x &&
        baseWorldCoord.z >= monumentClaimedArea.z &&
        baseWorldCoord.z < monumentClaimedAreaUpperCorner.z,
      "MonumentBountiesSystem: Base world coord is not within the claimed area"
    );

    VoxelCoord[] memory relativePositions = abi.decode(bountyData.relativePositions, (VoxelCoord[]));
    // Go through each relative position, aplpy it to the base world coord, and check if the object type id matches
    for (uint256 i = 0; i < bountyData.objectTypeIds.length; i++) {
      VoxelCoord memory absolutePosition = VoxelCoord({
        x: baseWorldCoord.x + relativePositions[i].x,
        y: baseWorldCoord.y + relativePositions[i].y,
        z: baseWorldCoord.z + relativePositions[i].z
      });
      bytes32 entityId = getEntityAtCoord(worldStore, absolutePosition);
      bytes32 objectTypeId;
      if (entityId == bytes32(0)) {
        // then it's the terrain
        objectTypeId = ITerrainSystem(WORLD_ADDRESS).getTerrainObjectTypeId(absolutePosition);
      } else {
        objectTypeId = ObjectType.get(worldStore, entityId);
      }
      if (objectTypeId != bountyData.objectTypeIds[i]) {
        revert("MonumentBountiesSystem: Submission does not match bounty");
      }
    }

    address claimer = MonumentClaimedArea.getOwner(monumentClaimedArea.x, monumentClaimedArea.y, monumentClaimedArea.z);
    MonumentBounties.setClaimedBy(bountyId, claimer);
    MonumentBounties.setClaimedAreaX(bountyId, monumentClaimedArea.x);
    MonumentBounties.setClaimedAreaY(bountyId, monumentClaimedArea.y);
    MonumentBounties.setClaimedAreaZ(bountyId, monumentClaimedArea.z);

    MonumentToken.set(claimer, MonumentToken.get(claimer) + bountyData.bountyAmount);
  }
}
