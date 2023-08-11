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

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("ClassifierRegist")));
bytes32 constant ClassifierRegistryTableId = _tableId;

struct ClassifierRegistryData {
  address creator;
  bytes4 classifySelector;
  string name;
  string description;
  bytes selectorInterface;
  string classificationResultTableName;
}

library ClassifierRegistry {
  /** Get the table's schema */
  function getSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](6);
    _schema[0] = SchemaType.ADDRESS;
    _schema[1] = SchemaType.BYTES4;
    _schema[2] = SchemaType.STRING;
    _schema[3] = SchemaType.STRING;
    _schema[4] = SchemaType.BYTES;
    _schema[5] = SchemaType.STRING;

    return SchemaLib.encode(_schema);
  }

  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.BYTES32;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's metadata */
  function getMetadata() internal pure returns (string memory, string[] memory) {
    string[] memory _fieldNames = new string[](6);
    _fieldNames[0] = "creator";
    _fieldNames[1] = "classifySelector";
    _fieldNames[2] = "name";
    _fieldNames[3] = "description";
    _fieldNames[4] = "selectorInterface";
    _fieldNames[5] = "classificationResultTableName";
    return ("ClassifierRegistry", _fieldNames);
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

  /** Get creator */
  function getCreator(bytes32 classifierId) internal view returns (address creator) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0);
    return (address(Bytes.slice20(_blob, 0)));
  }

  /** Get creator (using the specified store) */
  function getCreator(IStore _store, bytes32 classifierId) internal view returns (address creator) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0);
    return (address(Bytes.slice20(_blob, 0)));
  }

  /** Set creator */
  function setCreator(bytes32 classifierId, address creator) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((creator)));
  }

  /** Set creator (using the specified store) */
  function setCreator(IStore _store, bytes32 classifierId, address creator) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((creator)));
  }

  /** Get classifySelector */
  function getClassifySelector(bytes32 classifierId) internal view returns (bytes4 classifySelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1);
    return (Bytes.slice4(_blob, 0));
  }

  /** Get classifySelector (using the specified store) */
  function getClassifySelector(IStore _store, bytes32 classifierId) internal view returns (bytes4 classifySelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1);
    return (Bytes.slice4(_blob, 0));
  }

  /** Set classifySelector */
  function setClassifySelector(bytes32 classifierId, bytes4 classifySelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.setField(_tableId, _keyTuple, 1, abi.encodePacked((classifySelector)));
  }

  /** Set classifySelector (using the specified store) */
  function setClassifySelector(IStore _store, bytes32 classifierId, bytes4 classifySelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.setField(_tableId, _keyTuple, 1, abi.encodePacked((classifySelector)));
  }

  /** Get name */
  function getName(bytes32 classifierId) internal view returns (string memory name) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 2);
    return (string(_blob));
  }

  /** Get name (using the specified store) */
  function getName(IStore _store, bytes32 classifierId) internal view returns (string memory name) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 2);
    return (string(_blob));
  }

  /** Set name */
  function setName(bytes32 classifierId, string memory name) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.setField(_tableId, _keyTuple, 2, bytes((name)));
  }

  /** Set name (using the specified store) */
  function setName(IStore _store, bytes32 classifierId, string memory name) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.setField(_tableId, _keyTuple, 2, bytes((name)));
  }

  /** Get the length of name */
  function lengthName(bytes32 classifierId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 2, getSchema());
    return _byteLength / 1;
  }

  /** Get the length of name (using the specified store) */
  function lengthName(IStore _store, bytes32 classifierId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 2, getSchema());
    return _byteLength / 1;
  }

  /** Get an item of name (unchecked, returns invalid data if index overflows) */
  function getItemName(bytes32 classifierId, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = StoreSwitch.getFieldSlice(_tableId, _keyTuple, 2, getSchema(), _index * 1, (_index + 1) * 1);
    return (string(_blob));
  }

  /** Get an item of name (using the specified store) (unchecked, returns invalid data if index overflows) */
  function getItemName(IStore _store, bytes32 classifierId, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 2, getSchema(), _index * 1, (_index + 1) * 1);
    return (string(_blob));
  }

  /** Push a slice to name */
  function pushName(bytes32 classifierId, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 2, bytes((_slice)));
  }

  /** Push a slice to name (using the specified store) */
  function pushName(IStore _store, bytes32 classifierId, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.pushToField(_tableId, _keyTuple, 2, bytes((_slice)));
  }

  /** Pop a slice from name */
  function popName(bytes32 classifierId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 2, 1);
  }

  /** Pop a slice from name (using the specified store) */
  function popName(IStore _store, bytes32 classifierId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.popFromField(_tableId, _keyTuple, 2, 1);
  }

  /** Update a slice of name at `_index` */
  function updateName(bytes32 classifierId, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.updateInField(_tableId, _keyTuple, 2, _index * 1, bytes((_slice)));
  }

  /** Update a slice of name (using the specified store) at `_index` */
  function updateName(IStore _store, bytes32 classifierId, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.updateInField(_tableId, _keyTuple, 2, _index * 1, bytes((_slice)));
  }

  /** Get description */
  function getDescription(bytes32 classifierId) internal view returns (string memory description) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 3);
    return (string(_blob));
  }

  /** Get description (using the specified store) */
  function getDescription(IStore _store, bytes32 classifierId) internal view returns (string memory description) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 3);
    return (string(_blob));
  }

  /** Set description */
  function setDescription(bytes32 classifierId, string memory description) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.setField(_tableId, _keyTuple, 3, bytes((description)));
  }

  /** Set description (using the specified store) */
  function setDescription(IStore _store, bytes32 classifierId, string memory description) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.setField(_tableId, _keyTuple, 3, bytes((description)));
  }

  /** Get the length of description */
  function lengthDescription(bytes32 classifierId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 3, getSchema());
    return _byteLength / 1;
  }

  /** Get the length of description (using the specified store) */
  function lengthDescription(IStore _store, bytes32 classifierId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 3, getSchema());
    return _byteLength / 1;
  }

  /** Get an item of description (unchecked, returns invalid data if index overflows) */
  function getItemDescription(bytes32 classifierId, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = StoreSwitch.getFieldSlice(_tableId, _keyTuple, 3, getSchema(), _index * 1, (_index + 1) * 1);
    return (string(_blob));
  }

  /** Get an item of description (using the specified store) (unchecked, returns invalid data if index overflows) */
  function getItemDescription(
    IStore _store,
    bytes32 classifierId,
    uint256 _index
  ) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 3, getSchema(), _index * 1, (_index + 1) * 1);
    return (string(_blob));
  }

  /** Push a slice to description */
  function pushDescription(bytes32 classifierId, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 3, bytes((_slice)));
  }

  /** Push a slice to description (using the specified store) */
  function pushDescription(IStore _store, bytes32 classifierId, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.pushToField(_tableId, _keyTuple, 3, bytes((_slice)));
  }

  /** Pop a slice from description */
  function popDescription(bytes32 classifierId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 3, 1);
  }

  /** Pop a slice from description (using the specified store) */
  function popDescription(IStore _store, bytes32 classifierId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.popFromField(_tableId, _keyTuple, 3, 1);
  }

  /** Update a slice of description at `_index` */
  function updateDescription(bytes32 classifierId, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.updateInField(_tableId, _keyTuple, 3, _index * 1, bytes((_slice)));
  }

  /** Update a slice of description (using the specified store) at `_index` */
  function updateDescription(IStore _store, bytes32 classifierId, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.updateInField(_tableId, _keyTuple, 3, _index * 1, bytes((_slice)));
  }

  /** Get selectorInterface */
  function getSelectorInterface(bytes32 classifierId) internal view returns (bytes memory selectorInterface) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 4);
    return (bytes(_blob));
  }

  /** Get selectorInterface (using the specified store) */
  function getSelectorInterface(
    IStore _store,
    bytes32 classifierId
  ) internal view returns (bytes memory selectorInterface) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 4);
    return (bytes(_blob));
  }

  /** Set selectorInterface */
  function setSelectorInterface(bytes32 classifierId, bytes memory selectorInterface) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.setField(_tableId, _keyTuple, 4, bytes((selectorInterface)));
  }

  /** Set selectorInterface (using the specified store) */
  function setSelectorInterface(IStore _store, bytes32 classifierId, bytes memory selectorInterface) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.setField(_tableId, _keyTuple, 4, bytes((selectorInterface)));
  }

  /** Get the length of selectorInterface */
  function lengthSelectorInterface(bytes32 classifierId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 4, getSchema());
    return _byteLength / 1;
  }

  /** Get the length of selectorInterface (using the specified store) */
  function lengthSelectorInterface(IStore _store, bytes32 classifierId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 4, getSchema());
    return _byteLength / 1;
  }

  /** Get an item of selectorInterface (unchecked, returns invalid data if index overflows) */
  function getItemSelectorInterface(bytes32 classifierId, uint256 _index) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = StoreSwitch.getFieldSlice(_tableId, _keyTuple, 4, getSchema(), _index * 1, (_index + 1) * 1);
    return (bytes(_blob));
  }

  /** Get an item of selectorInterface (using the specified store) (unchecked, returns invalid data if index overflows) */
  function getItemSelectorInterface(
    IStore _store,
    bytes32 classifierId,
    uint256 _index
  ) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 4, getSchema(), _index * 1, (_index + 1) * 1);
    return (bytes(_blob));
  }

  /** Push a slice to selectorInterface */
  function pushSelectorInterface(bytes32 classifierId, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 4, bytes((_slice)));
  }

  /** Push a slice to selectorInterface (using the specified store) */
  function pushSelectorInterface(IStore _store, bytes32 classifierId, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.pushToField(_tableId, _keyTuple, 4, bytes((_slice)));
  }

  /** Pop a slice from selectorInterface */
  function popSelectorInterface(bytes32 classifierId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 4, 1);
  }

  /** Pop a slice from selectorInterface (using the specified store) */
  function popSelectorInterface(IStore _store, bytes32 classifierId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.popFromField(_tableId, _keyTuple, 4, 1);
  }

  /** Update a slice of selectorInterface at `_index` */
  function updateSelectorInterface(bytes32 classifierId, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.updateInField(_tableId, _keyTuple, 4, _index * 1, bytes((_slice)));
  }

  /** Update a slice of selectorInterface (using the specified store) at `_index` */
  function updateSelectorInterface(IStore _store, bytes32 classifierId, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.updateInField(_tableId, _keyTuple, 4, _index * 1, bytes((_slice)));
  }

  /** Get classificationResultTableName */
  function getClassificationResultTableName(
    bytes32 classifierId
  ) internal view returns (string memory classificationResultTableName) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 5);
    return (string(_blob));
  }

  /** Get classificationResultTableName (using the specified store) */
  function getClassificationResultTableName(
    IStore _store,
    bytes32 classifierId
  ) internal view returns (string memory classificationResultTableName) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 5);
    return (string(_blob));
  }

  /** Set classificationResultTableName */
  function setClassificationResultTableName(
    bytes32 classifierId,
    string memory classificationResultTableName
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.setField(_tableId, _keyTuple, 5, bytes((classificationResultTableName)));
  }

  /** Set classificationResultTableName (using the specified store) */
  function setClassificationResultTableName(
    IStore _store,
    bytes32 classifierId,
    string memory classificationResultTableName
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.setField(_tableId, _keyTuple, 5, bytes((classificationResultTableName)));
  }

  /** Get the length of classificationResultTableName */
  function lengthClassificationResultTableName(bytes32 classifierId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 5, getSchema());
    return _byteLength / 1;
  }

  /** Get the length of classificationResultTableName (using the specified store) */
  function lengthClassificationResultTableName(IStore _store, bytes32 classifierId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 5, getSchema());
    return _byteLength / 1;
  }

  /** Get an item of classificationResultTableName (unchecked, returns invalid data if index overflows) */
  function getItemClassificationResultTableName(
    bytes32 classifierId,
    uint256 _index
  ) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = StoreSwitch.getFieldSlice(_tableId, _keyTuple, 5, getSchema(), _index * 1, (_index + 1) * 1);
    return (string(_blob));
  }

  /** Get an item of classificationResultTableName (using the specified store) (unchecked, returns invalid data if index overflows) */
  function getItemClassificationResultTableName(
    IStore _store,
    bytes32 classifierId,
    uint256 _index
  ) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 5, getSchema(), _index * 1, (_index + 1) * 1);
    return (string(_blob));
  }

  /** Push a slice to classificationResultTableName */
  function pushClassificationResultTableName(bytes32 classifierId, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 5, bytes((_slice)));
  }

  /** Push a slice to classificationResultTableName (using the specified store) */
  function pushClassificationResultTableName(IStore _store, bytes32 classifierId, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.pushToField(_tableId, _keyTuple, 5, bytes((_slice)));
  }

  /** Pop a slice from classificationResultTableName */
  function popClassificationResultTableName(bytes32 classifierId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 5, 1);
  }

  /** Pop a slice from classificationResultTableName (using the specified store) */
  function popClassificationResultTableName(IStore _store, bytes32 classifierId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.popFromField(_tableId, _keyTuple, 5, 1);
  }

  /** Update a slice of classificationResultTableName at `_index` */
  function updateClassificationResultTableName(bytes32 classifierId, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.updateInField(_tableId, _keyTuple, 5, _index * 1, bytes((_slice)));
  }

  /** Update a slice of classificationResultTableName (using the specified store) at `_index` */
  function updateClassificationResultTableName(
    IStore _store,
    bytes32 classifierId,
    uint256 _index,
    string memory _slice
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.updateInField(_tableId, _keyTuple, 5, _index * 1, bytes((_slice)));
  }

  /** Get the full data */
  function get(bytes32 classifierId) internal view returns (ClassifierRegistryData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store, bytes32 classifierId) internal view returns (ClassifierRegistryData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(
    bytes32 classifierId,
    address creator,
    bytes4 classifySelector,
    string memory name,
    string memory description,
    bytes memory selectorInterface,
    string memory classificationResultTableName
  ) internal {
    bytes memory _data = encode(
      creator,
      classifySelector,
      name,
      description,
      selectorInterface,
      classificationResultTableName
    );

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using individual values (using the specified store) */
  function set(
    IStore _store,
    bytes32 classifierId,
    address creator,
    bytes4 classifySelector,
    string memory name,
    string memory description,
    bytes memory selectorInterface,
    string memory classificationResultTableName
  ) internal {
    bytes memory _data = encode(
      creator,
      classifySelector,
      name,
      description,
      selectorInterface,
      classificationResultTableName
    );

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using the data struct */
  function set(bytes32 classifierId, ClassifierRegistryData memory _table) internal {
    set(
      classifierId,
      _table.creator,
      _table.classifySelector,
      _table.name,
      _table.description,
      _table.selectorInterface,
      _table.classificationResultTableName
    );
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, bytes32 classifierId, ClassifierRegistryData memory _table) internal {
    set(
      _store,
      classifierId,
      _table.creator,
      _table.classifySelector,
      _table.name,
      _table.description,
      _table.selectorInterface,
      _table.classificationResultTableName
    );
  }

  /** Decode the tightly packed blob using this table's schema */
  function decode(bytes memory _blob) internal pure returns (ClassifierRegistryData memory _table) {
    // 24 is the total byte length of static data
    PackedCounter _encodedLengths = PackedCounter.wrap(Bytes.slice32(_blob, 24));

    _table.creator = (address(Bytes.slice20(_blob, 0)));

    _table.classifySelector = (Bytes.slice4(_blob, 20));

    // Store trims the blob if dynamic fields are all empty
    if (_blob.length > 24) {
      uint256 _start;
      // skip static data length + dynamic lengths word
      uint256 _end = 56;

      _start = _end;
      _end += _encodedLengths.atIndex(0);
      _table.name = (string(SliceLib.getSubslice(_blob, _start, _end).toBytes()));

      _start = _end;
      _end += _encodedLengths.atIndex(1);
      _table.description = (string(SliceLib.getSubslice(_blob, _start, _end).toBytes()));

      _start = _end;
      _end += _encodedLengths.atIndex(2);
      _table.selectorInterface = (bytes(SliceLib.getSubslice(_blob, _start, _end).toBytes()));

      _start = _end;
      _end += _encodedLengths.atIndex(3);
      _table.classificationResultTableName = (string(SliceLib.getSubslice(_blob, _start, _end).toBytes()));
    }
  }

  /** Tightly pack full data using this table's schema */
  function encode(
    address creator,
    bytes4 classifySelector,
    string memory name,
    string memory description,
    bytes memory selectorInterface,
    string memory classificationResultTableName
  ) internal pure returns (bytes memory) {
    uint40[] memory _counters = new uint40[](4);
    _counters[0] = uint40(bytes(name).length);
    _counters[1] = uint40(bytes(description).length);
    _counters[2] = uint40(bytes(selectorInterface).length);
    _counters[3] = uint40(bytes(classificationResultTableName).length);
    PackedCounter _encodedLengths = PackedCounterLib.pack(_counters);

    return
      abi.encodePacked(
        creator,
        classifySelector,
        _encodedLengths.unwrap(),
        bytes((name)),
        bytes((description)),
        bytes((selectorInterface)),
        bytes((classificationResultTableName))
      );
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(bytes32 classifierId) internal pure returns (bytes32[] memory _keyTuple) {
    _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;
  }

  /* Delete all data for given keys */
  function deleteRecord(bytes32 classifierId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, bytes32 classifierId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = classifierId;

    _store.deleteRecord(_tableId, _keyTuple);
  }
}