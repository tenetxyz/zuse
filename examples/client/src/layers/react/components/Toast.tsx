import React from "react";
import { registerUIComponent } from "../engine";
import { of } from "rxjs";
import { ToastContainer } from "react-toastify";
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
          position="top-right"
          toastStyle={{ marginTop: 2, marginLeft: 20, lineHeight: 1.3, color: "black" }}
          newestOnTop={true}
          autoClose={3500}
          hideProgressBar={true}
          theme="light"
        />
      );
    }
  );
}
