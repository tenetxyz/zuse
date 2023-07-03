// This was generated from this chat:https://chat.openai.com/share/b05a54b3-c8d9-4a38-bdd8-a8a77c17f212
import React, { useEffect, useState } from "react";
import styled from "styled-components";

interface SlidingBarContainerProps {
  color: string;
}

const SlidingBarContainer = styled.div<SlidingBarContainerProps>`
  width: 100%;
  height: 20px;
  background-color: #e0e0e0;
  overflow: hidden;
`;

interface SlidingBarProps {
  width: number;
  color: string;
  barFloatLeft: boolean;
}

const SlidingBar = styled.div<SlidingBarProps>`
  height: 100%;
  background-color: ${(props) => props.color};
  transition: width 0.5s ease-in-out;
  width: ${(props) => props.width}%;
  position: relative;
  float: ${(props) => (props.barFloatLeft ? "left" : "right")};
`;

const BarText = styled.span<{ barFloatLeft: boolean }>`
  position: absolute;
  top: 50%;
  ${(props) => (props.barFloatLeft ? "left: 10%;" : "right: 10%;")}
  transform: translate(0, -55%);
  color: #ffffff;
  font-weight: bold;
`;

interface Props {
  percentage: number;
  color: string;
  text: string;
  barFloatLeft: boolean;
}

const Bar: React.FC<Props> = ({ percentage, color, text, barFloatLeft }) => {
  const [slideWidth, setSlideWidth] = useState(0);

  useEffect(() => {
    setSlideWidth(percentage);
  }, [percentage]);

  return (
    <SlidingBarContainer color={color}>
      <SlidingBar width={slideWidth} color={color} barFloatLeft={barFloatLeft}>
        <BarText barFloatLeft={barFloatLeft}>{text}</BarText>
      </SlidingBar>
    </SlidingBarContainer>
  );
};

export default Bar;
