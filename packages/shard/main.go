package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"sync"

	pb "tenetxyz/shard/codegen/tenetxyz/shard"

	"google.golang.org/grpc"
)

type Player struct {
	Id                      []byte
	Position                *pb.Coord3
	Direction               *pb.Quaternion
	Health                  uint
	AttackCooldownTicksLeft uint
}

type server struct {
	pb.UnimplementedPlayerServiceServer
	sync.RWMutex
	players map[string]*pb.Player
}

const damage = uint32(1)
const attackCooldown = uint32(10)

func (s *server) UpdatePlayer(ctx context.Context, player *pb.Player) (*pb.Player, error) {
	s.Lock()
	defer s.Unlock()

	s.players[player.Id] = player
	return player, nil
}

func (s *server) AttackPlayer(ctx context.Context, attack *pb.Attack) (*pb.Player, error) {
	log.Printf("AttackPlayer: %v", attack.AttackerId)
	s.Lock()
	defer s.Unlock()

	attacker, ok := s.players[attack.AttackerId]
	if !ok {
		return nil, fmt.Errorf("attacker with id %s not found", attack.AttackerId)
	}

	victim, ok := s.players[attack.VictimId]
	if !ok {
		return nil, fmt.Errorf("victim with id %s not found", attack.VictimId)
	}

	// Decrease victim's health
	victim.Health = victim.Health - damage
	if victim.Health < damage {
		victim.Health = 0
	}

	// Increase the attacker's attack cooldown
	attacker.AttackCooldownTicksLeft = attackCooldown

	return victim, nil
}

func newServer() *server {
	return &server{
		players: make(map[string]*pb.Player),
	}
}

func main() {
	port := ":50051"
	log.Printf("Listening on %s", port)
	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterPlayerServiceServer(s, newServer())

	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
