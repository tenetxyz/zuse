// This react hook returns a list of worlds that meet the user's filter criteria
// when searching through the creative inventory
import React, { useEffect } from "react";
import Fuse from "fuse.js";
import { useComponentUpdate } from "./useComponentUpdate";
import { ComponentRecord, Layers } from "../types";
import { WorldRegistryFilters, WorldDesc, CaDesc } from "../layers/react/components/WorldsRegistry";
import { Entity, getComponentValue } from "@latticexyz/recs";
import { onStreamUpdate } from "./stream";

export interface Props {
  layers: Layers;
  filters: WorldRegistryFilters;
}

export interface CreativeInventorySearch {
  worldsToDisplay: WorldDesc[];
}

export const useWorldRegistrySearch = ({ layers, filters }: Props) => {
  const {
    network: {
      registryComponents: { WorldRegistry, CARegistry },
    },
  } = layers;

  const allWorlds = React.useRef<WorldDesc[]>([]);
  const filteredWorlds = React.useRef<WorldDesc[]>([]); // Filtered based on the specified filters. The user's search box query does NOT affect this.
  const [worldsToDisplay, setWorldsToDisplay] = React.useState<WorldDesc[]>([]);
  const fuse = React.useRef<Fuse<WorldDesc>>();

  // PERF: this useComponentUpdate is triggered on every update. it means that we refetch EVERYTHING on each update.
  // we should only fetch once? or just read all the values of the component when we first load the page?
  useComponentUpdate(WorldRegistry, () => {
    const allWorldsInRegistry = [...WorldRegistry.entities()];
    const worlds = new Map<Entity, ComponentRecord<typeof WorldRegistry>>();
    for (const world of allWorldsInRegistry) {
      const worldRecord = getComponentValue(WorldRegistry, world);
      if (!worldRecord) {
        console.warn(`cannot find worldRecord for ${world}`);
        continue;
      }
      worlds.set(world, worldRecord);
    }
    allWorlds.current = Array.from(worlds.entries()).map(([world, worldRecord]) => {
      return {
        worldAddress: world,
        name: worldRecord.name,
        description: worldRecord.description,
        creator: worldRecord.creator,
      } as WorldDesc;
    });

    // TODO: sort allWorlds.current;

    // After we have parsed all the worlds, apply the world
    // filters to narrow down the worlds that will be displayed.
    applyFilters();
  });

  const applyFilters = () => {
    // TODO: add filters for the serach
    filteredWorlds.current = allWorlds.current;
    // TODO: add a sort function to sort by namespace
    const options = {
      isCaseSensitive: false,
      includeScore: false,
      shouldSort: true,
      keys: ["name"],
      threshold: 0.3,
    };

    fuse.current = new Fuse(filteredWorlds.current, options);
    queryForWorldsToDisplay();
  };
  // recalculate which worlds are in the display pool when the filters change
  useEffect(applyFilters, [filters]);

  const queryForWorldsToDisplay = () => {
    if (!fuse.current) {
      return;
    }

    if (filters.query === "") {
      setWorldsToDisplay(filteredWorlds.current);
      return;
    }

    const queryResult = fuse.current.search(filters.query).map((r) => r.item);
    setWorldsToDisplay(queryResult);
  };
  React.useEffect(queryForWorldsToDisplay, [filters.query]);

  return {
    worldsToDisplay,
  };
};
