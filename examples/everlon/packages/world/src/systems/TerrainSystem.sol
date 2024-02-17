// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { ISimInitSystem } from "@tenet-base-simulator/src/codegen/world/ISimInitSystem.sol";
import { Position, ReversePosition, ObjectType, ObjectEntity, ReverseObjectEntity, Faucet, FaucetData, FaucetTableId, OwnedBy, TerrainProperties, TerrainPropertiesTableId } from "@tenet-world/src/codegen/Tables.sol";
import { TerrainData } from "@tenet-world/src/Types.sol";

import { safeStaticCall, safeCall } from "@tenet-utils/src/CallUtils.sol";
import { SIMULATOR_ADDRESS, AirObjectID, FaucetObjectID } from "@tenet-world/src/Constants.sol";
import { TerrainSystem as TerrainProtoSystem } from "@tenet-base-world/src/systems/TerrainSystem.sol";

// Spline functions and inspiration from https://github.com/latticexyz/opcraft/blob/main/packages/contracts/src/libraries/LibTerrain.sol
contract TerrainSystem is TerrainProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function emptyObjectId() internal pure override returns (bytes32) {
    return AirObjectID;
  }

  function spawnInitialFaucets() public {
    bytes32[][] memory numFaucets = getKeysInTable(FaucetTableId);
    require(numFaucets.length == 0, "TerrainSystem: Faucets already spawned");

    VoxelCoord memory faucetCoord1 = VoxelCoord(197, 27, 203);
    setFaucetAgent(faucetCoord1);

    VoxelCoord memory faucetCoord2 = VoxelCoord(173, 31, 241);
    setFaucetAgent(faucetCoord2);

    VoxelCoord memory faucetCoord3 = VoxelCoord(152, 42, 159);
    setFaucetAgent(faucetCoord3);

    VoxelCoord memory faucetCoord4 = VoxelCoord(263, 28, 115);
    setFaucetAgent(faucetCoord4);
  }

  function setFaucetAgent(VoxelCoord memory coord) internal {
    bytes32 objectTypeId = FaucetObjectID;

    // Create entity
    bytes32 eventEntityId = getUniqueEntity();
    Position.set(eventEntityId, coord.x, coord.y, coord.z);
    ReversePosition.set(coord.x, coord.y, coord.z, eventEntityId);
    ObjectType.set(eventEntityId, objectTypeId);
    bytes32 objectEntityId = getUniqueEntity();
    ObjectEntity.set(eventEntityId, objectEntityId);
    ReverseObjectEntity.set(objectEntityId, eventEntityId);

    // This will place the agent, so it will check if the object there is air
    bytes32 terrainObjectTypeId = IWorld(_world()).getTerrainObjectTypeId(coord);
    require(
      terrainObjectTypeId == emptyObjectId() || terrainObjectTypeId == objectTypeId,
      "TerrainSystem: Terrain object type id does not match"
    );

    ObjectProperties memory faucetProperties = IWorld(_world()).enterWorld(objectTypeId, coord, objectEntityId);
    ISimInitSystem(SIMULATOR_ADDRESS).initObject(objectEntityId, faucetProperties);

    // TODO: Make this the world contract, so that FaucetSystem can build using it
    OwnedBy.set(objectEntityId, address(0)); // Set owner to 0 so no one can claim it
    Faucet.set(
      objectEntityId,
      FaucetData({
        claimers: new address[](0),
        claimerAmounts: new uint256[](0),
        claimerObjectEntityIds: abi.encode(new bytes32[][](0))
      })
    );
  }

  function getTerrainObjectTypeId(VoxelCoord memory coord) public view override returns (bytes32) {
    return getTerrainObjectData(coord).objectTypeId;
  }

  function getTerrainObjectProperties(
    VoxelCoord memory coord,
    ObjectProperties memory requestedProperties
  ) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    // use cache if possible
    if (hasKey(TerrainPropertiesTableId, TerrainProperties.encodeKeyTuple(coord.x, coord.y, coord.z))) {
      bytes memory encodedTerrainProperties = TerrainProperties.get(coord.x, coord.y, coord.z);
      return abi.decode(encodedTerrainProperties, (ObjectProperties));
    }

    objectProperties = getTerrainObjectData(coord).properties;

    TerrainProperties.set(coord.x, coord.y, coord.z, abi.encode(objectProperties));

    return objectProperties;
  }

  function getTerrainObjectData(VoxelCoord memory coord) internal view returns (TerrainData memory) {
    return IWorld(_world()).world_LibTerrainSystem_getTerrainBlock(coord);
  }
}
