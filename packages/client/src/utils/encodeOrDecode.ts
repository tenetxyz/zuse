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
