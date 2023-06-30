import { defaultAbiCoder as abi } from "ethers/lib/utils";

export function abiDecode(encodedType: string, encodedBytes: string) {
  if (encodedBytes === undefined || encodedBytes === null || encodedBytes.length === 0 || encodedBytes === "0x")
    return undefined;

  try {
    const decodedData = abi.decode([encodedType], encodedBytes)[0];
    return decodedData;
  } catch (e) {
    console.error("Error decoding materials");
    console.error(e);
  }
  return undefined;
}
