import { defaultAbiCoder as abi } from "ethers/lib/utils";

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
