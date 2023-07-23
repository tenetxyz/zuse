import { Layers } from "../../../types";
import { SearchBar } from "./common/SearchBar";

export interface WorldRegistryFilters {
  query: string;
}
export interface WorldDesc {
  name: string;
  deployer: string;
}

export const WorldRegistry = (layers: Layers) => {
    return (
    <div className="flex flex-col p-4">
      <div className="flex w-full">
        <SearchBar value={filters.query} onChange={(e) => setFilters({ ...filters, query: e.target.value })} />
      </div>
      {/* <div className="flex w-full mt-5 justify-center items-center">
        <ActionBarWrapper>{[...range(NUM_COLS * NUM_ROWS)].map((i) => Slots[i])}</ActionBarWrapper>
      </div> */}
    </div>
    )
});