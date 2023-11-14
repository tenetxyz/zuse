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

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("CAReversePositio")));
bytes32 constant CAReversePositionTableId = _tableId;

struct CAReversePositionData {
  address callerAddress;
  bytes32 entity;
  bool hasValue;
}

library CAReversePosition {
  /** Get the table's key schema */
  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](3);
    _schema[0] = SchemaType.INT32;
    _schema[1] = SchemaType.INT32;
    _schema[2] = SchemaType.INT32;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's value schema */
  function getValueSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](3);
    _schema[0] = SchemaType.ADDRESS;
    _schema[1] = SchemaType.BYTES32;
    _schema[2] = SchemaType.BOOL;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's key names */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](3);
    keyNames[0] = "x";
    keyNames[1] = "y";
    keyNames[2] = "z";
  }

  /** Get the table's field names */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](3);
    fieldNames[0] = "callerAddress";
    fieldNames[1] = "entity";
    fieldNames[2] = "hasValue";
  }

  /** Register the table's key schema, value schema, key names and value names */
  function register() internal {
    StoreSwitch.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Register the table's key schema, value schema, key names and value names (using the specified store) */
  function register(IStore _store) internal {
    _store.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Get callerAddress */
  function getCallerAddress(int32 x, int32 y, int32 z) internal view returns (address callerAddress) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (address(Bytes.slice20(_blob, 0)));
  }

  /** Get callerAddress (using the specified store) */
  function getCallerAddress(IStore _store, int32 x, int32 y, int32 z) internal view returns (address callerAddress) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (address(Bytes.slice20(_blob, 0)));
  }

  /** Set callerAddress */
  function setCallerAddress(int32 x, int32 y, int32 z, address callerAddress) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((callerAddress)), getValueSchema());
  }

  /** Set callerAddress (using the specified store) */
  function setCallerAddress(IStore _store, int32 x, int32 y, int32 z, address callerAddress) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((callerAddress)), getValueSchema());
  }

  /** Get entity */
  function getEntity(int32 x, int32 y, int32 z) internal view returns (bytes32 entity) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1, getValueSchema());
    return (Bytes.slice32(_blob, 0));
  }

  /** Get entity (using the specified store) */
  function getEntity(IStore _store, int32 x, int32 y, int32 z) internal view returns (bytes32 entity) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1, getValueSchema());
    return (Bytes.slice32(_blob, 0));
  }

  /** Set entity */
  function setEntity(int32 x, int32 y, int32 z, bytes32 entity) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    StoreSwitch.setField(_tableId, _keyTuple, 1, abi.encodePacked((entity)), getValueSchema());
  }

  /** Set entity (using the specified store) */
  function setEntity(IStore _store, int32 x, int32 y, int32 z, bytes32 entity) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    _store.setField(_tableId, _keyTuple, 1, abi.encodePacked((entity)), getValueSchema());
  }

  /** Get hasValue */
  function getHasValue(int32 x, int32 y, int32 z) internal view returns (bool hasValue) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 2, getValueSchema());
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Get hasValue (using the specified store) */
  function getHasValue(IStore _store, int32 x, int32 y, int32 z) internal view returns (bool hasValue) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 2, getValueSchema());
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Set hasValue */
  function setHasValue(int32 x, int32 y, int32 z, bool hasValue) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    StoreSwitch.setField(_tableId, _keyTuple, 2, abi.encodePacked((hasValue)), getValueSchema());
  }

  /** Set hasValue (using the specified store) */
  function setHasValue(IStore _store, int32 x, int32 y, int32 z, bool hasValue) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    _store.setField(_tableId, _keyTuple, 2, abi.encodePacked((hasValue)), getValueSchema());
  }

  /** Get the full data */
  function get(int32 x, int32 y, int32 z) internal view returns (CAReversePositionData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store, int32 x, int32 y, int32 z) internal view returns (CAReversePositionData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(int32 x, int32 y, int32 z, address callerAddress, bytes32 entity, bool hasValue) internal {
    bytes memory _data = encode(callerAddress, entity, hasValue);

    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    StoreSwitch.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using individual values (using the specified store) */
  function set(
    IStore _store,
    int32 x,
    int32 y,
    int32 z,
    address callerAddress,
    bytes32 entity,
    bool hasValue
  ) internal {
    bytes memory _data = encode(callerAddress, entity, hasValue);

    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    _store.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using the data struct */
  function set(int32 x, int32 y, int32 z, CAReversePositionData memory _table) internal {
    set(x, y, z, _table.callerAddress, _table.entity, _table.hasValue);
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, int32 x, int32 y, int32 z, CAReversePositionData memory _table) internal {
    set(_store, x, y, z, _table.callerAddress, _table.entity, _table.hasValue);
  }

  /** Decode the tightly packed blob using this table's schema */
  function decode(bytes memory _blob) internal pure returns (CAReversePositionData memory _table) {
    _table.callerAddress = (address(Bytes.slice20(_blob, 0)));

    _table.entity = (Bytes.slice32(_blob, 20));

    _table.hasValue = (_toBool(uint8(Bytes.slice1(_blob, 52))));
  }

  /** Tightly pack full data using this table's schema */
  function encode(address callerAddress, bytes32 entity, bool hasValue) internal pure returns (bytes memory) {
    return abi.encodePacked(callerAddress, entity, hasValue);
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(int32 x, int32 y, int32 z) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    return _keyTuple;
  }

  /* Delete all data for given keys */
  function deleteRecord(int32 x, int32 y, int32 z) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    StoreSwitch.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, int32 x, int32 y, int32 z) internal {
    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(int256(x)));
    _keyTuple[1] = bytes32(uint256(int256(y)));
    _keyTuple[2] = bytes32(uint256(int256(z)));

    _store.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }
}

function _toBool(uint8 value) pure returns (bool result) {
  assembly {
    result := value
  }
}
