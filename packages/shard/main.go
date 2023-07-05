package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"shard/codegen/Shard"
	"sync"

	flatbuffers "github.com/google/flatbuffers/go"
	"google.golang.org/grpc"
)

type Player struct {
	Id                      []byte
	Position                *Shard.Coord3
	Direction               *Shard.Quaternion
	Health                  uint
	AttackCooldownTicksLeft uint
}

type server struct {
	Shard.UnimplementedPlayerServiceServer
	sync.RWMutex
	players map[string]*Player
}

const damage = uint(1)
const attackCooldown = uint(10)

func (s *server) AttackPlayer(ctx context.Context, req *Shard.Attack) (*flatbuffers.Builder, error) {
	log.Printf("AttackPlayer: %s -> %s", req.AttackerId(), req.VictimId())
	s.Lock()
	defer s.Unlock()

	attacker, ok := s.players[string(req.AttackerId())]
	if !ok {
		return nil, fmt.Errorf("attacker with id %s not found", req.AttackerId())
	}

	victim, ok := s.players[string(req.VictimId())]
	if !ok {
		return nil, fmt.Errorf("victim with id %s not found", req.VictimId())
	}

	// Decrease victim's health
	victim.Health = victim.Health - damage
	if victim.Health < damage {
		victim.Health = 0
	}

	// Increase the attacker's attack cooldown
	attacker.AttackCooldownTicksLeft = attackCooldown

	// Build the updated victim player to return
	builder := flatbuffers.NewBuilder(4)
	// pos := Shard.CreateCoord3(builder, victim.Position.X(), victim.Position.Y(), victim.Position.Z())
	// dir := Shard.CreateQuaternion(builder, victim.Direction(nil).X(), victim.Direction(nil).Y(), victim.Direction(nil).Z(), victim.Direction(nil).W())
	// id := builder.CreateString(string(victim.Id()))
	Shard.PlayerStart(builder)
	Shard.PlayerAddId(builder, builder.CreateByteVector(victim.Id)) // TODO: use bytes
	Shard.PlayerAddPosition(builder, victim.Position.Table().Pos)
	Shard.PlayerAddDirection(builder, victim.Direction.Table().Pos)
	Shard.PlayerAddHealth(builder, uint32(builder.CreateByteVector(victim.Health)))
	Shard.PlayerAddAttackCooldownTicksLeft(builder, victim.AttackCooldownTicksLeft())
	player := Shard.PlayerEnd(builder)
	builder.Finish(player)

	return builder, nil
}

func newServer() *server {
	return &server{
		players: make(map[string]*Player),
	}
}

func main() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	Shard.RegisterPlayerServiceServer(s, newServer())

	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
