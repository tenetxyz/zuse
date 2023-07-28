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

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("ElectronTunnelSp")));
bytes32 constant ElectronTunnelSpotTableId = _tableId;

struct ElectronTunnelSpotData {
  bool atTop;
  bytes32 sibling;
}

library ElectronTunnelSpot {
  /** Get the table's schema */
  function getSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](2);
    _schema[0] = SchemaType.BOOL;
    _schema[1] = SchemaType.BYTES32;

    return SchemaLib.encode(_schema);
  }

  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](2);
    _schema[0] = SchemaType.ADDRESS;
    _schema[1] = SchemaType.BYTES32;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's metadata */
  function getMetadata() internal pure returns (string memory, string[] memory) {
    string[] memory _fieldNames = new string[](2);
    _fieldNames[0] = "atTop";
    _fieldNames[1] = "sibling";
    return ("ElectronTunnelSpot", _fieldNames);
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

  /** Get atTop */
  function getAtTop(address callerAddress, bytes32 entity) internal view returns (bool atTop) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0);
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Get atTop (using the specified store) */
  function getAtTop(IStore _store, address callerAddress, bytes32 entity) internal view returns (bool atTop) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0);
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Set atTop */
  function setAtTop(address callerAddress, bytes32 entity, bool atTop) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((atTop)));
  }

  /** Set atTop (using the specified store) */
  function setAtTop(IStore _store, address callerAddress, bytes32 entity, bool atTop) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((atTop)));
  }

  /** Get sibling */
  function getSibling(address callerAddress, bytes32 entity) internal view returns (bytes32 sibling) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1);
    return (Bytes.slice32(_blob, 0));
  }

  /** Get sibling (using the specified store) */
  function getSibling(IStore _store, address callerAddress, bytes32 entity) internal view returns (bytes32 sibling) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1);
    return (Bytes.slice32(_blob, 0));
  }

  /** Set sibling */
  function setSibling(address callerAddress, bytes32 entity, bytes32 sibling) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    StoreSwitch.setField(_tableId, _keyTuple, 1, abi.encodePacked((sibling)));
  }

  /** Set sibling (using the specified store) */
  function setSibling(IStore _store, address callerAddress, bytes32 entity, bytes32 sibling) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    _store.setField(_tableId, _keyTuple, 1, abi.encodePacked((sibling)));
  }

  /** Get the full data */
  function get(address callerAddress, bytes32 entity) internal view returns (ElectronTunnelSpotData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(
    IStore _store,
    address callerAddress,
    bytes32 entity
  ) internal view returns (ElectronTunnelSpotData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(address callerAddress, bytes32 entity, bool atTop, bytes32 sibling) internal {
    bytes memory _data = encode(atTop, sibling);

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    StoreSwitch.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using individual values (using the specified store) */
  function set(IStore _store, address callerAddress, bytes32 entity, bool atTop, bytes32 sibling) internal {
    bytes memory _data = encode(atTop, sibling);

    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    _store.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using the data struct */
  function set(address callerAddress, bytes32 entity, ElectronTunnelSpotData memory _table) internal {
    set(callerAddress, entity, _table.atTop, _table.sibling);
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, address callerAddress, bytes32 entity, ElectronTunnelSpotData memory _table) internal {
    set(_store, callerAddress, entity, _table.atTop, _table.sibling);
  }

  /** Decode the tightly packed blob using this table's schema */
  function decode(bytes memory _blob) internal pure returns (ElectronTunnelSpotData memory _table) {
    _table.atTop = (_toBool(uint8(Bytes.slice1(_blob, 0))));

    _table.sibling = (Bytes.slice32(_blob, 1));
  }

  /** Tightly pack full data using this table's schema */
  function encode(bool atTop, bytes32 sibling) internal pure returns (bytes memory) {
    return abi.encodePacked(atTop, sibling);
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(address callerAddress, bytes32 entity) internal pure returns (bytes32[] memory _keyTuple) {
    _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;
  }

  /* Delete all data for given keys */
  function deleteRecord(address callerAddress, bytes32 entity) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, address callerAddress, bytes32 entity) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = bytes32(uint256(uint160(callerAddress)));
    _keyTuple[1] = entity;

    _store.deleteRecord(_tableId, _keyTuple);
  }
}

function _toBool(uint8 value) pure returns (bool result) {
  assembly {
    result := value
  }
}
