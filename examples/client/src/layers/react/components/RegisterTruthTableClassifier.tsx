import { useState } from "react";
import { Button } from "./common";
import { Layers } from "@/types";
import { toast } from "react-toastify";
import { BigNumber } from "ethers";

interface Props {
  layers: Layers;
}
export const RegisterTruthTableClassifier: React.FC<Props> = ({ layers }: Props) => {
  const {
    network: {
      api: { registerTruthTableClassifier },
    },
  } = layers;

  // TODO: we should move this state up so the data is persisted
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [inputText, setInputText] = useState("");
  const [outputText, setOutputText] = useState("");

  const handleSubmit = () => {
    if (inputText === "" || outputText === "") {
      toast(`Invalid truth table. Input and Output cannot be empty.`);
      return;
    }
    const inputRes = tableToTruthTableEntry(inputText);
    if (!inputRes) {
      return;
    }
    const outputRes = tableToTruthTableEntry(outputText);
    if (!outputRes) {
      return;
    }
    const { rows: inputRows, numBits: numInputBits } = inputRes;
    const { rows: outputRows, numBits: numOutputBits } = outputRes;

    if (inputRows.length !== outputRows.length) {
      toast(`Invalid truth table. Input and output have different number of rows.`);
      return;
    }
    registerTruthTableClassifier(name, description, inputRows, outputRows, numInputBits, numOutputBits);
  };

  // An entry of the truth table is stored as a single uint256 number
  // each bit represents whether that the ith input (or output) is a 0 or 1.
  // This function converts the string into the uint256 number
  const tableToTruthTableEntry = (table: string) => {
    const lines = table.split("\n");
    const rows: BigNumber[] = [];
    const numBits = lines[0].split(",").length;
    for (const line of lines) {
      let row = "0";
      const cells = line.split(",");
      if (cells.length !== numBits) {
        toast(`Invalid truth table. Found ${cells.length} cells in row ${line}. each row must have ${numBits} cells.`);
        return undefined;
      }

      for (let cell of cells) {
        cell = cell.trim();
        if (cell === "0") {
          row = row + "0";
        } else if (cell === "1") {
          row = row + "1";
        } else {
          toast(`Invalid truth table. Found ${cell} in row ${line}. Please only enter 0 or 1.`);
          return undefined;
        }
      }
      rows.push(BigNumber.from(row));
    }
    return { rows, numBits };
  };

  const isSubmitDisabled = name === "" || inputText === "" || outputText === "";

  return (
    <div className="flex flex-col w-full mt-5 overflow-y-auto">
      <p>Name</p>
      <input
        placeholder="AND Gate"
        className="p-5 m-5 text-slate-800"
        value={name}
        onChange={(e) => setName(e.target.value)}
      />

      <p>Description</p>
      <input
        placeholder="Turns on when both inputs are on!"
        className="p-5 m-5 text-slate-800"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
      />

      <p>Truth Table Input</p>
      <textarea
        placeholder="0,0
0,1
1,0
1,1"
        className="h-32 p-5 m-5 text-slate-800"
        value={inputText}
        onChange={(e) => setInputText(e.target.value)}
      ></textarea>
      <p>Truth Table Output</p>
      <textarea
        placeholder="0
0
0
1"
        className="h-32 p-5 m-5 text-slate-800"
        value={outputText}
        onChange={(e) => setOutputText(e.target.value)}
      ></textarea>
      <Button
        className="p-5 m-5"
        onClick={() => {
          if (!isSubmitDisabled) {
            handleSubmit();
          }
        }}
        disabled={isSubmitDisabled}
      >
        Submit
      </Button>
    </div>
  );
};
