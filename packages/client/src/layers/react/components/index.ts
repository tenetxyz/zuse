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
import { registerTenetSidebar } from "./TenetSidebar";
import { registerBackgroundFade } from "./BackgroundFade";
import { registerSplashCard } from "./SplashCard";
import { registerPersistentSidebar } from "./PersistentSidebar";
import { registerZoomOverlay } from "./ZoomOverlay";
import { registerWorldMap } from "./WorldMap";
export * from "./common";

export function registerUIComponents() {
  registerCrosshairs();
  // registerBlockExplorer();
  registerInventoryHud();
  // registerSidebar();
  registerToast();
  registerPersistentNotifications();
  // TODO: Need to make sure plugin structure works with MUD2 before renabling
  // registerPlugins();

  clearTenetComponentRenderer();
  registerLoadingState();
  registerActionQueue();
  registerTenetSidebar();
  registerAdminPanel();
  registerBackgroundFade();
  registerPersistentSidebar();
  // registerSplashCard();
  registerZoomOverlay();
  // registerWorldMap();
}
