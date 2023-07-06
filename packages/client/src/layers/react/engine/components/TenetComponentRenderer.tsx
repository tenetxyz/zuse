import { Layers } from "../../../../types";
import { Cell } from "./Cell";

interface Props {
  name: string;
  rowStart: number;
  rowEnd: number;
  columnStart: number;
  columnEnd: number;
  Component: React.ElementType<ComponentRendererProps>;
}

const tenetComponents = new Map<string, Props>();
export const clearTenetComponentRenderer = () => {
  tenetComponents.clear();
};
export const registerTenetComponent = (props: Props) => {
  tenetComponents.set(props.name, props);
};

interface ComponentRendererProps {
  layers: Layers;
}
export const NewComponentRenderer = ({ layers }: ComponentRendererProps) => {
  console.log("new compoennt renderer rerender");
  return (
    <>
      {Array.from(tenetComponents.values()).map((props: Props, idx: number) => {
        return (
          <Cell
            key={`componentRenderer-idx-${idx}`}
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
