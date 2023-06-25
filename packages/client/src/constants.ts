import { toUtf8Bytes } from "ethers/lib/utils.js";
import { BigNumber } from "ethers";

export enum Direction {
  Top,
  Right,
  Bottom,
  Left,
}

export const Directions = {
  [Direction.Top]: { x: 0, y: -1 },
  [Direction.Right]: { x: 1, y: 0 },
  [Direction.Bottom]: { x: 0, y: 1 },
  [Direction.Left]: { x: -1, y: 0 },
};

export const CHUNK = 16;

function formatNamespace(namespace: string) {
  if(namespace.length < 34)  {
    return namespace + "0".repeat(34 - namespace.length);
  } else {
    return namespace.substring(0, 34);
  }
}

export const TENET_NAMESPACE = formatNamespace(BigNumber.from((toUtf8Bytes("tenet"))).toHexString());

// pad TENET_NAMESPACE with 0's so that its of length 32