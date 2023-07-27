import { Entity } from "@latticexyz/recs";
import React from "react";
import styled from "styled-components";
import { VoxelIcon } from "./VoxelIcon";
import { AbsoluteBorder } from "./AbsoluteBorder";
import { Border } from "./Border";

export const Slot: React.FC<{
  voxelType?: Entity;
  quantity?: number;
  onClick?: (event: React.MouseEvent<HTMLDivElement>) => void;
  onRightClick?: () => void;
  selected?: boolean;
  disabled?: boolean;
  iconUrl?: string;
  tooltipText?: React.ReactNode;
  slotSize?: string;
}> = ({ voxelType, quantity, onClick, onRightClick, selected, disabled, iconUrl, tooltipText, slotSize }) => {
  return (
    <AbsoluteBorder borderColor={"transparent"} borderWidth={2}>
      <TooltipContainer>
        {/* <Border borderColor={"transparent"}>
          <Border borderColor={"transparent"}> */}
            <Border borderColor={"transparent"}>
              <Inner
                onClick={onClick}
                disabled={false}
                selected={selected}
                onContextMenu={(event: React.MouseEvent<HTMLDivElement>) => {
                  event.preventDefault(); // Prevent the default browser context menu from showing up
                  onRightClick && onRightClick();
                }}
                slotSize={slotSize || "64px"}
              >
                {voxelType ? (
                  <VoxelIcon iconUrl={iconUrl ? iconUrl : ""} scale={4}>
                    {quantity !== null ? <Quantity>{quantity}</Quantity> : null}
                  </VoxelIcon>
                ) : null}
              </Inner>
            </Border>
          {/* </Border>
        </Border> */}
        {tooltipText !== undefined && <TooltipText>{tooltipText}</TooltipText>}
      </TooltipContainer>
    </AbsoluteBorder>
  );
};

const Inner = styled.div<{ disabled?: boolean; slotSize: string; selected?: boolean }>`
  width: ${(p) => p.slotSize};
  height: ${(p) => p.slotSize};
  overflow: hidden;
  display: grid;
  justify-content: center;
  align-content: center;
  font-size: 20px;
  opacity: ${(p) => (p.disabled ? 0.5 : 1)};
  border: 2px solid #374147;
  background-color: rgba(36, 42, 47, 0.8);43
  border-radius: 4px;
  transition: box-shadow 0.3s ease;
  box-shadow: ${(p) => p.selected ? '#C9CACB 0px 0px 20px 5px' : 'none'};
  &:hover {
    box-shadow: 0 2px 5px 0 rgba(0, 0, 0, 0.1);
  }
`;






const Quantity = styled.div`
  width: 100%;
  height: 100%;
  display: grid;
  justify-content: end;
  align-content: end;
  padding: 8px 6px;
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
  // border-bottom: 1px dotted black;

  &:hover ${TooltipText} {
    visibility: visible;
    opacity: 1;
  }
`;
