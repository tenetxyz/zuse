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

// Import user types
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("VoxelVariantsReg")));
bytes32 constant VoxelVariantsRegistryTableId = _tableId;

struct VoxelVariantsRegistryData {
  uint256 variantId;
  uint32 frames;
  bool opaque;
  bool fluid;
  bool solid;
  NoaBlockType blockType;
  bytes materials;
  string uvWrap;
}

library VoxelVariantsRegistry {
  /** Get the table's schema */
  function getSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](8);
    _schema[0] = SchemaType.UINT256;
    _schema[1] = SchemaType.UINT32;
    _schema[2] = SchemaType.BOOL;
    _schema[3] = SchemaType.BOOL;
    _schema[4] = SchemaType.BOOL;
    _schema[5] = SchemaType.UINT8;
    _schema[6] = SchemaType.BYTES;
    _schema[7] = SchemaType.STRING;

    return SchemaLib.encode(_schema);
  }

  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.BYTES32;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's metadata */
  function getMetadata() internal pure returns (string memory, string[] memory) {
    string[] memory _fieldNames = new string[](8);
    _fieldNames[0] = "variantId";
    _fieldNames[1] = "frames";
    _fieldNames[2] = "opaque";
    _fieldNames[3] = "fluid";
    _fieldNames[4] = "solid";
    _fieldNames[5] = "blockType";
    _fieldNames[6] = "materials";
    _fieldNames[7] = "uvWrap";
    return ("VoxelVariantsRegistry", _fieldNames);
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

  /** Get variantId */
  function getVariantId(bytes32 voxelVariantId) internal view returns (uint256 variantId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0);
    return (uint256(Bytes.slice32(_blob, 0)));
  }

  /** Get variantId (using the specified store) */
  function getVariantId(IStore _store, bytes32 voxelVariantId) internal view returns (uint256 variantId) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0);
    return (uint256(Bytes.slice32(_blob, 0)));
  }

  /** Set variantId */
  function setVariantId(bytes32 voxelVariantId, uint256 variantId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked((variantId)));
  }

  /** Set variantId (using the specified store) */
  function setVariantId(IStore _store, bytes32 voxelVariantId, uint256 variantId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked((variantId)));
  }

  /** Get frames */
  function getFrames(bytes32 voxelVariantId) internal view returns (uint32 frames) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1);
    return (uint32(Bytes.slice4(_blob, 0)));
  }

  /** Get frames (using the specified store) */
  function getFrames(IStore _store, bytes32 voxelVariantId) internal view returns (uint32 frames) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1);
    return (uint32(Bytes.slice4(_blob, 0)));
  }

  /** Set frames */
  function setFrames(bytes32 voxelVariantId, uint32 frames) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.setField(_tableId, _keyTuple, 1, abi.encodePacked((frames)));
  }

  /** Set frames (using the specified store) */
  function setFrames(IStore _store, bytes32 voxelVariantId, uint32 frames) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.setField(_tableId, _keyTuple, 1, abi.encodePacked((frames)));
  }

  /** Get opaque */
  function getOpaque(bytes32 voxelVariantId) internal view returns (bool opaque) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 2);
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Get opaque (using the specified store) */
  function getOpaque(IStore _store, bytes32 voxelVariantId) internal view returns (bool opaque) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 2);
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Set opaque */
  function setOpaque(bytes32 voxelVariantId, bool opaque) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.setField(_tableId, _keyTuple, 2, abi.encodePacked((opaque)));
  }

  /** Set opaque (using the specified store) */
  function setOpaque(IStore _store, bytes32 voxelVariantId, bool opaque) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.setField(_tableId, _keyTuple, 2, abi.encodePacked((opaque)));
  }

  /** Get fluid */
  function getFluid(bytes32 voxelVariantId) internal view returns (bool fluid) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 3);
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Get fluid (using the specified store) */
  function getFluid(IStore _store, bytes32 voxelVariantId) internal view returns (bool fluid) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 3);
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Set fluid */
  function setFluid(bytes32 voxelVariantId, bool fluid) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.setField(_tableId, _keyTuple, 3, abi.encodePacked((fluid)));
  }

  /** Set fluid (using the specified store) */
  function setFluid(IStore _store, bytes32 voxelVariantId, bool fluid) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.setField(_tableId, _keyTuple, 3, abi.encodePacked((fluid)));
  }

  /** Get solid */
  function getSolid(bytes32 voxelVariantId) internal view returns (bool solid) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 4);
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Get solid (using the specified store) */
  function getSolid(IStore _store, bytes32 voxelVariantId) internal view returns (bool solid) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 4);
    return (_toBool(uint8(Bytes.slice1(_blob, 0))));
  }

  /** Set solid */
  function setSolid(bytes32 voxelVariantId, bool solid) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.setField(_tableId, _keyTuple, 4, abi.encodePacked((solid)));
  }

  /** Set solid (using the specified store) */
  function setSolid(IStore _store, bytes32 voxelVariantId, bool solid) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.setField(_tableId, _keyTuple, 4, abi.encodePacked((solid)));
  }

  /** Get blockType */
  function getBlockType(bytes32 voxelVariantId) internal view returns (NoaBlockType blockType) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 5);
    return NoaBlockType(uint8(Bytes.slice1(_blob, 0)));
  }

  /** Get blockType (using the specified store) */
  function getBlockType(IStore _store, bytes32 voxelVariantId) internal view returns (NoaBlockType blockType) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 5);
    return NoaBlockType(uint8(Bytes.slice1(_blob, 0)));
  }

  /** Set blockType */
  function setBlockType(bytes32 voxelVariantId, NoaBlockType blockType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.setField(_tableId, _keyTuple, 5, abi.encodePacked(uint8(blockType)));
  }

  /** Set blockType (using the specified store) */
  function setBlockType(IStore _store, bytes32 voxelVariantId, NoaBlockType blockType) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.setField(_tableId, _keyTuple, 5, abi.encodePacked(uint8(blockType)));
  }

  /** Get materials */
  function getMaterials(bytes32 voxelVariantId) internal view returns (bytes memory materials) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 6);
    return (bytes(_blob));
  }

  /** Get materials (using the specified store) */
  function getMaterials(IStore _store, bytes32 voxelVariantId) internal view returns (bytes memory materials) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 6);
    return (bytes(_blob));
  }

  /** Set materials */
  function setMaterials(bytes32 voxelVariantId, bytes memory materials) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.setField(_tableId, _keyTuple, 6, bytes((materials)));
  }

  /** Set materials (using the specified store) */
  function setMaterials(IStore _store, bytes32 voxelVariantId, bytes memory materials) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.setField(_tableId, _keyTuple, 6, bytes((materials)));
  }

  /** Get the length of materials */
  function lengthMaterials(bytes32 voxelVariantId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 6, getSchema());
    return _byteLength / 1;
  }

  /** Get the length of materials (using the specified store) */
  function lengthMaterials(IStore _store, bytes32 voxelVariantId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 6, getSchema());
    return _byteLength / 1;
  }

  /** Get an item of materials (unchecked, returns invalid data if index overflows) */
  function getItemMaterials(bytes32 voxelVariantId, uint256 _index) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = StoreSwitch.getFieldSlice(_tableId, _keyTuple, 6, getSchema(), _index * 1, (_index + 1) * 1);
    return (bytes(_blob));
  }

  /** Get an item of materials (using the specified store) (unchecked, returns invalid data if index overflows) */
  function getItemMaterials(
    IStore _store,
    bytes32 voxelVariantId,
    uint256 _index
  ) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 6, getSchema(), _index * 1, (_index + 1) * 1);
    return (bytes(_blob));
  }

  /** Push a slice to materials */
  function pushMaterials(bytes32 voxelVariantId, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 6, bytes((_slice)));
  }

  /** Push a slice to materials (using the specified store) */
  function pushMaterials(IStore _store, bytes32 voxelVariantId, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.pushToField(_tableId, _keyTuple, 6, bytes((_slice)));
  }

  /** Pop a slice from materials */
  function popMaterials(bytes32 voxelVariantId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 6, 1);
  }

  /** Pop a slice from materials (using the specified store) */
  function popMaterials(IStore _store, bytes32 voxelVariantId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.popFromField(_tableId, _keyTuple, 6, 1);
  }

  /** Update a slice of materials at `_index` */
  function updateMaterials(bytes32 voxelVariantId, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.updateInField(_tableId, _keyTuple, 6, _index * 1, bytes((_slice)));
  }

  /** Update a slice of materials (using the specified store) at `_index` */
  function updateMaterials(IStore _store, bytes32 voxelVariantId, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.updateInField(_tableId, _keyTuple, 6, _index * 1, bytes((_slice)));
  }

  /** Get uvWrap */
  function getUvWrap(bytes32 voxelVariantId) internal view returns (string memory uvWrap) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 7);
    return (string(_blob));
  }

  /** Get uvWrap (using the specified store) */
  function getUvWrap(IStore _store, bytes32 voxelVariantId) internal view returns (string memory uvWrap) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 7);
    return (string(_blob));
  }

  /** Set uvWrap */
  function setUvWrap(bytes32 voxelVariantId, string memory uvWrap) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.setField(_tableId, _keyTuple, 7, bytes((uvWrap)));
  }

  /** Set uvWrap (using the specified store) */
  function setUvWrap(IStore _store, bytes32 voxelVariantId, string memory uvWrap) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.setField(_tableId, _keyTuple, 7, bytes((uvWrap)));
  }

  /** Get the length of uvWrap */
  function lengthUvWrap(bytes32 voxelVariantId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 7, getSchema());
    return _byteLength / 1;
  }

  /** Get the length of uvWrap (using the specified store) */
  function lengthUvWrap(IStore _store, bytes32 voxelVariantId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 7, getSchema());
    return _byteLength / 1;
  }

  /** Get an item of uvWrap (unchecked, returns invalid data if index overflows) */
  function getItemUvWrap(bytes32 voxelVariantId, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = StoreSwitch.getFieldSlice(_tableId, _keyTuple, 7, getSchema(), _index * 1, (_index + 1) * 1);
    return (string(_blob));
  }

  /** Get an item of uvWrap (using the specified store) (unchecked, returns invalid data if index overflows) */
  function getItemUvWrap(IStore _store, bytes32 voxelVariantId, uint256 _index) internal view returns (string memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 7, getSchema(), _index * 1, (_index + 1) * 1);
    return (string(_blob));
  }

  /** Push a slice to uvWrap */
  function pushUvWrap(bytes32 voxelVariantId, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 7, bytes((_slice)));
  }

  /** Push a slice to uvWrap (using the specified store) */
  function pushUvWrap(IStore _store, bytes32 voxelVariantId, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.pushToField(_tableId, _keyTuple, 7, bytes((_slice)));
  }

  /** Pop a slice from uvWrap */
  function popUvWrap(bytes32 voxelVariantId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 7, 1);
  }

  /** Pop a slice from uvWrap (using the specified store) */
  function popUvWrap(IStore _store, bytes32 voxelVariantId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.popFromField(_tableId, _keyTuple, 7, 1);
  }

  /** Update a slice of uvWrap at `_index` */
  function updateUvWrap(bytes32 voxelVariantId, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.updateInField(_tableId, _keyTuple, 7, _index * 1, bytes((_slice)));
  }

  /** Update a slice of uvWrap (using the specified store) at `_index` */
  function updateUvWrap(IStore _store, bytes32 voxelVariantId, uint256 _index, string memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.updateInField(_tableId, _keyTuple, 7, _index * 1, bytes((_slice)));
  }

  /** Get the full data */
  function get(bytes32 voxelVariantId) internal view returns (VoxelVariantsRegistryData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store, bytes32 voxelVariantId) internal view returns (VoxelVariantsRegistryData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(
    bytes32 voxelVariantId,
    uint256 variantId,
    uint32 frames,
    bool opaque,
    bool fluid,
    bool solid,
    NoaBlockType blockType,
    bytes memory materials,
    string memory uvWrap
  ) internal {
    bytes memory _data = encode(variantId, frames, opaque, fluid, solid, blockType, materials, uvWrap);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using individual values (using the specified store) */
  function set(
    IStore _store,
    bytes32 voxelVariantId,
    uint256 variantId,
    uint32 frames,
    bool opaque,
    bool fluid,
    bool solid,
    NoaBlockType blockType,
    bytes memory materials,
    string memory uvWrap
  ) internal {
    bytes memory _data = encode(variantId, frames, opaque, fluid, solid, blockType, materials, uvWrap);

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using the data struct */
  function set(bytes32 voxelVariantId, VoxelVariantsRegistryData memory _table) internal {
    set(
      voxelVariantId,
      _table.variantId,
      _table.frames,
      _table.opaque,
      _table.fluid,
      _table.solid,
      _table.blockType,
      _table.materials,
      _table.uvWrap
    );
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, bytes32 voxelVariantId, VoxelVariantsRegistryData memory _table) internal {
    set(
      _store,
      voxelVariantId,
      _table.variantId,
      _table.frames,
      _table.opaque,
      _table.fluid,
      _table.solid,
      _table.blockType,
      _table.materials,
      _table.uvWrap
    );
  }

  /** Decode the tightly packed blob using this table's schema */
  function decode(bytes memory _blob) internal pure returns (VoxelVariantsRegistryData memory _table) {
    // 40 is the total byte length of static data
    PackedCounter _encodedLengths = PackedCounter.wrap(Bytes.slice32(_blob, 40));

    _table.variantId = (uint256(Bytes.slice32(_blob, 0)));

    _table.frames = (uint32(Bytes.slice4(_blob, 32)));

    _table.opaque = (_toBool(uint8(Bytes.slice1(_blob, 36))));

    _table.fluid = (_toBool(uint8(Bytes.slice1(_blob, 37))));

    _table.solid = (_toBool(uint8(Bytes.slice1(_blob, 38))));

    _table.blockType = NoaBlockType(uint8(Bytes.slice1(_blob, 39)));

    // Store trims the blob if dynamic fields are all empty
    if (_blob.length > 40) {
      uint256 _start;
      // skip static data length + dynamic lengths word
      uint256 _end = 72;

      _start = _end;
      _end += _encodedLengths.atIndex(0);
      _table.materials = (bytes(SliceLib.getSubslice(_blob, _start, _end).toBytes()));

      _start = _end;
      _end += _encodedLengths.atIndex(1);
      _table.uvWrap = (string(SliceLib.getSubslice(_blob, _start, _end).toBytes()));
    }
  }

  /** Tightly pack full data using this table's schema */
  function encode(
    uint256 variantId,
    uint32 frames,
    bool opaque,
    bool fluid,
    bool solid,
    NoaBlockType blockType,
    bytes memory materials,
    string memory uvWrap
  ) internal pure returns (bytes memory) {
    uint40[] memory _counters = new uint40[](2);
    _counters[0] = uint40(bytes(materials).length);
    _counters[1] = uint40(bytes(uvWrap).length);
    PackedCounter _encodedLengths = PackedCounterLib.pack(_counters);

    return
      abi.encodePacked(
        variantId,
        frames,
        opaque,
        fluid,
        solid,
        blockType,
        _encodedLengths.unwrap(),
        bytes((materials)),
        bytes((uvWrap))
      );
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(bytes32 voxelVariantId) internal pure returns (bytes32[] memory _keyTuple) {
    _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;
  }

  /* Delete all data for given keys */
  function deleteRecord(bytes32 voxelVariantId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, bytes32 voxelVariantId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = voxelVariantId;

    _store.deleteRecord(_tableId, _keyTuple);
  }
}

function _toBool(uint8 value) pure returns (bool result) {
  assembly {
    result := value
  }
}
