import { SetupNetworkResult } from "./setupNetwork";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls({ worldContract, waitForTransaction }: SetupNetworkResult) {
  return {};
}
