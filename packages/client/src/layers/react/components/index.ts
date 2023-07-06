import { registerActionQueue } from "./ActionQueue";
import { registerCrosshairs } from "./Crosshairs";
import { registerLoadingState } from "./LoadingState";
import { registerBlockExplorer } from "./BlockExplorer";
import { registerInventoryHud } from "./InventoryHud";
import { registerSidebar } from "./Sidebar";
import { registerPlugins } from "./Plugins";
import { registerToast } from "./Toast";
import { registerAdminPanel } from "./AdminPanel";
import { registerPersistentNotifications } from "./PersistentNotification";
import { clearTenetComponentRenderer } from "../engine/components/TenetComponentRenderer";
import { registerTenetSidebar } from "../TenetSidebar";
export * from "./common";

export function registerUIComponents() {
  registerLoadingState();
  registerActionQueue();
  registerCrosshairs();
  registerBlockExplorer();
  registerInventoryHud();
  registerSidebar();
  registerToast();
  registerPersistentNotifications();
  // TODO: Need to make sure plugin structure works with MUD2 before renabling
  // registerPlugins();

  clearTenetComponentRenderer();
  registerAdminPanel();
  registerTenetSidebar();
}
