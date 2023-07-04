package main

import (
	"context"
	"log"
	"net"
	"sync"

	"shard/src/Shard"

	flatbuffers "github.com/google/flatbuffers/go"
	"google.golang.org/grpc"
)

type server struct {
	Shard.UnimplementedPlayerServiceServer
	sync.RWMutex
	players map[string]*Shard.Player
}

func (s *server) UpdatePlayer(ctx context.Context, req *Shard.Player) (*flatbuffers.Builder, error) {
	s.Lock()
	defer s.Unlock()

	reqId := string(req.Id())
	s.players[reqId] = req

	builder := flatbuffers.NewBuilder(0)
	pos := Shard.CreateCoord3(builder, req.Position(nil).X(), req.Position(nil).Y(), req.Position(nil).Z())
	dir := Shard.CreateQuaternion(builder, req.Direction(nil).X(), req.Direction(nil).Y(), req.Direction(nil).Z(), req.Direction(nil).W())
	id := builder.CreateString(reqId)
	Shard.PlayerStart(builder)
	Shard.PlayerAddId(builder, id)
	Shard.PlayerAddPosition(builder, pos)
	Shard.PlayerAddDirection(builder, dir)
	Shard.PlayerAddHealth(builder, req.Health())
	Shard.PlayerAddAttackCooldownTicksLeft(builder, req.AttackCooldownTicksLeft())
	player := Shard.PlayerEnd(builder)
	builder.Finish(player)

	return builder, nil
}

func newServer() *server {
	return &server{
		players: make(map[string]*Shard.Player),
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
