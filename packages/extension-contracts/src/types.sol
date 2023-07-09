// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { NoaBlockType } from "@tenet-contracts/src/codegen/types.sol";

// TODO: should not be duplicated from "@tenet-contracts
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
