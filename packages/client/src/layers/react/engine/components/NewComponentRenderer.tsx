import { Cell } from "./Cell";

export const registerNewComponent = () => {};

export const NewComponentRenderer = () => {
  return (
    <Cell
      style={{
        gridRowStart: rowStart,
        gridRowEnd: rowEnd,
        gridColumnStart: colStart,
        gridColumnEnd: colEnd,
      }}
    >
      {children}
    </Cell>
  );
};
