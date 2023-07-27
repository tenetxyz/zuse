import styled from "styled-components";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { useComponentValue } from "@latticexyz/react";
import { setComponent } from "@latticexyz/recs";
import { FocusedUiType } from "../../noa/components/FocusedUi";
import { useEffect } from "react";

// This ui element is responsible for the dark backgroudn that appears when the user is in a UI
// If the user clicks on the background, the user will be taken back to the world
// TODO: find a better home for the logic in this component that enables/disables inputs
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

      const focusedUiType = useComponentValue(FocusedUi, SingletonEntity)?.value;
      return focusedUiType !== FocusedUiType.WORLD ? (
        <Background
          className="animate-fade-in"
          onClick={() => {
            setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.WORLD });
            noa.container.setPointerLock(true); // make the user be able to move again
          }}
        />
      ) : null;
    },
  });
}

const Background = styled.div`
  position: absolute;
  height: 100%;
  width: 100%;
  pointer-events: all;
  background-color: rgba(0, 0, 0, 0.2);
`;
