import { BaseCreation } from "../layers/noa/systems/createSpawnOverlaySystem";
import { Creation } from "../layers/react/components/CreationStore";
import { defaultAbiCoder as abi } from "ethers/lib/utils";

export const hexToAscii = (hexString: string): string => {
  let asciiString = "";
  for (let i = 0; i < hexString.length; i += 2) {
    asciiString += String.fromCharCode(parseInt(hexString.substr(i, 2), 16));
  }
  return asciiString;
};

export function removeTrailingNulls(input: string): string {
  // Using regex, we find all occurrences of '\u0000' at the end of the string and replace them with ''
  return input.replace(/\u0000+$/, "");
}

// this is like JSON.stringify but for bigints
// from https://github.com/latticexyz/mud/blob/73e200cc8bc2e28aa927637a0cbd55b71c1608a1/packages/dev-tools/src/tables/Table.tsx#L53
export function serializeWithoutIndexedValues(obj: any) {
  return JSON.stringify(obj, (key, value) => {
    // strip indexed values
    if (/^\d+$/.test(key)) {
      return;
    }
    // serialize bigints as strings
    if (typeof value === "bigint") {
      return value.toString();
    }
    return value;
  });
}

export const decodeBaseCreations = (baseCreations: string): BaseCreation[] => {
  return abiDecode(
    "tuple(bytes32 creationId,tuple(int32 x,int32 y,int32 z) coordOffset,tuple(int32 x,int32 y,int32 z)[] deletedRelativeCoords)[]",
    baseCreations
  ) as BaseCreation[];
};

export function abiDecode(encodedType: string, encodedBytes: string, clean = true) {
  if (encodedBytes === undefined || encodedBytes === null || encodedBytes.length === 0 || encodedBytes === "0x")
    return undefined;

  try {
    const isArray = encodedType.endsWith("[]");
    const decodedData = abi.decode([encodedType], encodedBytes)[0];
    if (isArray) {
      return clean ? cleanObjArray(decodedData) : decodedData;
    } else {
      return clean ? cleanObj(decodedData) : decodedData;
    }
  } catch (e) {
    console.error("Error decoding materials");
    console.error(e);
  }
  return undefined;
}

export function cleanObj(obj: any): any {
  const cleanedObj: any = {};
  for (const [key, val] of Object.entries(obj)) {
    // check if key string is an integer
    if (isNaN(parseInt(key))) {
      cleanedObj[key] = val;
    }
  }
  return cleanedObj;
}

export function cleanObjArray(objArray: any[]): any[] {
  const cleanedArray: any[] = [];
  for (const obj of objArray) {
    cleanedArray.push(cleanObj(obj));
  }
  return cleanedArray;
}
