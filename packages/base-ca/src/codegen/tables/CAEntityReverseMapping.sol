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

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("CAEntityReverseM")));
bytes32 constant CAEntityReverseMappingTableId = _tableId;

struct CAEntityReverseMappingData {
  address callerAddress;
  bytes32 entity;
  bool hasValue;
}

library CAEntityReverseMapping {
  /** Get the table's key schema */
  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.BYTES32;

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
    keyNames = new string[](1);
    keyNames[0] = "caEntity";
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
  function getCallerAddress(bytes32 caEntity) internal view returns (address callerAddress) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (address(Bytes.slice20(_blob, 0)));
  }

  /** Get callerAddress (using the specified store) */
  function getCallerAddress(IStore _store, bytes32 caEntity) internal view returns (address callerAddress) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (address(Bytes.slice20(_blob, 0)));
  }

  /** Set callerAddress */
  function setCallerAddress(bytes32 caEntity, address callerAddress) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((callerAddress)), getValueSchema());
  }

  /** Set callerAddress (using the specified store) */
  function setCallerAddress(IStore _store, bytes32 caEntity, address callerAddress) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((callerAddress)), getValueSchema());
  }

  /** Get entity */
  function getEntity(bytes32 caEntity) internal view returns (bytes32 entity) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1, getValueSchema());
    return (Bytes.slice32(_blob, 0));
  }

  /** Get entity (using the specified store) */
  function getEntity(IStore _store, bytes32 caEntity) internal view returns (bytes32 entity) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1, getValueSchema());
    return (Bytes.slice32(_blob, 0));
  }

  /** Set entity */
  function setEntity(bytes32 caEntity, bytes32 entity) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    StoreSwitch.setField(_tableId, _keyTuple, 1, abi.encodePacked((entity)), getValueSchema());
  }

  /** Set entity (using the specified store) */
  function setEntity(IStore _store, bytes32 caEntity, bytes32 entity) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    _store.setField(_tableId, _keyTuple, 1, abi.encodePacked((entity)), getValueSchema());
  }

  /** Get hasValue */
  function getHasValue(bytes32 caEntity) internal view returns (bool hasValue) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 2, getValueSchema());
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Get hasValue (using the specified store) */
  function getHasValue(IStore _store, bytes32 caEntity) internal view returns (bool hasValue) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 2, getValueSchema());
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Set hasValue */
  function setHasValue(bytes32 caEntity, bool hasValue) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    StoreSwitch.setField(_tableId, _keyTuple, 2, abi.encodePacked((hasValue)), getValueSchema());
  }

  /** Set hasValue (using the specified store) */
  function setHasValue(IStore _store, bytes32 caEntity, bool hasValue) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    _store.setField(_tableId, _keyTuple, 2, abi.encodePacked((hasValue)), getValueSchema());
  }

  /** Get the full data */
  function get(bytes32 caEntity) internal view returns (CAEntityReverseMappingData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store, bytes32 caEntity) internal view returns (CAEntityReverseMappingData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(bytes32 caEntity, address callerAddress, bytes32 entity, bool hasValue) internal {
    bytes memory _data = encode(callerAddress, entity, hasValue);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    StoreSwitch.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using individual values (using the specified store) */
  function set(IStore _store, bytes32 caEntity, address callerAddress, bytes32 entity, bool hasValue) internal {
    bytes memory _data = encode(callerAddress, entity, hasValue);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    _store.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using the data struct */
  function set(bytes32 caEntity, CAEntityReverseMappingData memory _table) internal {
    set(caEntity, _table.callerAddress, _table.entity, _table.hasValue);
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, bytes32 caEntity, CAEntityReverseMappingData memory _table) internal {
    set(_store, caEntity, _table.callerAddress, _table.entity, _table.hasValue);
  }

  /** Decode the tightly packed blob using this table's schema */
  function decode(bytes memory _blob) internal pure returns (CAEntityReverseMappingData memory _table) {
    _table.callerAddress = (address(Bytes.slice20(_blob, 0)));

    _table.entity = (Bytes.slice32(_blob, 20));

    _table.hasValue = (_toBool(uint8(Bytes.slice1(_blob, 52))));
  }

  /** Tightly pack full data using this table's schema */
  function encode(address callerAddress, bytes32 entity, bool hasValue) internal pure returns (bytes memory) {
    return abi.encodePacked(callerAddress, entity, hasValue);
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(bytes32 caEntity) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    return _keyTuple;
  }

  /* Delete all data for given keys */
  function deleteRecord(bytes32 caEntity) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    StoreSwitch.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, bytes32 caEntity) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    _store.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }
}

function _toBool(uint8 value) pure returns (bool result) {
  assembly {
    result := value
  }
}
