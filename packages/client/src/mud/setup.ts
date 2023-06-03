import { createClientComponents } from "./createClientComponents";
import { createSystemCalls } from "./createSystemCalls";
import { setupNetwork } from "./setupNetwork";
import {boot} from "../boot";

export type SetupResult = Awaited<ReturnType<typeof setup>>;

export async function setup() {
  console.log("Starting setup");
  const network = await setupNetwork();
  console.log("Finished setup network");
  const components = createClientComponents(network);
  // Give components a Human-readable ID
  Object.entries(components).forEach(([name, component]) => {
    component.id = name;
  });
  console.log("Finished setup components");
  const systemCalls = createSystemCalls(network, components);
  console.log("Finished setup system calls");
  const game = await boot(network);
  console.log("Finished setup");

  return {
    network,
    components,
    systemCalls,
    game,
  };
}
