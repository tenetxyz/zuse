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

export const jsonStringifyWithBigInt = (obj: object): string => {
  return JSON.stringify(obj, (key, value) => {
    if (typeof value === "bigint") {
      return value.toString(); // Convert BigInt to string
    }
    return value;
  });
};
