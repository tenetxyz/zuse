// https://fenomas.github.io/noa/API/classes/_internal_.Inputs.html#bind
// Key strings should align to KeyboardEvent.code strings - e.g. KeyA, ArrowDown, etc.
// https://developer.mozilla.org/en-US/docs/Web/API/UI_Events/Keyboard_event_code_values

import { Engine } from "noa-engine";
import { FocusedUiType } from "../components/FocusedUi";
import { InputEventKey, InputEvent } from "./createInputSystem";

export const bindInputEvent = (noa: Engine, key: InputEventKey) => {
  const inputKeys = InputEvent[key];
  if (Array.isArray(inputKeys)) {
    noa.inputs.bind(key, ...inputKeys);
  } else {
    noa.inputs.bind(key, inputKeys);
  }
};

export const unbindInputEvent = (noa: Engine, key: InputEventKey) => {
  noa.inputs.unbind(key);
};

export function disableInputs(noa: Engine, focusedUi: FocusedUiType) {
  // disable movement when inventory is open
  // https://github.com/fenomas/noa/issues/61
  noa.entities.removeComponent(noa.playerEntity, noa.ents.names.receivesInputs);
  unbindInputEvent(noa, "select-voxel");
  if (focusedUi !== FocusedUiType.TENET_SIDEBAR) {
    unbindInputEvent(noa, "sidebar");
  }
  if (focusedUi !== FocusedUiType.INVENTORY) {
    // do NOT unbind toggle-inventory if the user is in the inventory (so they can close it)
    unbindInputEvent(noa, "toggle-inventory");
  }
  noa.entities.getMovement(noa.playerEntity).isPlayerSlowedToAStop = true; // stops the player's input from moving the player
  unbindInputEvent(noa, "cancel-action");
}

export function enableInputs(noa: Engine) {
  // since a react component calls this function times, we need to use addComponentAgain (rather than addComponent)
  noa.entities.addComponentAgain(noa.playerEntity, "receivesInputs", noa.ents.names.receivesInputs);
  bindInputEvent(noa, "select-voxel");
  bindInputEvent(noa, "sidebar");
  bindInputEvent(noa, "toggle-inventory");
  noa.entities.getMovement(noa.playerEntity).isPlayerSlowedToAStop = false;
  bindInputEvent(noa, "cancel-action");
}
