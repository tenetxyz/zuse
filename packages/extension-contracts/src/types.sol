// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";

// TODO: should not be duplicated from "@tenetxyz/contracts
struct VoxelVariantsData {
  uint32 variantId;
  uint32 frames;
  bool opaque;
  bool fluid;
  bool solid;
  NoaBlockType blockType;
  bytes materials;
  string uvWrap;
}
