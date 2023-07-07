import styled from "styled-components";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { useComponentValue } from "@latticexyz/react";
import { setComponent } from "@latticexyz/recs";
import { UiComponentType } from "../../noa/createNoaLayer";
import { FocusedUiType } from "../../noa/components/FocusedUi";

export function registerBackgroundFade() {
  registerTenetComponent({
    rowStart: 1,
    rowEnd: 12,
    columnStart: 1,
    columnEnd: 12,
    Component: ({ layers }) => {
      const {
        noa: {
          components: { FocusedUi },
          SingletonEntity,
          noa,
        },
      } = layers;

      const focusedUi = useComponentValue(FocusedUi, SingletonEntity)?.value;
      return focusedUi !== FocusedUiType.WORLD ? (
        <Background
          onClick={() => {
            setComponent(FocusedUi, SingletonEntity, { value: false });
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
