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

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("CAMind")));
bytes32 constant CAMindTableId = _tableId;

struct CAMindData {
  bytes32 voxelTypeId;
  bytes4 mindSelector;
}

library CAMind {
  /** Get the table's schema */
  function getSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](2);
    _schema[0] = SchemaType.BYTES32;
    _schema[1] = SchemaType.BYTES4;

    return SchemaLib.encode(_schema);
  }

  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.BYTES32;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's metadata */
  function getMetadata() internal pure returns (string memory, string[] memory) {
    string[] memory _fieldNames = new string[](2);
    _fieldNames[0] = "voxelTypeId";
    _fieldNames[1] = "mindSelector";
    return ("CAMind", _fieldNames);
  }

  /** Register the table's schema */
  function registerSchema() internal {
    StoreSwitch.registerSchema(_tableId, getSchema(), getKeySchema());
  }

  /** Register the table's schema (using the specified store) */
  function registerSchema(IStore _store) internal {
    _store.registerSchema(_tableId, getSchema(), getKeySchema());
  }

  /** Set the table's metadata */
  function setMetadata() internal {
    (string memory _tableName, string[] memory _fieldNames) = getMetadata();
    StoreSwitch.setMetadata(_tableId, _tableName, _fieldNames);
  }

  /** Set the table's metadata (using the specified store) */
  function setMetadata(IStore _store) internal {
    (string memory _tableName, string[] memory _fieldNames) = getMetadata();
    _store.setMetadata(_tableId, _tableName, _fieldNames);
  }

  /** Get voxelTypeId */
  function getVoxelTypeId(bytes32 caEntity) internal view returns (bytes32 voxelTypeId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0);
    return (Bytes.slice32(_blob, 0));
  }

  /** Get voxelTypeId (using the specified store) */
  function getVoxelTypeId(IStore _store, bytes32 caEntity) internal view returns (bytes32 voxelTypeId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0);
    return (Bytes.slice32(_blob, 0));
  }

  /** Set voxelTypeId */
  function setVoxelTypeId(bytes32 caEntity, bytes32 voxelTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((voxelTypeId)));
  }

  /** Set voxelTypeId (using the specified store) */
  function setVoxelTypeId(IStore _store, bytes32 caEntity, bytes32 voxelTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((voxelTypeId)));
  }

  /** Get mindSelector */
  function getMindSelector(bytes32 caEntity) internal view returns (bytes4 mindSelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1);
    return (Bytes.slice4(_blob, 0));
  }

  /** Get mindSelector (using the specified store) */
  function getMindSelector(IStore _store, bytes32 caEntity) internal view returns (bytes4 mindSelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1);
    return (Bytes.slice4(_blob, 0));
  }

  /** Set mindSelector */
  function setMindSelector(bytes32 caEntity, bytes4 mindSelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    StoreSwitch.setField(_tableId, _keyTuple, 1, abi.encodePacked((mindSelector)));
  }

  /** Set mindSelector (using the specified store) */
  function setMindSelector(IStore _store, bytes32 caEntity, bytes4 mindSelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    _store.setField(_tableId, _keyTuple, 1, abi.encodePacked((mindSelector)));
  }

  /** Get the full data */
  function get(bytes32 caEntity) internal view returns (CAMindData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store, bytes32 caEntity) internal view returns (CAMindData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(bytes32 caEntity, bytes32 voxelTypeId, bytes4 mindSelector) internal {
    bytes memory _data = encode(voxelTypeId, mindSelector);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    StoreSwitch.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using individual values (using the specified store) */
  function set(IStore _store, bytes32 caEntity, bytes32 voxelTypeId, bytes4 mindSelector) internal {
    bytes memory _data = encode(voxelTypeId, mindSelector);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    _store.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using the data struct */
  function set(bytes32 caEntity, CAMindData memory _table) internal {
    set(caEntity, _table.voxelTypeId, _table.mindSelector);
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, bytes32 caEntity, CAMindData memory _table) internal {
    set(_store, caEntity, _table.voxelTypeId, _table.mindSelector);
  }

  /** Decode the tightly packed blob using this table's schema */
  function decode(bytes memory _blob) internal pure returns (CAMindData memory _table) {
    _table.voxelTypeId = (Bytes.slice32(_blob, 0));

    _table.mindSelector = (Bytes.slice4(_blob, 32));
  }

  /** Tightly pack full data using this table's schema */
  function encode(bytes32 voxelTypeId, bytes4 mindSelector) internal pure returns (bytes memory) {
    return abi.encodePacked(voxelTypeId, mindSelector);
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(bytes32 caEntity) internal pure returns (bytes32[] memory _keyTuple) {
    _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;
  }

  /* Delete all data for given keys */
  function deleteRecord(bytes32 caEntity) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, bytes32 caEntity) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = caEntity;

    _store.deleteRecord(_tableId, _keyTuple);
  }
}
