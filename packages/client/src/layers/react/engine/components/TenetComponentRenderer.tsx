import { Layers } from "../../../../types";
import { Cell } from "./Cell";

interface Props {
  rowStart: number;
  rowEnd: number;
  columnStart: number;
  columnEnd: number;
  Component: React.ElementType<ComponentRendererProps>;
}

let tenetComponents: Props[] = [];
export const clearTenetComponentRenderer = () => {
  tenetComponents = [];
};
export const registerTenetComponent = (props: Props) => {
  tenetComponents.push(props);
};

interface ComponentRendererProps {
  layers: Layers;
}
export const TenetComponentRenderer = ({ layers }: ComponentRendererProps) => {
  return (
    <>
      {tenetComponents.map((props: Props, idx: number) => {
        return (
          <Cell
            key={`tenetComponentRenderer-idx-${idx}`}
            style={{
              gridRowStart: props.rowStart,
              gridRowEnd: props.rowEnd,
              gridColumnStart: props.columnStart,
              gridColumnEnd: props.columnEnd,
            }}
          >
            <props.Component layers={layers} />
          </Cell>
        );
      })}
    </>
  );
};
