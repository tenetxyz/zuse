import { Entity } from "@latticexyz/recs";
import styled from "styled-components";
import { VoxelTypeIdToKey } from "../../../network/constants";
import { getVoxelIconUrl } from "../../../noa/constants";

export const VoxelIcon = styled.div<{ voxelType: Entity; scale: number }>`
  width: ${(p) => 16 * p.scale}px;
  height: ${(p) => 16 * p.scale}px;
  background-image: url("${(p) =>
    getVoxelIconUrl(VoxelTypeIdToKey[p.voxelType]) ?? ""}");
  background-size: 100%;
  image-rendering: pixelated;
  display: grid;
  justify-items: center;
  align-items: center;
  font-size: 20px;
`;
