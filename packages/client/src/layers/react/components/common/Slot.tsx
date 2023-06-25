import { Entity } from "@latticexyz/recs";
import React from "react";
import styled from "styled-components";
import { VoxelIcon } from "./VoxelIcon";
import { AbsoluteBorder } from "./AbsoluteBorder";
import { Border } from "./Border";
import { entityToVoxelType } from "../../../../utils/voxels";
import { VoxelVariantDataKey } from "../../../noa/types";

export const Slot: React.FC<{
  voxelType?: Entity;
  quantity?: number;
  onClick?: () => void;
  onRightClick?: () => void;
  selected?: boolean;
  disabled?: boolean;
  bgUrl?: string;
  getVoxelIconUrl: (voxelTypeKey: VoxelVariantDataKey) => string | undefined;
}> = ({ voxelType, quantity, onClick, onRightClick, selected, disabled, getVoxelIconUrl, bgUrl }) => {
  let usebgUrl = bgUrl ? bgUrl : "";
  const voxelVariantData = voxelType ? entityToVoxelType(voxelType) : undefined;
  if (usebgUrl == "" && voxelVariantData !== undefined) {
    usebgUrl = getVoxelIconUrl({
      voxelVariantNamespace: voxelVariantData.voxelVariantNamespace,
      voxelVariantId: voxelVariantData.voxelVariantId,
    }) || "";
  }
  return (<AbsoluteBorder
    borderColor={selected ? "#ffffff" : "transparent"}
    borderWidth={6}
  >
    <Border borderColor={"#b1b1b1"}>
      <Border borderColor={"#797979"}>
        <Border borderColor={"rgb(0 0 0 / 10%)"}>
          <Inner
            onClick={onClick}
            disabled={disabled}
            onContextMenu={(event: React.MouseEvent<HTMLDivElement>) => {
              event.preventDefault(); // Prevent the default browser context menu from showing up
              onRightClick && onRightClick();
            }}
          >
            {voxelType ? (
              <VoxelIcon bgUrl={usebgUrl} scale={4}>
                {quantity != null ? <Quantity>{quantity}</Quantity> : null}
              </VoxelIcon>
            ) : null}
          </Inner>
        </Border>
      </Border>
    </Border>
  </AbsoluteBorder>
  );
};

const Inner = styled.div<{ disabled?: boolean }>`
  width: 64px;
  height: 64px;
  display: grid;
  justify-items: center;
  align-items: center;
  font-size: 20px;
  opacity: ${(p) => (p.disabled ? 0.5 : 1)};
`;

const Quantity = styled.div`
  width: 100%;
  height: 100%;
  display: grid;
  justify-content: end;
  align-content: end;
  padding: 7px 3px;
`;
