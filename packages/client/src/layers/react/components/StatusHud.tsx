// This hud sows information about yourself (e.g. health, stamina)

import React, { useEffect, useState } from "react";
import Bar from "../../noa/components/Bar";
import { Layers } from "../../../types";

interface Props {
  layers: Layers;
}

export const StatusHud: React.FC<Props> = ({ layers }) => {
  const maxHealth = 100;
  const maxStamina = 100;
  const [health, setHealth] = useState(80);
  const [stamina, setStamina] = useState(70);
  return (
    <div className="flex flex-row space-x-32 mb-3">
      <Bar percentage={(health * 100) / maxHealth} color={"#ff3838"} text={"Health"} barFloatLeft={true} />
      <Bar percentage={(stamina * 100) / maxStamina} color={"#5671e8"} text={"Stamina"} barFloatLeft={false} />
    </div>
  );
};
