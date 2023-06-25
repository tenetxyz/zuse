import { Entity } from "@latticexyz/recs";
import styled from "styled-components";

export const VoxelIcon = styled.div<{ iconUrl: string; scale: number }>`
  width: ${(p) => 16 * p.scale}px;
  height: ${(p) => 16 * p.scale}px;
  background-image: url("${(p) => p.iconUrl}");
  background-size: 100%;
  image-rendering: pixelated;
  display: grid;
  justify-items: center;
  align-items: center;
  font-size: 20px;
`;
