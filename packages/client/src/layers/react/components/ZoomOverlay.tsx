import styled from "styled-components";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { useComponentValue } from "@latticexyz/react";
import { setComponent } from "@latticexyz/recs";
import { FocusedUiType } from "../../noa/components/FocusedUi";
import { useCallback, useEffect, useRef, useState } from "react";
import * as BABYLON from "@babylonjs/core";

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
          streams: { zoomEvent$ },
        },
      } = layers;

      const [isZooming, setIsZooming] = useState<ZoomState>(ZoomState.NOT_ZOOMING);
      const timeoutId = useRef<NodeJS.Timeout>();
      const ZOOM_DURATION_MS = 1500;

      useEffect(() => {
        zoomEvent$.subscribe((isZoomingIn) => {
          if (isZoomingIn) {
            setIsZooming(ZoomState.ZOOMING_IN);
          } else {
            setIsZooming(ZoomState.ZOOMING_OUT);
          }

          clearTimeout(timeoutId.current); // stop any existing zoom animation
          timeoutId.current = setTimeout(() => {
            setIsZooming(ZoomState.NOT_ZOOMING);
          }, ZOOM_DURATION_MS);
        });
        return () => {
          clearTimeout(timeoutId.current);
        };
      }, []);

      // const focusedUiType = useComponentValue(FocusedUi, SingletonEntity)?.value;
      // return focusedUiType !== FocusedUiType.WORLD ? <Background /> : null;
      const canvasRef = useCallback((canvas: HTMLCanvasElement) => {
        if (!canvas) {
          return;
        }
        var engine = new BABYLON.Engine(canvas, true);
        var createScene = function () {
          var scene = new BABYLON.Scene(engine);
          scene.clearColor = new BABYLON.Color4(0, 0, 0, 0.5);
          var camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 0, -5), scene);
          camera.setTarget(BABYLON.Vector3.Zero());
          var warpLines = [];
          for (var z = -1000; z < 1000; z += 20) {
            var line = BABYLON.MeshBuilder.CreateCylinder(
              "cylinder",
              { height: 1, diameterTop: 4, diameterBottom: 4, tessellation: 32 },
              scene
            );
            line.material = new BABYLON.StandardMaterial("white", scene);
            line.material.emissiveColor = new BABYLON.Color3(1, 1, 1);
            line.position.x = Math.random() * 1000 - 500;
            line.position.y = Math.random() * 1000 - 500;
            line.position.z = z;
            line.scaling.x = line.scaling.y = 1; // Adjust scaling here for size
            line.scaling.z = 60;
            warpLines.push(line);
          }

          scene.beforeRender = function () {
            for (var i = 0; i < warpLines.length; i++) {
              line = warpLines[i];
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
          console.log("resize");
          engine.resize();
        });
      }, []);

      if (!isZooming) {
        return null;
      }
      return <Canvas ref={canvasRef} />;
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
