import { Container, Red } from "./common";
import React, { useEffect, useState } from "react";
import styled from "styled-components";
import { registerUIComponent } from "../engine";
import { concat, distinctUntilChanged, map, of } from "rxjs";
import { IPersistentNotification, NotificationIcon } from "../../noa/components/persistentNotification";
import { setComponent } from "@latticexyz/recs";

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
        noa: {
          components: { PersistentNotification },
          SingletonEntity,
        },
      } = layers;
      const balance$ = balanceGwei$.pipe(distinctUntilChanged());
      const notification$ = concat(
        of({ message: "", icon: NotificationIcon.NONE }),
        PersistentNotification.update$.pipe(
          map((notificationUpdate) => ({
            message: notificationUpdate.value[0]?.message,
            icon: notificationUpdate.value[0]?.icon,
          }))
        )
      );

      return of({
        balance$,
        notification$,
        PersistentNotification,
        SingletonEntity,
      });
    },
    (props) => {
      const { balance$, notification$, PersistentNotification, SingletonEntity } = props;
      const [notification, setNotification] = useState<IPersistentNotification | null>(null);

      useEffect(() => {
        // this is the main piece of code that will listen for new notifications and update this component
        notification$.subscribe((notification) => {
          if (notification.message !== "") {
            setNotification({
              message: notification.message ?? "",
              icon: notification.icon ?? NotificationIcon.NONE,
            });
          } else {
            setNotification(null);
          }
        });

        balance$.subscribe((balance) => {
          if (balance === 0) {
            setComponent(PersistentNotification, SingletonEntity, {
              message: " you need to request a drip before you can mine or build (top right).",
              icon: NotificationIcon.CROSS,
            });
          }
        });
      }, []);

      const getNotificationIcon = (icon: NotificationIcon): React.ReactNode => {
        switch (icon) {
          case NotificationIcon.NONE:
            return <></>;
          case NotificationIcon.CROSS:
            return <Red>X</Red>;
        }
      };

      return (
        <>
          {notification && (
            <NotificationWrapper>
              <Container>
                <div className="w-full text-center">
                  {getNotificationIcon(notification.icon)} {notification.message}
                </div>
              </Container>
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
