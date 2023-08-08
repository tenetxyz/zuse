// This hud sows information about yourself (e.g. health, stamina)

import React, { useEffect, useState } from "react";
import Bar from "../../noa/components/Bar";
import { Layers } from "../../../types";
import { getComponentValue } from "@latticexyz/recs";

interface Props {
  layers: Layers;
}

export const StatusHud: React.FC<Props> = ({ layers }) => {
  const {
    network: {
      contractComponents: { Player },
      playerEntity,
    },
  } = layers;

  if (playerEntity === undefined) return <></>;

  const health = Number(getComponentValue(Player, playerEntity)?.health) || 100;
  const stamina = Number(getComponentValue(Player, playerEntity)?.stamina) || 100;

  return (
    <div className="flex flex-row space-x-32 mb-3">
      <Bar percentage={health} color={"#ff3838"} text={"Health"} barFloatLeft={true} />
      <Bar percentage={stamina} color={"#5671e8"} text={"Stamina"} barFloatLeft={false} />
    </div>
  );
};
