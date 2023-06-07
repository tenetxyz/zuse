import React from "react";
import { registerUIComponent } from "../engine";
import { concat, map, of } from "rxjs";
import { ToastContainer, toast, Slide } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

export function registerToast() {
  registerUIComponent(
    "Toast",
    {
      rowStart: 2,
      rowEnd: 13,
      colStart: 1,
      colEnd: 13,
    },
    (layers) => of(1),
    () => {
      return (
        <ToastContainer
          position="top-left"
          toastStyle={{ marginTop: 2, marginLeft: 20 }}
          newestOnTop={true}
          autoClose={3500}
          hideProgressBar={true}
          theme="dark"
        />
      );
    }
  );
}
