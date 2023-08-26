import React from "react";
import { ActionState } from "@latticexyz/recs/src/deprecated";
import styled from "styled-components";
import { PendingIcon } from "./icons/PendingIcon";
import { CheckIcon } from "./icons/CheckIcon";
import { CloseIcon } from "./icons/CloseIcon";
import { Container } from "./common";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";

type Props = {
  state: ActionState;
  icon?: string;
  title: string;
  description?: string;
  link?: string;
};

const ActionContainer = styled.div`
  display: flex;
  border: 0.5px solid #374147;
  background-color: rgba(36, 42, 47, 0.8);
  border-radius: 4px;
  box-shadow: "#C9CACB 0px 0px 20px 5px";

  padding: 4px;

  gap: 10px;
  position: relative;

  transition: opacity 300ms ease-in-out;
  &.Action--pending {
    opacity: 0.4;
  }

  .ActionIcon {
    flex-shrink: 0;
    width: 16px;
    height: 16px;
    overflow: hidden;
    img {
      width: 100%;
      object-fit: cover;
    }
  }

  .ActionLabel {
    display: flex;
    flex-direction: column;
    justify-content: center;
    gap: 6px;
  }

  .ActionTitle {
    color: white;
    text-transform: capitalize;
  }

  .ActionStatus {
    position: absolute;
    right: 8px;
    font-size: 1rem;
  }

  .ActionStatus--spin {
    animation: spin 1s linear infinite;
    @keyframes spin {
      from {
        transform: rotate(0deg);
      }
      to {
        transform: rotate(360deg);
      }
    }
  }
  .ActionStatus--gray {
    color: hsl(0, 0%, 60%);
  }
  .ActionStatus--red {
    color: hsl(0, 60%, 60%);
  }
  .ActionStatus--green {
    color: hsl(120, 60%, 60%);
  }
`;

// TODO: handle other action states
export const ActionStatusIcon = ({ state }: { state: ActionState }) => {
  switch (state) {
    case ActionState.Complete:
      return <CheckIcon className="ActionStatus--green" />;
    case ActionState.Failed:
    case ActionState.Cancelled:
      return <CloseIcon className="ActionStatus--red" />;
    case ActionState.WaitingForTxEvents:
    case ActionState.Executing:
      return <PendingIcon className="ActionStatus--gray ActionStatus--spin" />;
    default:
      return null;
  }
};

export const Action = ({ state, icon, title, description, link }: Props) => (
  <ActionContainer
    className={state <= ActionState.Executing ? "Action--pending" : ""}
    onClick={() => link && window.open(link)}
    clickable={Boolean(link)}
  >
    {/* TODO: placeholder icon if none is set so we can fill the gap and keep text aligned */}
    <div className="ActionIcon">{icon ? <img src={icon} alt="" /> : null}</div>
    <div className="ActionLabel">
      <div className="ActionTitle">{title}</div>
      {description ? <div className="ActionDescription">{description}</div> : null}
    </div>
    <div className="ActionStatus">
      <ActionStatusIcon state={state} />
    </div>
  </ActionContainer>
);
