import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./MUDContext";

export const App = () => {
  const {
    network: { singletonEntity },
  } = useMUD();

  return (
    <>
      <div>Basic CA Client</div>
    </>
  );
};
