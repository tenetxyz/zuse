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

// TODO: figure out if we actually want this to be async or if we should render something else in the meantime
setup().then((result) => {
  root.render(
    <MUDProvider value={result}>
      <App />
    </MUDProvider>
  );
  mountDevTools();
});
