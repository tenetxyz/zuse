// This hud sows information about yourself (e.g. health, stamina)

import React, { useEffect, useState } from "react";
import { Layers } from "../layers";
import Bar from "../../noa/components/Bar";

interface Props {
  layers: Layers;
}

export const StatusHud: React.FC<Props> = ({ layers }) => {
  const maxHealth = 100;
  const maxStamina = 100;
  const [health, setHealth] = useState(80);
  const [stamina, setStamina] = useState(70);
  return (
    <div className="flex flex-col">
      <div className="flex w-32">
        <Bar percentage={(health * 100) / maxHealth} color={"#ff3838"} text={"Health"} barFloatLeft={true} />
      </div>
      <div className="flex justify-end">
        <Bar percentage={(stamina * 100) / maxStamina} color={"#2de0c2"} text={"Stamina"} barFloatLeft={false} />
      </div>
    </div>
  );
};
