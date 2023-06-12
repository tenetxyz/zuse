import { Container, Red } from "./common";
import React, { useEffect, useState } from "react";
import styled from "styled-components";
import { registerUIComponent } from "../engine";
import { distinctUntilChanged, of } from "rxjs";

export function registerPersistentNotifications() {
  registerUIComponent(
    "PersistentNotifications",
    {
      rowStart: 10,
      rowEnd: 13,
      colStart: 4,
      colEnd: 10,
    },
    (layers) => {
      const {
        network: {
          streams: { balanceGwei$ },
        },
      } = layers;
      const balance$ = balanceGwei$.pipe(distinctUntilChanged());

      return of({ balance$ });
    },
    (props) => {
      const { balance$ } = props;
      const [notificationElement, setNotificationElement] =
        useState<React.ReactNode | null>(null);

      useEffect(() => {
        balance$.subscribe((balance) => {
          if (balance === 0) {
            setNotificationElement(
              <>
                <Red>X</Red> you need to request a drip before you can mine or
                build (top right).
              </>
            );
          }
        });
      }, []);

      return (
        <>
          {notificationElement && (
            <NotificationWrapper>
              <Container>{notificationElement}</Container>
            </NotificationWrapper>
          )}
        </>
      );
    }
  );
}

const NotificationWrapper = styled.div`
  position: absolute;
  bottom: 100px;
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
