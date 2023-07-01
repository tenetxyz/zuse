import { Component, ComponentValue, Schema, SchemaOf } from "@latticexyz/recs";
import { ecs } from "./boot";
import { NetworkLayer } from "./layers/network";
import { NoaLayer } from "./layers/noa";

export type Layers = { network: NetworkLayer; noa: NoaLayer };
export type Window = typeof window & {
  layers: Layers;
  ecs: typeof ecs;
  remountReact: () => Promise<void>;
};
export type ComponentRecord<C extends Component<Schema>> = ComponentValue<SchemaOf<C>>;
