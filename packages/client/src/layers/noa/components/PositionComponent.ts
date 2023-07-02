// This file was copied over from noa: https://github.com/fenomas/noa/blob/master/src/components/position.js
// The reason why was we need it to listen to position changes
import vec3 from "gl-vec3";

export const POSITION_COMPONENT_NAME = "position";

export interface IPositionState {
  /** Position in global coords (may be low precision)  **/
  position: null | number[];
  width: number;
  height: number;

  /** Precise position in local coords **/
  _localPosition: null | number[];

  /** [x,y,z] in LOCAL COORDS **/
  _renderPosition: null | number[];

  /** [lo,lo,lo, hi,hi,hi] in LOCAL COORDS **/
  _extents: null | number[];
}

export function PositionState(): IPositionState {
  return {
    position: null,
    width: 0.8,
    height: 0.8,
    _localPosition: null,
    _renderPosition: null,
    _extents: null,
  };
}

interface IPosition {
  name: string;
  order: number;
  state: IPositionState;
  onAdd(eid: number, states: IPositionState): void;
  onRemove: null;
  system(dt: number, states: IPositionState[]): void;
}

export default function (noa: any): IPosition {
  return {
    name: POSITION_COMPONENT_NAME,
    order: 60,
    state: PositionState(),
    onAdd: function (eid, state) {
      // copy position into a plain array
      const pos = [0, 0, 0];
      if (state.position) vec3.copy(pos, state.position);
      state.position = pos;

      state._localPosition = vec3.create();
      state._renderPosition = vec3.create();
      state._extents = new Float32Array(6);

      // on init only, set local from global
      noa.globalToLocal(state.position, null, state._localPosition);
      vec3.copy(state._renderPosition, state._localPosition);
      updatePositionExtents(state);
    },
    onRemove: null,
    system: function positionProcessor(dt: number, states: IPositionState[]) {
      const off = noa.worldOriginOffset;
      for (let i = 0; i < states.length; i++) {
        const state = states[i];
        vec3.add(state.position, state._localPosition, off);
        updatePositionExtents(state);
      }
    },
  };
}

// update an entity's position state `_extents`
export function updatePositionExtents(state: IPositionState) {
  const hw = state.width / 2;
  const lpos = state._localPosition;
  const ext = state._extents;
  ext[0] = lpos[0] - hw;
  ext[1] = lpos[1];
  ext[2] = lpos[2] - hw;
  ext[3] = lpos[0] + hw;
  ext[4] = lpos[1] + state.height;
  ext[5] = lpos[2] + hw;
}
