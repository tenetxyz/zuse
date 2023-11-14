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

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("ReversePosition")));
bytes32 constant ReversePositionTableId = _tableId;

struct ReversePositionData {
  bytes32 entity;
  bool hasValue;
}

library ReversePosition {
  /** Get the table's key schema */
  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](4);
    _schema[0] = SchemaType.INT32;
    _schema[1] = SchemaType.INT32;
    _schema[2] = SchemaType.INT32;
    _schema[3] = SchemaType.UINT32;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's value schema */
  function getValueSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](2);
    _schema[0] = SchemaType.BYTES32;
    _schema[1] = SchemaType.BOOL;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's key names */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](4);
    keyNames[0] = "x";
    keyNames[1] = "y";
    keyNames[2] = "z";
    keyNames[3] = "scale";
  }

  /** Get the table's field names */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](2);
    fieldNames[0] = "entity";
    fieldNames[1] = "hasValue";
  }

  /** Register the table's key schema, value schema, key names and value names */
  function register() internal {
    StoreSwitch.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Register the table's key schema, value schema, key names and value names (using the specified store) */
  function register(IStore _store) internal {
    _store.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Get entity */
  function getEntity(int32 x, int32 y, int32 z, uint32 scale) internal view returns (bytes32 entity) {
    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (Bytes.slice32(_blob, 0));
  }

  /** Get entity (using the specified store) */
  function getEntity(IStore _store, int32 x, int32 y, int32 z, uint32 scale) internal view returns (bytes32 entity) {
    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (Bytes.slice32(_blob, 0));
  }

  /** Set entity */
  function setEntity(int32 x, int32 y, int32 z, uint32 scale, bytes32 entity) internal {
    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((entity)), getValueSchema());
  }

  /** Set entity (using the specified store) */
  function setEntity(IStore _store, int32 x, int32 y, int32 z, uint32 scale, bytes32 entity) internal {
    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((entity)), getValueSchema());
  }

  /** Get hasValue */
  function getHasValue(int32 x, int32 y, int32 z, uint32 scale) internal view returns (bool hasValue) {
    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1, getValueSchema());
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Get hasValue (using the specified store) */
  function getHasValue(IStore _store, int32 x, int32 y, int32 z, uint32 scale) internal view returns (bool hasValue) {
    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1, getValueSchema());
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Set hasValue */
  function setHasValue(int32 x, int32 y, int32 z, uint32 scale, bool hasValue) internal {
    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    StoreSwitch.setField(_tableId, _keyTuple, 1, abi.encodePacked((hasValue)), getValueSchema());
  }

  /** Set hasValue (using the specified store) */
  function setHasValue(IStore _store, int32 x, int32 y, int32 z, uint32 scale, bool hasValue) internal {
    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    _store.setField(_tableId, _keyTuple, 1, abi.encodePacked((hasValue)), getValueSchema());
  }

  /** Get the full data */
  function get(int32 x, int32 y, int32 z, uint32 scale) internal view returns (ReversePositionData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(
    IStore _store,
    int32 x,
    int32 y,
    int32 z,
    uint32 scale
  ) internal view returns (ReversePositionData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(int32 x, int32 y, int32 z, uint32 scale, bytes32 entity, bool hasValue) internal {
    bytes memory _data = encode(entity, hasValue);

    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    StoreSwitch.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using individual values (using the specified store) */
  function set(IStore _store, int32 x, int32 y, int32 z, uint32 scale, bytes32 entity, bool hasValue) internal {
    bytes memory _data = encode(entity, hasValue);

    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    _store.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using the data struct */
  function set(int32 x, int32 y, int32 z, uint32 scale, ReversePositionData memory _table) internal {
    set(x, y, z, scale, _table.entity, _table.hasValue);
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, int32 x, int32 y, int32 z, uint32 scale, ReversePositionData memory _table) internal {
    set(_store, x, y, z, scale, _table.entity, _table.hasValue);
  }

  /** Decode the tightly packed blob using this table's schema */
  function decode(bytes memory _blob) internal pure returns (ReversePositionData memory _table) {
    _table.entity = (Bytes.slice32(_blob, 0));

    _table.hasValue = (_toBool(uint8(Bytes.slice1(_blob, 32))));
  }

  /** Tightly pack full data using this table's schema */
  function encode(bytes32 entity, bool hasValue) internal pure returns (bytes memory) {
    return abi.encodePacked(entity, hasValue);
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(int32 x, int32 y, int32 z, uint32 scale) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    return _keyTuple;
  }

  /* Delete all data for given keys */
  function deleteRecord(int32 x, int32 y, int32 z, uint32 scale) internal {
    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    StoreSwitch.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, int32 x, int32 y, int32 z, uint32 scale) internal {
    bytes32[] memory _keyTuple = new bytes32[](4);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));
    _keyTuple[3] = bytes32(uint256(scale));

    _store.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }
}

function _toBool(uint8 value) pure returns (bool result) {
  assembly {
    result := value
  }
}
