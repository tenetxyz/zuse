// import { createChannel, createClient, Client } from "nice-grpc-web";
// import { PlayerServiceClient } from "../codegen/player.client";
// import { PlayerServiceClient } from "../codegen/player_grpc_web_pb.js";
// import { Attack } from "../codegen/player.js";

// const url = "http://0.0.0.0:50051";
// const channel = createChannel(url);

// const wsClient = createClient(ECSRelayServiceDefinition, createChannel(url, grpc.WebsocketTransport()));
// const client = new PlayerServiceClient(url);

export function attackPlayer(attackerId: string, victimId: string, damage: number) {
  // Create a new Attack object
  // const attack = {
  //   attackerId,
  //   victimId,
  //   damage,
  // } as Attack;
  // const attack = new Attack();
  // attack.setDamage(damage);
  // attack.setAttackerId(attackerId);
  // attack.setVictimId(victimId);
  // client.attackPlayer(attack);
  // , {}, (err: any, res: any) => {
  //   console.log(res);
  //   console.log(err);
  // });
  // .then((res) => {
  //   console.log(res);
  // })
  // .catch((err) => {
  //   console.warn(err);
  // });
}
