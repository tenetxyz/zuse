import { registerActionQueue } from "./ActionQueue";
import { registerCrosshairs } from "./Crosshairs";
import { registerLoadingState } from "./LoadingState";
import { registerBlockExplorer } from "./BlockExplorer";
import { registerInventory } from "./Inventory";
import { registerSidebar } from "./Sidebar";
import { registerPlugins } from "./Plugins";
export * from "./common";

export function registerUIComponents() {
  registerLoadingState();
  registerActionQueue();
  registerCrosshairs();
  registerBlockExplorer();
  registerInventory();
  registerSidebar();
  // TODO: Need to make sure plugin structure works with MUD2 before renabling
  // registerPlugins();
}
