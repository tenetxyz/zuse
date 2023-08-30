// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;
address constant CA_ADDRESS = 0x663F3ad617193148711d28f5334eE4Ed07016602;

bytes32 constant WireVoxelID = bytes32(keccak256("wire"));
bytes32 constant SignalVoxelID = bytes32(keccak256("signal"));
bytes32 constant InvertedSignalVoxelID = bytes32(keccak256("invertedsignal"));
bytes32 constant SignalSourceVoxelID = bytes32(keccak256("signalsource"));
bytes32 constant OrangeFlowerVoxelID = bytes32(keccak256("orangeflower"));
bytes32 constant LogVoxelID = bytes32(keccak256("log"));
bytes32 constant SandVoxelID = bytes32(keccak256("sand"));
bytes32 constant LavaVoxelID = bytes32(keccak256("lava"));
bytes32 constant IceVoxelID = bytes32(keccak256("ice"));
bytes32 constant ThermoGenVoxelID = bytes32(keccak256("thermogen"));
bytes32 constant PowerWireVoxelID = bytes32(keccak256("powerwire"));
bytes32 constant StorageVoxelID = bytes32(keccak256("storage"));
bytes32 constant LightBulbVoxelID = bytes32(keccak256("lightbulb"));
bytes32 constant PowerSignalVoxelID = bytes32(keccak256("powersignal"));