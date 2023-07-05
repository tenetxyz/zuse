import { grpc } from "grpc-web";
import { Player, Attack } from "../codegen/shard";
import { PlayerService } from "../codegen/player_grpc";
import { flatbuffers } from "flatbuffers";

const client = new PlayerService("http://localhost:50051", null, null);

// export function updatePlayer(player: Player) {
//   return new Promise<Player>((resolve, reject) => {
//     const req = new UpdatePlayerRequest();
//     req.setPlayer(player);

//     client.updatePlayer(req, {}, (err, response) => {
//       if (err) {
//         reject(err);
//       } else {
//         resolve(response.getPlayer());
//       }
//     });
//   });
// }

export function attackPlayer(attackerId: string, victimId: string, damage: number) {
  return new Promise<Player>((resolve, reject) => {
    const builder = new flatbuffers.Builder();
    Attack.startAttack(builder);

    const attackerIdOffset = builder.createString(attackerId);
    Attack.addAttackerId(builder, attackerIdOffset);

    const victimIdOffset = builder.createString(victimId);
    Attack.addVictimId(builder, victimIdOffset);

    Attack.addDamage(builder, 50);
    const attackOffset = Attack.endAttack(builder);
    builder.finish(attackOffset);
    const bytes = builder.asUint8Array();

    client.attackPlayer(bytes, {}, (err: any, response: any) => {
      if (err) {
        reject(err);
      } else {
        resolve(response.getPlayer());
      }
    });
  });
}
