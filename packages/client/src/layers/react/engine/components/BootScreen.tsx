import React, { ReactNode, useEffect, useState } from "react";
import styled from "styled-components";

export const BootScreen: React.FC<{ initialOpacity?: number; children: ReactNode }> = ({
  children,
  initialOpacity,
}: any) => {
  const [opacity, setOpacity] = useState(initialOpacity ?? 0);

  useEffect(() => setOpacity(0.35), []);

  return (
    <Container>
      <img
        src="/img/loading-background.jpeg"
        style={{ opacity, width: "100%", height: "100%", position: "absolute", objectFit: "cover" }}
      ></img>
      <LoadingMsgContainer>
        <div className="font-inter text-9xl opacity-100 text-white w-full h-full font-bold">EVERLON</div>
        <>{children || <>&nbsp;</>}</>
      </LoadingMsgContainer>
    </Container>
  );
};

const LoadingMsgContainer = styled.div`
  position: relative;
  width: 100%;
  height: 100%;
  padding-top: 30px;
  padding-left: 30px;
  padding-right: 30px;
  padding-bottom: 22px;
  color: white;
`;

const Container = styled.div`
  width: 100%;
  height: 100%;
  position: absolute;
  background-color: rgb(0 0 0 / 100%);
  display: grid;
  align-content: center;
  align-items: center;
  justify-content: center;
  justify-items: center;
  transition: all 2s ease;
  grid-gap: 50px;
  z-index: 100;
  pointer-events: none;

  div {
    font-family: "Lattice Pixel", sans-serif;
  }

  img {
    transition: all 2s ease;
    width: 100px;
  }
`;
