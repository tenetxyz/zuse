import styled from "styled-components";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { useComponentValue } from "@latticexyz/react";
import { setComponent } from "@latticexyz/recs";
import { UiComponentType } from "../../noa/createNoaLayer";
import { FocusedUiType } from "../../noa/components/FocusedUi";
import { useEffect } from "react";
import { ComponentRecord } from "../../../types";

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

      function disableOrEnableInputs(isUiOpen: boolean | undefined) {
        if (isUiOpen) {
          // disable movement when inventory is open
          // https://github.com/fenomas/noa/issues/61
          noa.entities.removeComponent(noa.playerEntity, noa.ents.names.receivesInputs);
          noa.inputs.unbind("select-voxel");
          noa.inputs.unbind("admin-panel");
          const a = noa.entities.getMovement(noa.playerEntity);
          noa.entities.getMovement(noa.playerEntity).isPlayerSlowedToAStop = true; // stops the player's input from moving the player
        } else {
          // since a react component calls this function times, we need to use addComponentAgain (rather than addComponent)
          noa.entities.addComponentAgain(noa.playerEntity, "receivesInputs", noa.ents.names.receivesInputs);
          noa.inputs.bind("select-voxel", "V");
          noa.inputs.bind("admin-panel", "-");
          noa.entities.getMovement(noa.playerEntity).isPlayerSlowedToAStop = false;
        }
      }

      const focusedUi = useComponentValue(FocusedUi, SingletonEntity)?.value;
      useEffect(() => {
        disableOrEnableInputs(focusedUi !== FocusedUiType.WORLD);
        if (focusedUi === FocusedUiType.WORLD) {
          noa.container.setPointerLock(true);
        }
      }, [focusedUi]);

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
