import { TxQueue } from "@latticexyz/network";
import { Component, ComponentValue, defineComponent, Entity, Schema, Type, World } from "@latticexyz/recs";
import { keccak256 } from "@latticexyz/utils";
import { BigNumber } from "ethers";
import { createBrowserDevComponents } from "@latticexyz/ecs-browser/src/createBrowserDevComponents";

export function setupDevSystems(
  world: World,
) {
  // const DevHighlightComponent = defineComponent(world, { value: Type.OptionalNumber });
  //
  // const HoverHighlightComponent = defineComponent(world, {
  //   x: Type.OptionalNumber,
  //   y: Type.OptionalNumber,
  // });
  //
  async function setContractComponentValue<T extends Schema>(
    entity: Entity,
    component: Component<T, { contractId: string }>,
    newValue: ComponentValue<T>
  ) {
    if (!component.metadata.contractId)
      throw new Error(
        `Attempted to set the contract value of Component ${component.id} without a deployed contract backing it.`
      );
    // const encoders = await encodersPromise;
    // const data = encoders[keccak256(component.metadata.contractId)](newValue);
    console.log(`Sent transaction to edit networked Component ${component.id} for Entity ${entity}`);
    await systems["ember.system.componentDev"].executeTyped(
      keccak256(component.metadata.contractId),
      BigNumber.from(entity),
      data
    );
  }
  const {devHighlightComponent, hoverHighlightComponent} =  createBrowserDevComponents(world);

  return { setContractComponentValue, DevHighlightComponent: devHighlightComponent, HoverHighlightComponent: hoverHighlightComponent };
}
