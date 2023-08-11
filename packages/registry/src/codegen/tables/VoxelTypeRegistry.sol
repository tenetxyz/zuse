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

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("VoxelTypeRegistr")));
bytes32 constant VoxelTypeRegistryTableId = _tableId;

struct VoxelTypeRegistryData {
  uint32 scale;
  bytes32 previewVoxelVariantId;
  bytes32 baseVoxelTypeId;
  bytes4 enterWorldSelector;
  bytes4 exitWorldSelector;
  bytes4 voxelVariantSelector;
  bytes4 activateSelector;
  bytes4 interactionSelector;
  bytes metadata;
  bytes32[] childVoxelTypeIds;
  bytes32[] schemaVoxelTypeIds;
}

library VoxelTypeRegistry {
  /** Get the table's schema */
  function getSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](11);
    _schema[0] = SchemaType.UINT32;
    _schema[1] = SchemaType.BYTES32;
    _schema[2] = SchemaType.BYTES32;
    _schema[3] = SchemaType.BYTES4;
    _schema[4] = SchemaType.BYTES4;
    _schema[5] = SchemaType.BYTES4;
    _schema[6] = SchemaType.BYTES4;
    _schema[7] = SchemaType.BYTES4;
    _schema[8] = SchemaType.BYTES;
    _schema[9] = SchemaType.BYTES32_ARRAY;
    _schema[10] = SchemaType.BYTES32_ARRAY;

    return SchemaLib.encode(_schema);
  }

  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.BYTES32;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's metadata */
  function getMetadata() internal pure returns (string memory, string[] memory) {
    string[] memory _fieldNames = new string[](11);
    _fieldNames[0] = "scale";
    _fieldNames[1] = "previewVoxelVariantId";
    _fieldNames[2] = "baseVoxelTypeId";
    _fieldNames[3] = "enterWorldSelector";
    _fieldNames[4] = "exitWorldSelector";
    _fieldNames[5] = "voxelVariantSelector";
    _fieldNames[6] = "activateSelector";
    _fieldNames[7] = "interactionSelector";
    _fieldNames[8] = "metadata";
    _fieldNames[9] = "childVoxelTypeIds";
    _fieldNames[10] = "schemaVoxelTypeIds";
    return ("VoxelTypeRegistry", _fieldNames);
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

  /** Get scale */
  function getScale(bytes32 voxelTypeId) internal view returns (uint32 scale) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0);
    return (uint32(Bytes.slice4(_blob, 0)));
  }

  /** Get scale (using the specified store) */
  function getScale(IStore _store, bytes32 voxelTypeId) internal view returns (uint32 scale) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0);
    return (uint32(Bytes.slice4(_blob, 0)));
  }

  /** Set scale */
  function setScale(bytes32 voxelTypeId, uint32 scale) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((scale)));
  }

  /** Set scale (using the specified store) */
  function setScale(IStore _store, bytes32 voxelTypeId, uint32 scale) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((scale)));
  }

  /** Get previewVoxelVariantId */
  function getPreviewVoxelVariantId(bytes32 voxelTypeId) internal view returns (bytes32 previewVoxelVariantId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1);
    return (Bytes.slice32(_blob, 0));
  }

  /** Get previewVoxelVariantId (using the specified store) */
  function getPreviewVoxelVariantId(
    IStore _store,
    bytes32 voxelTypeId
  ) internal view returns (bytes32 previewVoxelVariantId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1);
    return (Bytes.slice32(_blob, 0));
  }

  /** Set previewVoxelVariantId */
  function setPreviewVoxelVariantId(bytes32 voxelTypeId, bytes32 previewVoxelVariantId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.setField(_tableId, _keyTuple, 1, abi.encodePacked((previewVoxelVariantId)));
  }

  /** Set previewVoxelVariantId (using the specified store) */
  function setPreviewVoxelVariantId(IStore _store, bytes32 voxelTypeId, bytes32 previewVoxelVariantId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.setField(_tableId, _keyTuple, 1, abi.encodePacked((previewVoxelVariantId)));
  }

  /** Get baseVoxelTypeId */
  function getBaseVoxelTypeId(bytes32 voxelTypeId) internal view returns (bytes32 baseVoxelTypeId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 2);
    return (Bytes.slice32(_blob, 0));
  }

  /** Get baseVoxelTypeId (using the specified store) */
  function getBaseVoxelTypeId(IStore _store, bytes32 voxelTypeId) internal view returns (bytes32 baseVoxelTypeId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 2);
    return (Bytes.slice32(_blob, 0));
  }

  /** Set baseVoxelTypeId */
  function setBaseVoxelTypeId(bytes32 voxelTypeId, bytes32 baseVoxelTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.setField(_tableId, _keyTuple, 2, abi.encodePacked((baseVoxelTypeId)));
  }

  /** Set baseVoxelTypeId (using the specified store) */
  function setBaseVoxelTypeId(IStore _store, bytes32 voxelTypeId, bytes32 baseVoxelTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.setField(_tableId, _keyTuple, 2, abi.encodePacked((baseVoxelTypeId)));
  }

  /** Get enterWorldSelector */
  function getEnterWorldSelector(bytes32 voxelTypeId) internal view returns (bytes4 enterWorldSelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 3);
    return (Bytes.slice4(_blob, 0));
  }

  /** Get enterWorldSelector (using the specified store) */
  function getEnterWorldSelector(IStore _store, bytes32 voxelTypeId) internal view returns (bytes4 enterWorldSelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 3);
    return (Bytes.slice4(_blob, 0));
  }

  /** Set enterWorldSelector */
  function setEnterWorldSelector(bytes32 voxelTypeId, bytes4 enterWorldSelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.setField(_tableId, _keyTuple, 3, abi.encodePacked((enterWorldSelector)));
  }

  /** Set enterWorldSelector (using the specified store) */
  function setEnterWorldSelector(IStore _store, bytes32 voxelTypeId, bytes4 enterWorldSelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.setField(_tableId, _keyTuple, 3, abi.encodePacked((enterWorldSelector)));
  }

  /** Get exitWorldSelector */
  function getExitWorldSelector(bytes32 voxelTypeId) internal view returns (bytes4 exitWorldSelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 4);
    return (Bytes.slice4(_blob, 0));
  }

  /** Get exitWorldSelector (using the specified store) */
  function getExitWorldSelector(IStore _store, bytes32 voxelTypeId) internal view returns (bytes4 exitWorldSelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 4);
    return (Bytes.slice4(_blob, 0));
  }

  /** Set exitWorldSelector */
  function setExitWorldSelector(bytes32 voxelTypeId, bytes4 exitWorldSelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.setField(_tableId, _keyTuple, 4, abi.encodePacked((exitWorldSelector)));
  }

  /** Set exitWorldSelector (using the specified store) */
  function setExitWorldSelector(IStore _store, bytes32 voxelTypeId, bytes4 exitWorldSelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.setField(_tableId, _keyTuple, 4, abi.encodePacked((exitWorldSelector)));
  }

  /** Get voxelVariantSelector */
  function getVoxelVariantSelector(bytes32 voxelTypeId) internal view returns (bytes4 voxelVariantSelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 5);
    return (Bytes.slice4(_blob, 0));
  }

  /** Get voxelVariantSelector (using the specified store) */
  function getVoxelVariantSelector(
    IStore _store,
    bytes32 voxelTypeId
  ) internal view returns (bytes4 voxelVariantSelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 5);
    return (Bytes.slice4(_blob, 0));
  }

  /** Set voxelVariantSelector */
  function setVoxelVariantSelector(bytes32 voxelTypeId, bytes4 voxelVariantSelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.setField(_tableId, _keyTuple, 5, abi.encodePacked((voxelVariantSelector)));
  }

  /** Set voxelVariantSelector (using the specified store) */
  function setVoxelVariantSelector(IStore _store, bytes32 voxelTypeId, bytes4 voxelVariantSelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.setField(_tableId, _keyTuple, 5, abi.encodePacked((voxelVariantSelector)));
  }

  /** Get activateSelector */
  function getActivateSelector(bytes32 voxelTypeId) internal view returns (bytes4 activateSelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 6);
    return (Bytes.slice4(_blob, 0));
  }

  /** Get activateSelector (using the specified store) */
  function getActivateSelector(IStore _store, bytes32 voxelTypeId) internal view returns (bytes4 activateSelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 6);
    return (Bytes.slice4(_blob, 0));
  }

  /** Set activateSelector */
  function setActivateSelector(bytes32 voxelTypeId, bytes4 activateSelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.setField(_tableId, _keyTuple, 6, abi.encodePacked((activateSelector)));
  }

  /** Set activateSelector (using the specified store) */
  function setActivateSelector(IStore _store, bytes32 voxelTypeId, bytes4 activateSelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.setField(_tableId, _keyTuple, 6, abi.encodePacked((activateSelector)));
  }

  /** Get interactionSelector */
  function getInteractionSelector(bytes32 voxelTypeId) internal view returns (bytes4 interactionSelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 7);
    return (Bytes.slice4(_blob, 0));
  }

  /** Get interactionSelector (using the specified store) */
  function getInteractionSelector(
    IStore _store,
    bytes32 voxelTypeId
  ) internal view returns (bytes4 interactionSelector) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 7);
    return (Bytes.slice4(_blob, 0));
  }

  /** Set interactionSelector */
  function setInteractionSelector(bytes32 voxelTypeId, bytes4 interactionSelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.setField(_tableId, _keyTuple, 7, abi.encodePacked((interactionSelector)));
  }

  /** Set interactionSelector (using the specified store) */
  function setInteractionSelector(IStore _store, bytes32 voxelTypeId, bytes4 interactionSelector) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.setField(_tableId, _keyTuple, 7, abi.encodePacked((interactionSelector)));
  }

  /** Get metadata */
  function getMetadata(bytes32 voxelTypeId) internal view returns (bytes memory metadata) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 8);
    return (bytes(_blob));
  }

  /** Get metadata (using the specified store) */
  function getMetadata(IStore _store, bytes32 voxelTypeId) internal view returns (bytes memory metadata) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 8);
    return (bytes(_blob));
  }

  /** Set metadata */
  function setMetadata(bytes32 voxelTypeId, bytes memory metadata) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.setField(_tableId, _keyTuple, 8, bytes((metadata)));
  }

  /** Set metadata (using the specified store) */
  function setMetadata(IStore _store, bytes32 voxelTypeId, bytes memory metadata) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.setField(_tableId, _keyTuple, 8, bytes((metadata)));
  }

  /** Get the length of metadata */
  function lengthMetadata(bytes32 voxelTypeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 8, getSchema());
    return _byteLength / 1;
  }

  /** Get the length of metadata (using the specified store) */
  function lengthMetadata(IStore _store, bytes32 voxelTypeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 8, getSchema());
    return _byteLength / 1;
  }

  /** Get an item of metadata (unchecked, returns invalid data if index overflows) */
  function getItemMetadata(bytes32 voxelTypeId, uint256 _index) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getFieldSlice(_tableId, _keyTuple, 8, getSchema(), _index * 1, (_index + 1) * 1);
    return (bytes(_blob));
  }

  /** Get an item of metadata (using the specified store) (unchecked, returns invalid data if index overflows) */
  function getItemMetadata(IStore _store, bytes32 voxelTypeId, uint256 _index) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 8, getSchema(), _index * 1, (_index + 1) * 1);
    return (bytes(_blob));
  }

  /** Push a slice to metadata */
  function pushMetadata(bytes32 voxelTypeId, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 8, bytes((_slice)));
  }

  /** Push a slice to metadata (using the specified store) */
  function pushMetadata(IStore _store, bytes32 voxelTypeId, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.pushToField(_tableId, _keyTuple, 8, bytes((_slice)));
  }

  /** Pop a slice from metadata */
  function popMetadata(bytes32 voxelTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 8, 1);
  }

  /** Pop a slice from metadata (using the specified store) */
  function popMetadata(IStore _store, bytes32 voxelTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.popFromField(_tableId, _keyTuple, 8, 1);
  }

  /** Update a slice of metadata at `_index` */
  function updateMetadata(bytes32 voxelTypeId, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.updateInField(_tableId, _keyTuple, 8, _index * 1, bytes((_slice)));
  }

  /** Update a slice of metadata (using the specified store) at `_index` */
  function updateMetadata(IStore _store, bytes32 voxelTypeId, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.updateInField(_tableId, _keyTuple, 8, _index * 1, bytes((_slice)));
  }

  /** Get childVoxelTypeIds */
  function getChildVoxelTypeIds(bytes32 voxelTypeId) internal view returns (bytes32[] memory childVoxelTypeIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 9);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_bytes32());
  }

  /** Get childVoxelTypeIds (using the specified store) */
  function getChildVoxelTypeIds(
    IStore _store,
    bytes32 voxelTypeId
  ) internal view returns (bytes32[] memory childVoxelTypeIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 9);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_bytes32());
  }

  /** Set childVoxelTypeIds */
  function setChildVoxelTypeIds(bytes32 voxelTypeId, bytes32[] memory childVoxelTypeIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.setField(_tableId, _keyTuple, 9, EncodeArray.encode((childVoxelTypeIds)));
  }

  /** Set childVoxelTypeIds (using the specified store) */
  function setChildVoxelTypeIds(IStore _store, bytes32 voxelTypeId, bytes32[] memory childVoxelTypeIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.setField(_tableId, _keyTuple, 9, EncodeArray.encode((childVoxelTypeIds)));
  }

  /** Get the length of childVoxelTypeIds */
  function lengthChildVoxelTypeIds(bytes32 voxelTypeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 9, getSchema());
    return _byteLength / 32;
  }

  /** Get the length of childVoxelTypeIds (using the specified store) */
  function lengthChildVoxelTypeIds(IStore _store, bytes32 voxelTypeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 9, getSchema());
    return _byteLength / 32;
  }

  /** Get an item of childVoxelTypeIds (unchecked, returns invalid data if index overflows) */
  function getItemChildVoxelTypeIds(bytes32 voxelTypeId, uint256 _index) internal view returns (bytes32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getFieldSlice(_tableId, _keyTuple, 9, getSchema(), _index * 32, (_index + 1) * 32);
    return (Bytes.slice32(_blob, 0));
  }

  /** Get an item of childVoxelTypeIds (using the specified store) (unchecked, returns invalid data if index overflows) */
  function getItemChildVoxelTypeIds(
    IStore _store,
    bytes32 voxelTypeId,
    uint256 _index
  ) internal view returns (bytes32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 9, getSchema(), _index * 32, (_index + 1) * 32);
    return (Bytes.slice32(_blob, 0));
  }

  /** Push an element to childVoxelTypeIds */
  function pushChildVoxelTypeIds(bytes32 voxelTypeId, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 9, abi.encodePacked((_element)));
  }

  /** Push an element to childVoxelTypeIds (using the specified store) */
  function pushChildVoxelTypeIds(IStore _store, bytes32 voxelTypeId, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.pushToField(_tableId, _keyTuple, 9, abi.encodePacked((_element)));
  }

  /** Pop an element from childVoxelTypeIds */
  function popChildVoxelTypeIds(bytes32 voxelTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 9, 32);
  }

  /** Pop an element from childVoxelTypeIds (using the specified store) */
  function popChildVoxelTypeIds(IStore _store, bytes32 voxelTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.popFromField(_tableId, _keyTuple, 9, 32);
  }

  /** Update an element of childVoxelTypeIds at `_index` */
  function updateChildVoxelTypeIds(bytes32 voxelTypeId, uint256 _index, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.updateInField(_tableId, _keyTuple, 9, _index * 32, abi.encodePacked((_element)));
  }

  /** Update an element of childVoxelTypeIds (using the specified store) at `_index` */
  function updateChildVoxelTypeIds(IStore _store, bytes32 voxelTypeId, uint256 _index, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.updateInField(_tableId, _keyTuple, 9, _index * 32, abi.encodePacked((_element)));
  }

  /** Get schemaVoxelTypeIds */
  function getSchemaVoxelTypeIds(bytes32 voxelTypeId) internal view returns (bytes32[] memory schemaVoxelTypeIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 10);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_bytes32());
  }

  /** Get schemaVoxelTypeIds (using the specified store) */
  function getSchemaVoxelTypeIds(
    IStore _store,
    bytes32 voxelTypeId
  ) internal view returns (bytes32[] memory schemaVoxelTypeIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 10);
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_bytes32());
  }

  /** Set schemaVoxelTypeIds */
  function setSchemaVoxelTypeIds(bytes32 voxelTypeId, bytes32[] memory schemaVoxelTypeIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.setField(_tableId, _keyTuple, 10, EncodeArray.encode((schemaVoxelTypeIds)));
  }

  /** Set schemaVoxelTypeIds (using the specified store) */
  function setSchemaVoxelTypeIds(IStore _store, bytes32 voxelTypeId, bytes32[] memory schemaVoxelTypeIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.setField(_tableId, _keyTuple, 10, EncodeArray.encode((schemaVoxelTypeIds)));
  }

  /** Get the length of schemaVoxelTypeIds */
  function lengthSchemaVoxelTypeIds(bytes32 voxelTypeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 10, getSchema());
    return _byteLength / 32;
  }

  /** Get the length of schemaVoxelTypeIds (using the specified store) */
  function lengthSchemaVoxelTypeIds(IStore _store, bytes32 voxelTypeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 10, getSchema());
    return _byteLength / 32;
  }

  /** Get an item of schemaVoxelTypeIds (unchecked, returns invalid data if index overflows) */
  function getItemSchemaVoxelTypeIds(bytes32 voxelTypeId, uint256 _index) internal view returns (bytes32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getFieldSlice(
      _tableId,
      _keyTuple,
      10,
      getSchema(),
      _index * 32,
      (_index + 1) * 32
    );
    return (Bytes.slice32(_blob, 0));
  }

  /** Get an item of schemaVoxelTypeIds (using the specified store) (unchecked, returns invalid data if index overflows) */
  function getItemSchemaVoxelTypeIds(
    IStore _store,
    bytes32 voxelTypeId,
    uint256 _index
  ) internal view returns (bytes32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 10, getSchema(), _index * 32, (_index + 1) * 32);
    return (Bytes.slice32(_blob, 0));
  }

  /** Push an element to schemaVoxelTypeIds */
  function pushSchemaVoxelTypeIds(bytes32 voxelTypeId, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 10, abi.encodePacked((_element)));
  }

  /** Push an element to schemaVoxelTypeIds (using the specified store) */
  function pushSchemaVoxelTypeIds(IStore _store, bytes32 voxelTypeId, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.pushToField(_tableId, _keyTuple, 10, abi.encodePacked((_element)));
  }

  /** Pop an element from schemaVoxelTypeIds */
  function popSchemaVoxelTypeIds(bytes32 voxelTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 10, 32);
  }

  /** Pop an element from schemaVoxelTypeIds (using the specified store) */
  function popSchemaVoxelTypeIds(IStore _store, bytes32 voxelTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.popFromField(_tableId, _keyTuple, 10, 32);
  }

  /** Update an element of schemaVoxelTypeIds at `_index` */
  function updateSchemaVoxelTypeIds(bytes32 voxelTypeId, uint256 _index, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.updateInField(_tableId, _keyTuple, 10, _index * 32, abi.encodePacked((_element)));
  }

  /** Update an element of schemaVoxelTypeIds (using the specified store) at `_index` */
  function updateSchemaVoxelTypeIds(IStore _store, bytes32 voxelTypeId, uint256 _index, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.updateInField(_tableId, _keyTuple, 10, _index * 32, abi.encodePacked((_element)));
  }

  /** Get the full data */
  function get(bytes32 voxelTypeId) internal view returns (VoxelTypeRegistryData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store, bytes32 voxelTypeId) internal view returns (VoxelTypeRegistryData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(
    bytes32 voxelTypeId,
    uint32 scale,
    bytes32 previewVoxelVariantId,
    bytes32 baseVoxelTypeId,
    bytes4 enterWorldSelector,
    bytes4 exitWorldSelector,
    bytes4 voxelVariantSelector,
    bytes4 activateSelector,
    bytes4 interactionSelector,
    bytes memory metadata,
    bytes32[] memory childVoxelTypeIds,
    bytes32[] memory schemaVoxelTypeIds
  ) internal {
    bytes memory _data = encode(
      scale,
      previewVoxelVariantId,
      baseVoxelTypeId,
      enterWorldSelector,
      exitWorldSelector,
      voxelVariantSelector,
      activateSelector,
      interactionSelector,
      metadata,
      childVoxelTypeIds,
      schemaVoxelTypeIds
    );

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using individual values (using the specified store) */
  function set(
    IStore _store,
    bytes32 voxelTypeId,
    uint32 scale,
    bytes32 previewVoxelVariantId,
    bytes32 baseVoxelTypeId,
    bytes4 enterWorldSelector,
    bytes4 exitWorldSelector,
    bytes4 voxelVariantSelector,
    bytes4 activateSelector,
    bytes4 interactionSelector,
    bytes memory metadata,
    bytes32[] memory childVoxelTypeIds,
    bytes32[] memory schemaVoxelTypeIds
  ) internal {
    bytes memory _data = encode(
      scale,
      previewVoxelVariantId,
      baseVoxelTypeId,
      enterWorldSelector,
      exitWorldSelector,
      voxelVariantSelector,
      activateSelector,
      interactionSelector,
      metadata,
      childVoxelTypeIds,
      schemaVoxelTypeIds
    );

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using the data struct */
  function set(bytes32 voxelTypeId, VoxelTypeRegistryData memory _table) internal {
    set(
      voxelTypeId,
      _table.scale,
      _table.previewVoxelVariantId,
      _table.baseVoxelTypeId,
      _table.enterWorldSelector,
      _table.exitWorldSelector,
      _table.voxelVariantSelector,
      _table.activateSelector,
      _table.interactionSelector,
      _table.metadata,
      _table.childVoxelTypeIds,
      _table.schemaVoxelTypeIds
    );
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, bytes32 voxelTypeId, VoxelTypeRegistryData memory _table) internal {
    set(
      _store,
      voxelTypeId,
      _table.scale,
      _table.previewVoxelVariantId,
      _table.baseVoxelTypeId,
      _table.enterWorldSelector,
      _table.exitWorldSelector,
      _table.voxelVariantSelector,
      _table.activateSelector,
      _table.interactionSelector,
      _table.metadata,
      _table.childVoxelTypeIds,
      _table.schemaVoxelTypeIds
    );
  }

  /** Decode the tightly packed blob using this table's schema */
  function decode(bytes memory _blob) internal pure returns (VoxelTypeRegistryData memory _table) {
    // 88 is the total byte length of static data
    PackedCounter _encodedLengths = PackedCounter.wrap(Bytes.slice32(_blob, 88));

    _table.scale = (uint32(Bytes.slice4(_blob, 0)));

    _table.previewVoxelVariantId = (Bytes.slice32(_blob, 4));

    _table.baseVoxelTypeId = (Bytes.slice32(_blob, 36));

    _table.enterWorldSelector = (Bytes.slice4(_blob, 68));

    _table.exitWorldSelector = (Bytes.slice4(_blob, 72));

    _table.voxelVariantSelector = (Bytes.slice4(_blob, 76));

    _table.activateSelector = (Bytes.slice4(_blob, 80));

    _table.interactionSelector = (Bytes.slice4(_blob, 84));

    // Store trims the blob if dynamic fields are all empty
    if (_blob.length > 88) {
      uint256 _start;
      // skip static data length + dynamic lengths word
      uint256 _end = 120;

      _start = _end;
      _end += _encodedLengths.atIndex(0);
      _table.metadata = (bytes(SliceLib.getSubslice(_blob, _start, _end).toBytes()));

      _start = _end;
      _end += _encodedLengths.atIndex(1);
      _table.childVoxelTypeIds = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_bytes32());

      _start = _end;
      _end += _encodedLengths.atIndex(2);
      _table.schemaVoxelTypeIds = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_bytes32());
    }
  }

  /** Tightly pack full data using this table's schema */
  function encode(
    uint32 scale,
    bytes32 previewVoxelVariantId,
    bytes32 baseVoxelTypeId,
    bytes4 enterWorldSelector,
    bytes4 exitWorldSelector,
    bytes4 voxelVariantSelector,
    bytes4 activateSelector,
    bytes4 interactionSelector,
    bytes memory metadata,
    bytes32[] memory childVoxelTypeIds,
    bytes32[] memory schemaVoxelTypeIds
  ) internal pure returns (bytes memory) {
    uint40[] memory _counters = new uint40[](3);
    _counters[0] = uint40(bytes(metadata).length);
    _counters[1] = uint40(childVoxelTypeIds.length * 32);
    _counters[2] = uint40(schemaVoxelTypeIds.length * 32);
    PackedCounter _encodedLengths = PackedCounterLib.pack(_counters);

    return
      abi.encodePacked(
        scale,
        previewVoxelVariantId,
        baseVoxelTypeId,
        enterWorldSelector,
        exitWorldSelector,
        voxelVariantSelector,
        activateSelector,
        interactionSelector,
        _encodedLengths.unwrap(),
        bytes((metadata)),
        EncodeArray.encode((childVoxelTypeIds)),
        EncodeArray.encode((schemaVoxelTypeIds))
      );
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(bytes32 voxelTypeId) internal pure returns (bytes32[] memory _keyTuple) {
    _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;
  }

  /* Delete all data for given keys */
  function deleteRecord(bytes32 voxelTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, bytes32 voxelTypeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelTypeId;

    _store.deleteRecord(_tableId, _keyTuple);
  }
}
