import styled from "styled-components";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { useComponentValue } from "@latticexyz/react";

export function registerBackgroundFade() {
  registerTenetComponent({
    rowStart: 1,
    rowEnd: 12,
    columnStart: 1,
    columnEnd: 12,
    Component: ({ layers }) => {
      const {
        noa: {
          components: { IsUiFocused },
          SingletonEntity,
          noa,
          api: { toggleInventory },
        },
      } = layers;

      const isShown = useComponentValue(IsUiFocused, SingletonEntity)?.value;
      return isShown ? (
        <Background
          onClick={() => {
            toggleInventory(false, undefined, false);
            noa.container.setPointerLock(true); // make the user be able to move again
          }}
        />
      ) : null;
    },
  });
}

const Background = styled.div`
  background-color: rgba(0, 0, 0, 0.2);
  position: absolute;
  height: 100%;
  width: 100%;
  pointer-events: all;
  backgroundcolor: "rgba(0,0,0,0.2)";
`;
