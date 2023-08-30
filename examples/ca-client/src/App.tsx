import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./MUDContext";

export const App = () => {
  const {
    network: { worldId },
  } = useMUD();

  return (
    <>
      <div>Basic Client for World: {worldId}</div>
    </>
  );
};
