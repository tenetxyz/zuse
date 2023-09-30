// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { BodyPhysics, BodyPhysicsData, VoxelTypeProperties } from "@tenet-world/src/codegen/Tables.sol";
import { getTerrainVoxelId } from "@tenet-base-ca/src/CallUtils.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";

uint256 constant TOTAL_MASS_IN_CHUNK = 1000;
uint256 constant TOTAL_ENERGY_IN_CHUNK = 1000;
int256 constant Y_AIR_THRESHOLD = 100;
int256 constant Y_GROUND_THRESHOLD = 0;

contract LibTerrainSystem is System {
  function getTerrainBodyPhysicsData(
    address caAddress,
    VoxelCoord memory coord
  ) public view returns (bytes32, BodyPhysicsData memory) {
    BodyPhysicsData memory data;

    bytes32 voxelTypeId = getTerrainVoxelId(caAddress, coord);
    (uint256 terrainMass, uint256 terrainEnergy) = getTerrainProperties(coord);

    data.mass = terrainMass;
    data.energy = terrainEnergy;
    data.velocity = abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 }));
    data.lastUpdateBlock = block.number;

    return (voxelTypeId, data);
  }

  function getTerrainProperties(VoxelCoord memory coord) public view returns (uint256, uint256) {
    // Use perlin noise to calculate mass and energy

    // Convert VoxelCoord to int256 for use with the noise functions
    int256 x = int256(coord.x);
    int256 y = int256(coord.y);
    int256 z = int256(coord.z);

    // Define some scaling factors for the noise functions
    int256 denom = 999;
    uint8 precision = 64;

    // Step 1: Determine whether we are in air or ground region
    int128 airGroundNoise = IWorld(_world()).noise(x, y, z, denom, precision);
    bool isAir = y > Y_AIR_THRESHOLD;
    bool isGround = y < Y_GROUND_THRESHOLD;
    bool isTerrain = !isAir && !isGround && airGroundNoise > 0;

    uint256 mass = 0;
    uint256 energy = 0;

    if (isGround || isTerrain) {
      // Step 2: Determine the mass of the ground
      int128 massNoise = IWorld(_world()).noise2d(x, z, denom, precision);
      mass = uint256((massNoise * int128(int(TOTAL_MASS_IN_CHUNK))) / (denom * 2));

      // Step 3: Determine the energy of the ground
      int128 energyNoise = IWorld(_world()).noise2d(x + denom, z + denom, denom, precision); // Offset coordinates for variation
      energy = uint256((energyNoise * int128(int(TOTAL_ENERGY_IN_CHUNK))) / (denom * 2)); // Normalize and scale
    }

    return (mass, energy);
  }

  // Called by CA's on terrain gen
  function onTerrainGen(bytes32 voxelTypeId, VoxelCoord memory coord) public {
    // address caAddress = _msgSender();
    (uint256 terrainMass, uint256 terrainEnergy) = getTerrainProperties(coord);
    require(terrainMass == VoxelTypeProperties.get(voxelTypeId), "Terrain mass does not match voxel type mass");
  }

  function setTerrainSelector(VoxelCoord memory coord, address contractAddress, bytes4 terrainSelector) public {
    // TODO: Make this be any CA address
    address caAddress = BASE_CA_ADDRESS;
    safeCall(
      caAddress,
      abi.encodeWithSignature(
        "setTerrainSelector((int32,int32,int32),address,bytes4)",
        coord,
        contractAddress,
        terrainSelector
      ),
      string(abi.encode("setTerrainSelector ", coord, " ", terrainSelector))
    );
  }
}
