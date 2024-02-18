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

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("InventoryObject")));
bytes32 constant InventoryObjectTableId = _tableId;

struct InventoryObjectData {
  bytes32 objectTypeId;
  uint8 numObjects;
  uint16 numUsesLeft;
  bytes objectProperties;
}

library InventoryObject {
  /** Get the table's key schema */
  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.BYTES32;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's value schema */
  function getValueSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](4);
    _schema[0] = SchemaType.BYTES32;
    _schema[1] = SchemaType.UINT8;
    _schema[2] = SchemaType.UINT16;
    _schema[3] = SchemaType.BYTES;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's key names */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](1);
    keyNames[0] = "inventoryId";
  }

  /** Get the table's field names */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](4);
    fieldNames[0] = "objectTypeId";
    fieldNames[1] = "numObjects";
    fieldNames[2] = "numUsesLeft";
    fieldNames[3] = "objectProperties";
  }

  /** Register the table's key schema, value schema, key names and value names */
  function register() internal {
    StoreSwitch.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Register the table's key schema, value schema, key names and value names (using the specified store) */
  function register(IStore _store) internal {
    _store.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Get objectTypeId */
  function getObjectTypeId(bytes32 inventoryId) internal view returns (bytes32 objectTypeId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (Bytes.slice32(_blob, 0));
  }

  /** Get objectTypeId (using the specified store) */
  function getObjectTypeId(IStore _store, bytes32 inventoryId) internal view returns (bytes32 objectTypeId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (Bytes.slice32(_blob, 0));
  }

  /** Set objectTypeId */
  function setObjectTypeId(bytes32 inventoryId, bytes32 objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((objectTypeId)), getValueSchema());
  }

  /** Set objectTypeId (using the specified store) */
  function setObjectTypeId(IStore _store, bytes32 inventoryId, bytes32 objectTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((objectTypeId)), getValueSchema());
  }

  /** Get numObjects */
  function getNumObjects(bytes32 inventoryId) internal view returns (uint8 numObjects) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1, getValueSchema());
    return (uint8(Bytes.slice1(_blob, 0)));
  }

  /** Get numObjects (using the specified store) */
  function getNumObjects(IStore _store, bytes32 inventoryId) internal view returns (uint8 numObjects) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1, getValueSchema());
    return (uint8(Bytes.slice1(_blob, 0)));
  }

  /** Set numObjects */
  function setNumObjects(bytes32 inventoryId, uint8 numObjects) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    StoreSwitch.setField(_tableId, _keyTuple, 1, abi.encodePacked((numObjects)), getValueSchema());
  }

  /** Set numObjects (using the specified store) */
  function setNumObjects(IStore _store, bytes32 inventoryId, uint8 numObjects) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    _store.setField(_tableId, _keyTuple, 1, abi.encodePacked((numObjects)), getValueSchema());
  }

  /** Get numUsesLeft */
  function getNumUsesLeft(bytes32 inventoryId) internal view returns (uint16 numUsesLeft) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 2, getValueSchema());
    return (uint16(Bytes.slice2(_blob, 0)));
  }

  /** Get numUsesLeft (using the specified store) */
  function getNumUsesLeft(IStore _store, bytes32 inventoryId) internal view returns (uint16 numUsesLeft) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 2, getValueSchema());
    return (uint16(Bytes.slice2(_blob, 0)));
  }

  /** Set numUsesLeft */
  function setNumUsesLeft(bytes32 inventoryId, uint16 numUsesLeft) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    StoreSwitch.setField(_tableId, _keyTuple, 2, abi.encodePacked((numUsesLeft)), getValueSchema());
  }

  /** Set numUsesLeft (using the specified store) */
  function setNumUsesLeft(IStore _store, bytes32 inventoryId, uint16 numUsesLeft) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    _store.setField(_tableId, _keyTuple, 2, abi.encodePacked((numUsesLeft)), getValueSchema());
  }

  /** Get objectProperties */
  function getObjectProperties(bytes32 inventoryId) internal view returns (bytes memory objectProperties) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 3, getValueSchema());
    return (bytes(_blob));
  }

  /** Get objectProperties (using the specified store) */
  function getObjectProperties(
    IStore _store,
    bytes32 inventoryId
  ) internal view returns (bytes memory objectProperties) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 3, getValueSchema());
    return (bytes(_blob));
  }

  /** Set objectProperties */
  function setObjectProperties(bytes32 inventoryId, bytes memory objectProperties) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    StoreSwitch.setField(_tableId, _keyTuple, 3, bytes((objectProperties)), getValueSchema());
  }

  /** Set objectProperties (using the specified store) */
  function setObjectProperties(IStore _store, bytes32 inventoryId, bytes memory objectProperties) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    _store.setField(_tableId, _keyTuple, 3, bytes((objectProperties)), getValueSchema());
  }

  /** Get the length of objectProperties */
  function lengthObjectProperties(bytes32 inventoryId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 3, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /** Get the length of objectProperties (using the specified store) */
  function lengthObjectProperties(IStore _store, bytes32 inventoryId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 3, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * Get an item of objectProperties
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemObjectProperties(bytes32 inventoryId, uint256 _index) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    unchecked {
      bytes memory _blob = StoreSwitch.getFieldSlice(
        _tableId,
        _keyTuple,
        3,
        getValueSchema(),
        _index * 1,
        (_index + 1) * 1
      );
      return (bytes(_blob));
    }
  }

  /**
   * Get an item of objectProperties (using the specified store)
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemObjectProperties(
    IStore _store,
    bytes32 inventoryId,
    uint256 _index
  ) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    unchecked {
      bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 3, getValueSchema(), _index * 1, (_index + 1) * 1);
      return (bytes(_blob));
    }
  }

  /** Push a slice to objectProperties */
  function pushObjectProperties(bytes32 inventoryId, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 3, bytes((_slice)), getValueSchema());
  }

  /** Push a slice to objectProperties (using the specified store) */
  function pushObjectProperties(IStore _store, bytes32 inventoryId, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    _store.pushToField(_tableId, _keyTuple, 3, bytes((_slice)), getValueSchema());
  }

  /** Pop a slice from objectProperties */
  function popObjectProperties(bytes32 inventoryId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 3, 1, getValueSchema());
  }

  /** Pop a slice from objectProperties (using the specified store) */
  function popObjectProperties(IStore _store, bytes32 inventoryId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    _store.popFromField(_tableId, _keyTuple, 3, 1, getValueSchema());
  }

  /**
   * Update a slice of objectProperties at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateObjectProperties(bytes32 inventoryId, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    unchecked {
      StoreSwitch.updateInField(_tableId, _keyTuple, 3, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /**
   * Update a slice of objectProperties (using the specified store) at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateObjectProperties(IStore _store, bytes32 inventoryId, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    unchecked {
      _store.updateInField(_tableId, _keyTuple, 3, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /** Get the full data */
  function get(bytes32 inventoryId) internal view returns (InventoryObjectData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store, bytes32 inventoryId) internal view returns (InventoryObjectData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(
    bytes32 inventoryId,
    bytes32 objectTypeId,
    uint8 numObjects,
    uint16 numUsesLeft,
    bytes memory objectProperties
  ) internal {
    bytes memory _data = encode(objectTypeId, numObjects, numUsesLeft, objectProperties);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    StoreSwitch.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using individual values (using the specified store) */
  function set(
    IStore _store,
    bytes32 inventoryId,
    bytes32 objectTypeId,
    uint8 numObjects,
    uint16 numUsesLeft,
    bytes memory objectProperties
  ) internal {
    bytes memory _data = encode(objectTypeId, numObjects, numUsesLeft, objectProperties);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    _store.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using the data struct */
  function set(bytes32 inventoryId, InventoryObjectData memory _table) internal {
    set(inventoryId, _table.objectTypeId, _table.numObjects, _table.numUsesLeft, _table.objectProperties);
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, bytes32 inventoryId, InventoryObjectData memory _table) internal {
    set(_store, inventoryId, _table.objectTypeId, _table.numObjects, _table.numUsesLeft, _table.objectProperties);
  }

  /**
   * Decode the tightly packed blob using this table's schema.
   * Undefined behaviour for invalid blobs.
   */
  function decode(bytes memory _blob) internal pure returns (InventoryObjectData memory _table) {
    // 35 is the total byte length of static data
    PackedCounter _encodedLengths = PackedCounter.wrap(Bytes.slice32(_blob, 35));

    _table.objectTypeId = (Bytes.slice32(_blob, 0));

    _table.numObjects = (uint8(Bytes.slice1(_blob, 32)));

    _table.numUsesLeft = (uint16(Bytes.slice2(_blob, 33)));

    // Store trims the blob if dynamic fields are all empty
    if (_blob.length > 35) {
      // skip static data length + dynamic lengths word
      uint256 _start = 67;
      uint256 _end;
      unchecked {
        _end = 67 + _encodedLengths.atIndex(0);
      }
      _table.objectProperties = (bytes(SliceLib.getSubslice(_blob, _start, _end).toBytes()));
    }
  }

  /** Tightly pack full data using this table's schema */
  function encode(
    bytes32 objectTypeId,
    uint8 numObjects,
    uint16 numUsesLeft,
    bytes memory objectProperties
  ) internal pure returns (bytes memory) {
    PackedCounter _encodedLengths;
    // Lengths are effectively checked during copy by 2**40 bytes exceeding gas limits
    unchecked {
      _encodedLengths = PackedCounterLib.pack(bytes(objectProperties).length);
    }

    return abi.encodePacked(objectTypeId, numObjects, numUsesLeft, _encodedLengths.unwrap(), bytes((objectProperties)));
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(bytes32 inventoryId) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    return _keyTuple;
  }

  /* Delete all data for given keys */
  function deleteRecord(bytes32 inventoryId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    StoreSwitch.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, bytes32 inventoryId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    _store.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }
}
