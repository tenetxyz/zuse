import { Entity } from "@latticexyz/recs";
import React from "react";
import styled from "styled-components";
import { VoxelIcon } from "./VoxelIcon";
import { AbsoluteBorder } from "./AbsoluteBorder";
import { Border } from "./Border";
import { VoxelVariantDataKey, entityToVoxelType } from "../../../noa/types";

export const Slot: React.FC<{
  voxelType?: Entity;
  quantity?: number;
  onClick?: (event: React.MouseEvent<HTMLDivElement>) => void;
  onRightClick?: () => void;
  selected?: boolean;
  disabled?: boolean;
  iconUrl?: string;
  tooltipText?: React.ReactNode;
}> = ({ voxelType, quantity, onClick, onRightClick, selected, disabled, iconUrl, tooltipText }) => {
  return (
    <AbsoluteBorder borderColor={selected ? "#ffffff" : "transparent"} borderWidth={6}>
      <TooltipContainer>
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
                  <VoxelIcon iconUrl={iconUrl ? iconUrl : ""} scale={4}>
                    {quantity !== null ? <Quantity>{quantity}</Quantity> : null}
                  </VoxelIcon>
                ) : null}
              </Inner>
            </Border>
          </Border>
        </Border>
        {tooltipText !== undefined && <TooltipText>{tooltipText}</TooltipText>}
      </TooltipContainer>
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
  user-select: none;
`;

const TooltipText = styled.div`
  visibility: hidden;
  width: 120px;
  background-color: #555;
  color: #fff;
  text-align: center;
  padding: 5px 0;
  border-radius: 6px;

  /* Position the tooltip text */
  position: absolute;
  z-index: 1;
  bottom: 100%;
  left: 50%;
  margin-left: -60px;

  /* Fade in tooltip */
  opacity: 0;
  transition: opacity 0.1s;

  &::after {
    content: "";
    position: absolute;
    top: 100%;
    left: 50%;
    margin-left: -5px;
    border-width: 5px;
    border-style: solid;
    border-color: #555 transparent transparent transparent;
  }
`;

const TooltipContainer = styled.div`
  position: relative;
  display: inline-block;
  border-bottom: 1px dotted black;

  &:hover ${TooltipText} {
    visibility: visible;
    opacity: 1;
  }
`;
