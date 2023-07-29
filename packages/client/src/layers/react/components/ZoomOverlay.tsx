import styled from "styled-components";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { useCallback, useEffect, useRef, useState } from "react";
import * as BABYLON from "@babylonjs/core";
import { disableInputs, enableInputs } from "../../noa/systems/createInputSystemHelpers";
import { FocusedUiType } from "../../noa/components/FocusedUi";

enum ZoomState {
  NOT_ZOOMING,
  ZOOMING_IN,
  ZOOMING_OUT,
}

export function registerZoomOverlay() {
  registerTenetComponent({
    rowStart: 1,
    rowEnd: 13,
    columnStart: 1,
    columnEnd: 13,
    Component: ({ layers }) => {
      const {
        noa: {
          noa,
          streams: { zoomEvent$ },
        },
      } = layers;

      const [zoomState, setZoomState] = useState<ZoomState>(ZoomState.NOT_ZOOMING);
      const timeoutId = useRef<NodeJS.Timeout>();
      const ZOOM_DURATION_MS = 2000;

      useEffect(() => {
        zoomEvent$.subscribe((isZoomingIn) => {
          const body = noa.entities.getPhysicsBody(noa.playerEntity)!;
          if (isZoomingIn) {
            setZoomState(ZoomState.ZOOMING_IN);
          } else {
            setZoomState(ZoomState.ZOOMING_OUT);
          }
          disableInputs(noa, FocusedUiType.WORLD);

          clearTimeout(timeoutId.current); // stop any existing zoom animation
          timeoutId.current = setTimeout(() => {
            setZoomState(ZoomState.NOT_ZOOMING);
            enableInputs(noa);
          }, ZOOM_DURATION_MS);
        });
        return () => {
          clearTimeout(timeoutId.current);
        };
      }, []);

      // TODO: see if there's a more efficient way to create this
      const canvasRef = useCallback(
        (canvas: HTMLCanvasElement) => {
          if (!canvas) {
            return;
          }
          const isZoomingIn = zoomState === ZoomState.ZOOMING_IN;
          const zoomZPos = isZoomingIn ? 450 : -450;
          const engine = new BABYLON.Engine(canvas, true);
          const createScene = function () {
            var scene = new BABYLON.Scene(engine);
            scene.clearColor = new BABYLON.Color4(0, 0, 0, 1); // opaque so it slowly dims the scene
            var camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 0, zoomZPos), scene);
            camera.setTarget(BABYLON.Vector3.Zero());
            const warpLines: BABYLON.Mesh[] = [];
            for (var z = -1000; z < 1000; z += 20) {
              const line = BABYLON.MeshBuilder.CreateCylinder(
                "cylinder",
                { height: 1, diameterTop: 4, diameterBottom: 4, tessellation: 32 },
                scene
              );
              line.material = new BABYLON.StandardMaterial("white", scene);
              (line.material as any).emissiveColor = new BABYLON.Color3(1, 1, 1);
              line.position.x = Math.random() * 1000 - 500;
              line.position.y = Math.random() * 1000 - 500;
              line.position.z = z;
              line.scaling.x = line.scaling.y = 1; // Adjust scaling here for size
              line.scaling.z = 60;
              warpLines.push(line);
            }

            scene.beforeRender = function () {
              for (let i = 0; i < warpLines.length; i++) {
                const line = warpLines[i];
                line.position.z += i / 5; // Adjust divisor here for speed
                if (line.position.z > 1000) line.position.z -= 2000;
              }
            };

            return scene;
          };

          var scene = createScene();
          engine.runRenderLoop(function () {
            scene.render();
          });

          window.addEventListener("resize", function () {
            engine.resize();
          });
        },
        [zoomState]
      );

      if (zoomState === ZoomState.NOT_ZOOMING) {
        return null;
      }
      return <Canvas className="animate-fade-in-and-out" ref={canvasRef} />;
    },
  });
}

const Canvas = styled.canvas`
  width: 100%;
  height: 100%;
`;
const Background = styled.div`
  background-color: rgba(0, 0, 0, 0.2);
  position: absolute;
  height: 100%;
  width: 100%;
`;
