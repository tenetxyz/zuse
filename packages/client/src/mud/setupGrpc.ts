import { grpc } from "grpc-web";
import { Player, PlayerService } from "../codegen/player";

const client = new PlayerServiceClient("http://localhost:50051", null, null);

export function updatePlayer(player: Player) {
  return new Promise<Player>((resolve, reject) => {
    const req = new UpdatePlayerRequest();
    req.setPlayer(player);

    client.updatePlayer(req, {}, (err, response) => {
      if (err) {
        reject(err);
      } else {
        resolve(response.getPlayer());
      }
    });
  });
}

export function attackPlayer(playerId: string, damage: number) {
  return new Promise<Player>((resolve, reject) => {
    // Retrieve the attacker's player data
    const attacker = getPlayerData();

    if (attacker) {
      const req = new UpdatePlayerRequest();
      // Assume that there's a method to get other players data
      const victim = getOtherPlayerData(playerId);

      if (victim) {
        // Decrease victim's health
        victim.setHealth(victim.getHealth() - damage);

        // Increase the attacker's attack cooldown
        attacker.setAttackCooldownTicksLeft(attacker.getAttackCooldownTicksLeft() + 1);
        req.setPlayer(victim);

        client.updatePlayer(req, {}, (err, response) => {
          if (err) {
            reject(err);
          } else {
            resolve(response.getPlayer());
          }
        });
      }
    }
  });
}
