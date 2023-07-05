import { Player, Attack } from "../codegen/proto/player_pb";
import { grpc } from "@improbable-eng/grpc-web";
import { createChannel, createClient } from "nice-grpc-web";

import { PlayerServiceClient } from "../codegen/proto/PlayerServiceClientPb";

const url = "http://0.0.0.0:50051";
// const wsClient = createClient(ECSRelayServiceDefinition, createChannel(url, grpc.WebsocketTransport()));
const client = new PlayerServiceClient(url, {}, { transport: grpc.WebsocketTransport() });

export function attackPlayer(attackerId: string, victimId: string, damage: number) {
  return new Promise<Player>((resolve, reject) => {
    const req = new Attack();
    req.setAttackerId(attackerId);
    req.setVictimId(victimId);
    req.setDamage(damage);

    client.attackPlayer(req, {}, (err, response) => {
      if (err) {
        reject(err);
      } else {
        resolve(response);
      }
    });
  });
}
