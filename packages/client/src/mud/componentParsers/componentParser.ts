import { Component, ComponentUpdate, createWorld, Entity, isComponentUpdate, Metadata, Schema } from "@latticexyz/recs";
import { useEffect } from "react";
import { Subject } from "rxjs";
import { parseCreation } from "./creation";
import { parseVoxelType } from "./voxelType";
import { parseSpawn } from "./spawn";

export interface WorldMetadata {
  worldAddress: string;
}

export type ComponentParser<ComponentRecord> = {
  updateStream$: Subject<ComponentRecord | undefined>;
  componentRows: Map<Entity, ComponentRecord>;
  getRecordStrict: (entityId: Entity) => ComponentRecord;
};

export function setupComponentParsers(
  world: Awaited<ReturnType<typeof createWorld>>,
  registryResult: any,
  result: any,
  worldAddress: string
) {
  const worldMetadata = {
    worldAddress: worldAddress,
  } as WorldMetadata;

  const ParsedCreationRegistry = setupComponentParser(
    world,
    registryResult.components.CreationRegistry,
    parseCreation,
    worldMetadata,
    "ParsedCreationRegistry"
  );

  const ParsedVoxelTypeRegistry = setupComponentParser(
    world,
    registryResult.components.VoxelTypeRegistry,
    parseVoxelType,
    worldMetadata,
    "ParsedVoxelTypeRegistry"
  );

  const ParsedSpawn = setupComponentParser(world, result.components.Spawn, parseSpawn, worldMetadata, "Spawn");

  return {
    ParsedCreationRegistry,
    ParsedVoxelTypeRegistry,
    ParsedSpawn,
  };
}

// This function returns a componentParser, which contains information about
// component updates. Why can't we just read these updates from the Components in recs?
// Cause some components have fields that are encoded (e.g. in bytes). We need to parse these fields!
function setupComponentParser<S extends Schema, ComponentRecord>(
  world: Awaited<ReturnType<typeof createWorld>>,
  component: Component<S, Metadata, undefined>,
  parseComponent: (
    update: ComponentUpdate<S, undefined>,
    worldMetadata: WorldMetadata
  ) =>
    | {
        entityId: Entity;
        componentRecord: ComponentRecord;
      }
    | undefined,
  worldMetadata: WorldMetadata,
  parserName: string
): ComponentParser<ComponentRecord> {
  const updateStream$ = new Subject<ComponentRecord | undefined>();
  const componentRows = new Map<Entity, ComponentRecord>();

  const subscription = component.update$.subscribe((update) => {
    if (isComponentUpdate(update, component)) {
      // if this is a delete update
      if (update.value[0] === undefined) {
        componentRows.delete(update.entity);
        updateStream$.next(undefined);
        return;
      }

      const result = parseComponent(update, worldMetadata);
      if (result === undefined) {
        console.warn("cannot parse entity", update.entity);
        return;
      }

      const { entityId, componentRecord } = result;
      componentRows.set(entityId, componentRecord);
      updateStream$.next(componentRecord);
    }
  });
  world.registerDisposer(() => subscription.unsubscribe());

  const getRecordStrict = (entityId: Entity): ComponentRecord => {
    const record = componentRows.get(entityId);
    if (record === undefined) {
      throw `[${parserName}] cannot getRecordStrict for entityId=${entityId}`;
    }
    return record;
  };

  const parsedComponent = {
    updateStream$,
    componentRows,
    getRecordStrict,
  };
  return parsedComponent;
}

// Runs a function whenever a component/table receives update
export function useParsedComponentUpdate<ComponentRecord>(
  componentParser: ComponentParser<ComponentRecord>,
  // TODO: figure out how do I represent a delete update?
  onComponentUpdate: (update: ComponentRecord | undefined, componentRows: Map<Entity, ComponentRecord>) => void,
  callEmptyUpdateOnInit: boolean // some react components use this so when the component is initialized, they can show all the values
): void {
  useEffect(() => {
    const subscription = componentParser.updateStream$.subscribe((update) => {
      onComponentUpdate(update, componentParser.componentRows);
    });

    if (callEmptyUpdateOnInit) {
      onComponentUpdate(undefined, componentParser.componentRows);
    }
    return () => subscription.unsubscribe();
  }, [componentParser]);
}
