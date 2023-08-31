import { defineComponent, Type, World } from "@latticexyz/recs";

export const enum NotificationIcon {
  NONE,
  CROSS,
}

export interface IPersistentNotification {
  message: string;
  icon: NotificationIcon;
}

export function definePersistentNotificationComponent(world: World) {
  return defineComponent(world, { message: Type.String, icon: Type.Number }, { id: "PersistentNotification" });
}
