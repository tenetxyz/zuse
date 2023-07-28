import { Entity } from "@latticexyz/recs";
import { BigNumber } from "ethers";
// this function was originally from import { formatEntityID } from "@latticexyz/network";
// I derived it by looking at the definition in the opcraft repo (it was there in mud1)
export const formatEntityID = (entityID: string) => {
  if (BigNumber.isBigNumber(entityID) || entityID.substring(0, 2) === "0x") {
    return BigNumber.from(entityID).toHexString();
  }
  return entityID;
};

// we need to convert the address to a 64 char-long hex string (256 bits) when doing a query
// since queries look for 0x0000002kj32klj4, but this string won't match the address if we pass just the rightmost 42 chars of the eth address
// since a hex value takes 4 bits to represent, the final address is 64 characters long
export const to64CharAddress = (hexAddress: string | undefined) => {
  if (!hexAddress) {
    console.error("trying to run a query on an undefined address");
    return "";
  }
  const addressWithout0x = hexAddress.substring(2);
  return "0x" + addressWithout0x.padStart(64, "0");
};

// same as above, but 40 chars. Useful for converting uint256 to an address
export const to40CharAddress = (hexAddress: string | undefined) => {
  if (!hexAddress) {
    console.error("trying to run a query on an undefined address");
    return "";
  }
  const rightmostChars = hexAddress.slice(-40);
  return "0x" + rightmostChars.padStart(40, "0");
};

// this is mainly for documentation so ppl know the internal representation
// also so people will look this up and see the other definitions in this file
// Notice how we're using the wrapper object String not string
export const stringToEntity = (str: String): Entity => {
  return str as Entity;
};
