import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./MUDContext";
import {Engine} from "./layers/react/engine";

export const App = () => {
  const {
    game: { layers },
  } = useMUD();

  return (
    <>
      <Engine layers={layers} />
    </>
  );
};
