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
	victimHealth := victim.Health() - req.Damage()
	if victim.Health() < req.Damage() {
		victimHealth = 0
	}
	victim.MutateHealth(victimHealth)

	// Increase the attacker's attack cooldown
	attacker.MutateAttackCooldownTicksLeft(attacker.AttackCooldownTicksLeft() + 1)

	// Build the updated victim player to return
	builder := flatbuffers.NewBuilder(0)
	pos := Shard.CreateCoord3(builder, victim.Position(nil).X(), victim.Position(nil).Y(), victim.Position(nil).Z())
	dir := Shard.CreateQuaternion(builder, victim.Direction(nil).X(), victim.Direction(nil).Y(), victim.Direction(nil).Z(), victim.Direction(nil).W())
	id := builder.CreateString(string(victim.Id()))
	Shard.PlayerStart(builder)
	Shard.PlayerAddId(builder, id)
	Shard.PlayerAddPosition(builder, pos)
	Shard.PlayerAddDirection(builder, dir)
	Shard.PlayerAddHealth(builder, victimHealth)
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
