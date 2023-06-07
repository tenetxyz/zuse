import { Container, Gold, Red } from "./common";
import React from "react";
import styled from "styled-components";
import { ComponentValue, Type } from "@latticexyz/recs";

interface Props {
  claim:
    | ComponentValue<{ stake: Type.Number; claimer: Type.String }, undefined>
    | undefined;
  balance: number;
}
// TODO: register these components as it's own ui component
export const UrgentNotification: React.FC<Props> = ({ claim, balance }) => {
  const claimer = "todo: remove claiming";
  const canBuild = true;

  const notification =
    balance === 0 ? (
      <>
        <Red>X</Red> you need to request a drip before you can mine or build
        (top right).
      </>
    ) : claim && !canBuild ? (
      <>
        <Red>X</Red> you cannot build or mine here. This chunk has been claimed
        by <Gold>{claimer}</Gold>
      </>
    ) : claim && canBuild ? (
      <>
        <Gold>You control this chunk!</Gold>
      </>
    ) : null;

  return (
    <>
      {notification && (
        <NotificationWrapper>
          <Container>{notification}</Container>
        </NotificationWrapper>
      )}
    </>
  );
};

const NotificationWrapper = styled.div`
  position: absolute;
  top: -25px;
  transform: translate(-50%, -100%);
  left: 50%;
  line-height: 100%;
`;

const Notification = styled.p`
  position: absolute;
  top: -25px;
  width: 100%;
  text-align: center;
`;
