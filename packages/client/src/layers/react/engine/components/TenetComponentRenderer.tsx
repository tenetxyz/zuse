import { Layers } from "../../../../types";
import { useLayers } from "../hooks/useLayers";
import { Cell } from "./Cell";

interface Props {
  name: string;
  gridRowStart: number;
  gridRowEnd: number;
  gridColumnStart: number;
  gridColumnEnd: number;
  Component: React.ElementType;
}

const tenetComponents = new Map<string, React.ReactNode>();
export const clearTenetComponentRenderer = () => {
  tenetComponents.clear();
};
export const registerTenetComponent = ({
  name,
  gridRowStart,
  gridRowEnd,
  gridColumnStart,
  gridColumnEnd,
  Component,
}: Props) => {
  const layers = useLayers();
  tenetComponents.set(
    name,
    <Cell
      style={{
        gridRowStart,
        gridRowEnd,
        gridColumnStart,
        gridColumnEnd,
      }}
    >
      <Component layers={layers} />
    </Cell>
  );
};

export const NewComponentRenderer = ({ layers: Layers }) => {
  return <>{tenetComponents.values()}</>;
};
