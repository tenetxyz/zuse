// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

// Import schema type
import { SchemaType } from "@latticexyz/schema-type/src/solidity/SchemaType.sol";

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { Schema, SchemaLib } from "@latticexyz/store/src/Schema.sol";
import { PackedCounter, PackedCounterLib } from "@latticexyz/store/src/PackedCounter.sol";

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("DecisionRuleRegi")));
bytes32 constant DecisionRuleRegistryTableId = _tableId;

library DecisionRuleRegistry {
  /** Get the table's key schema */
  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](3);
    _schema[0] = SchemaType.BYTES32;
    _schema[1] = SchemaType.BYTES32;
    _schema[2] = SchemaType.ADDRESS;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's value schema */
  function getValueSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.BYTES;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's key names */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](3);
    keyNames[0] = "srcVoxelTypeId";
    keyNames[1] = "targetVoxelTypeId";
    keyNames[2] = "worldAddress";
  }

  /** Get the table's field names */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](1);
    fieldNames[0] = "decisionRules";
  }

  /** Register the table's key schema, value schema, key names and value names */
  function register() internal {
    StoreSwitch.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Register the table's key schema, value schema, key names and value names (using the specified store) */
  function register(IStore _store) internal {
    _store.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Get decisionRules */
  function get(
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress
  ) internal view returns (bytes memory decisionRules) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (bytes(_blob));
  }

  /** Get decisionRules (using the specified store) */
  function get(
    IStore _store,
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress
  ) internal view returns (bytes memory decisionRules) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (bytes(_blob));
  }

  /** Set decisionRules */
  function set(
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress,
    bytes memory decisionRules
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    StoreSwitch.setField(_tableId, _keyTuple, 0, bytes((decisionRules)), getValueSchema());
  }

  /** Set decisionRules (using the specified store) */
  function set(
    IStore _store,
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress,
    bytes memory decisionRules
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    _store.setField(_tableId, _keyTuple, 0, bytes((decisionRules)), getValueSchema());
  }

  /** Get the length of decisionRules */
  function length(
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress
  ) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 0, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /** Get the length of decisionRules (using the specified store) */
  function length(
    IStore _store,
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress
  ) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 0, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * Get an item of decisionRules
   * (unchecked, returns invalid data if index overflows)
   */
  function getItem(
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress,
    uint256 _index
  ) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    unchecked {
      bytes memory _blob = StoreSwitch.getFieldSlice(
        _tableId,
        _keyTuple,
        0,
        getValueSchema(),
        _index * 1,
        (_index + 1) * 1
      );
      return (bytes(_blob));
    }
  }

  /**
   * Get an item of decisionRules (using the specified store)
   * (unchecked, returns invalid data if index overflows)
   */
  function getItem(
    IStore _store,
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress,
    uint256 _index
  ) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    unchecked {
      bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 0, getValueSchema(), _index * 1, (_index + 1) * 1);
      return (bytes(_blob));
    }
  }

  /** Push a slice to decisionRules */
  function push(bytes32 srcVoxelTypeId, bytes32 targetVoxelTypeId, address worldAddress, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    StoreSwitch.pushToField(_tableId, _keyTuple, 0, bytes((_slice)), getValueSchema());
  }

  /** Push a slice to decisionRules (using the specified store) */
  function push(
    IStore _store,
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress,
    bytes memory _slice
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    _store.pushToField(_tableId, _keyTuple, 0, bytes((_slice)), getValueSchema());
  }

  /** Pop a slice from decisionRules */
  function pop(bytes32 srcVoxelTypeId, bytes32 targetVoxelTypeId, address worldAddress) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    StoreSwitch.popFromField(_tableId, _keyTuple, 0, 1, getValueSchema());
  }

  /** Pop a slice from decisionRules (using the specified store) */
  function pop(IStore _store, bytes32 srcVoxelTypeId, bytes32 targetVoxelTypeId, address worldAddress) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    _store.popFromField(_tableId, _keyTuple, 0, 1, getValueSchema());
  }

  /**
   * Update a slice of decisionRules at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function update(
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress,
    uint256 _index,
    bytes memory _slice
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    unchecked {
      StoreSwitch.updateInField(_tableId, _keyTuple, 0, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /**
   * Update a slice of decisionRules (using the specified store) at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function update(
    IStore _store,
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress,
    uint256 _index,
    bytes memory _slice
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    unchecked {
      _store.updateInField(_tableId, _keyTuple, 0, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /** Tightly pack full data using this table's schema */
  function encode(bytes memory decisionRules) internal pure returns (bytes memory) {
    PackedCounter _encodedLengths;
    // Lengths are effectively checked during copy by 2**40 bytes exceeding gas limits
    unchecked {
      _encodedLengths = PackedCounterLib.pack(bytes(decisionRules).length);
    }

    return abi.encodePacked(_encodedLengths.unwrap(), bytes((decisionRules)));
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress
  ) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    return _keyTuple;
  }

  /* Delete all data for given keys */
  function deleteRecord(bytes32 srcVoxelTypeId, bytes32 targetVoxelTypeId, address worldAddress) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    StoreSwitch.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(
    IStore _store,
    bytes32 srcVoxelTypeId,
    bytes32 targetVoxelTypeId,
    address worldAddress
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = srcVoxelTypeId;
    _keyTuple[1] = targetVoxelTypeId;
    _keyTuple[2] = bytes32(uint256(uint160(worldAddress)));

    _store.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }
}