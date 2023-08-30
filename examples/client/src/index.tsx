import ReactDOM from "react-dom/client";
import { mount as mountDevTools } from "@latticexyz/dev-tools";
import { App } from "./App";
import { setup } from "./mud/setup";
import { MUDProvider } from "./MUDContext";
import "@fontsource/fira-sans";
import { BootScreen } from "./layers/react/engine";

const rootElement = document.getElementById("react-root");
if (!rootElement) throw new Error("React root not found");
const root = ReactDOM.createRoot(rootElement);
root.render(
  <BootScreen initialOpacity={1}>
    <span className="text-white">Connecting</span>
  </BootScreen>
);
const params = new URLSearchParams(window.location.search);
const shouldMountDevTools = params.get("mountDevTools");

// TODO: figure out if we actually want this to be async or if we should render something else in the meantime
setup().then((result) => {
  root.render(
    <MUDProvider value={result}>
      <App />
    </MUDProvider>
  );
  if (shouldMountDevTools) {
    mountDevTools({
      config: result.network.storeConfig,
      publicClient: result.network.publicClient,
      walletClient: result.network.walletClient,
      latestBlock$: result.network.latestBlock$,
      blockStorageOperations$: result.network.blockStorageOperations$,
      worldAddress: result.network.worldContract.address,
      worldAbi: result.network.worldContract.abi,
      write$: result.network.write$,
      recsWorld: result.network.world,
    });
  }
});
