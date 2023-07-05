import "../codegen/proto/player_pb.js";
import { grpc } from "@improbable-eng/grpc-web";
// import { createChannel, createClient } from "nice-grpc-web";
import { PlayerServiceClient } from "../codegen/proto/PlayerServiceClientPb";

const url = "http://0.0.0.0:50051";
// const wsClient = createClient(ECSRelayServiceDefinition, createChannel(url, grpc.WebsocketTransport()));
const client = new PlayerServiceClient(url, {}, { transport: grpc.WebsocketTransport() });

export function attackPlayer(attackerId: string, victimId: string, damage: number) {
  return new Promise<Shard.Player>((resolve, reject) => {
    // Create a new Attack object
    const attack = new Shard.Attack().setAttackerId(attackerId).setVictimId(victimId).setDamage(damage);
    client.attackPlayer(attack, {}, (err, response) => {
      if (err) {
        reject(err);
      } else {
        resolve(response);
      }
    });
  });
}
