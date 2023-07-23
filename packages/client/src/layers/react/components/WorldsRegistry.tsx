import { Layers } from "../../../types";
import { useWorldRegistrySearch } from "../../../utils/useWorldRegistrySearch";
import { SearchBar } from "./common/SearchBar";

export interface WorldRegistryFilters {
  query: string;
}
export interface WorldDesc {
  name: string;
  deployer: string;
}

interface Props {
  layers: Layers;
  filters: WorldRegistryFilters;
  setFilters: React.Dispatch<React.SetStateAction<WorldRegistryFilters>>;
}

export const WorldRegistry = ({ layers, filters, setFilters }: Props) => {
  const { worldsToDisplay } = useWorldRegistrySearch({ layers, filters });
  return (
    <div className="flex flex-col p-4">
      <div className="flex w-full">
        <SearchBar value={filters.query} onChange={(e) => setFilters({ ...filters, query: e.target.value })} />
      </div>
      {worldsToDisplay.map((world) => {
        return (
          <div>
            <p>{world.name}</p>
          </div>
        );
      })}
    </div>
  );
};
