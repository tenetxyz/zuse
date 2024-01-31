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

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("Inventory")));
bytes32 constant InventoryTableId = _tableId;

library Inventory {
  /** Get the table's key schema */
  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.BYTES32;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's value schema */
  function getValueSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.BYTES32;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's key names */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](1);
    keyNames[0] = "inventoryId";
  }

  /** Get the table's field names */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](1);
    fieldNames[0] = "agentObjectEntityId";
  }

  /** Register the table's key schema, value schema, key names and value names */
  function register() internal {
    StoreSwitch.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Register the table's key schema, value schema, key names and value names (using the specified store) */
  function register(IStore _store) internal {
    _store.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Get agentObjectEntityId */
  function get(bytes32 inventoryId) internal view returns (bytes32 agentObjectEntityId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (Bytes.slice32(_blob, 0));
  }

  /** Get agentObjectEntityId (using the specified store) */
  function get(IStore _store, bytes32 inventoryId) internal view returns (bytes32 agentObjectEntityId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (Bytes.slice32(_blob, 0));
  }

  /** Set agentObjectEntityId */
  function set(bytes32 inventoryId, bytes32 agentObjectEntityId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((agentObjectEntityId)), getValueSchema());
  }

  /** Set agentObjectEntityId (using the specified store) */
  function set(IStore _store, bytes32 inventoryId, bytes32 agentObjectEntityId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = inventoryId;

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((agentObjectEntityId)), getValueSchema());
  }

  /** Tightly pack full data using this table's schema */
  function encode(bytes32 agentObjectEntityId) internal pure returns (bytes memory) {
    return abi.encodePacked(agentObjectEntityId);
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
