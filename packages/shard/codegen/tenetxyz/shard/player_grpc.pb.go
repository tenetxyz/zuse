// Code generated by protoc-gen-go-grpc. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc v1.3.0
// - protoc             v4.23.3
// source: proto/player.proto

package shard

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

const (
	PlayerService_UpdatePlayer_FullMethodName = "/Shard.PlayerService/UpdatePlayer"
	PlayerService_AttackPlayer_FullMethodName = "/Shard.PlayerService/AttackPlayer"
)

// PlayerServiceClient is the client API for PlayerService service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
type PlayerServiceClient interface {
	UpdatePlayer(ctx context.Context, in *Player, opts ...grpc.CallOption) (*Player, error)
	AttackPlayer(ctx context.Context, in *Attack, opts ...grpc.CallOption) (*Player, error)
}

type playerServiceClient struct {
	cc grpc.ClientConnInterface
}

func NewPlayerServiceClient(cc grpc.ClientConnInterface) PlayerServiceClient {
	return &playerServiceClient{cc}
}

func (c *playerServiceClient) UpdatePlayer(ctx context.Context, in *Player, opts ...grpc.CallOption) (*Player, error) {
	out := new(Player)
	err := c.cc.Invoke(ctx, PlayerService_UpdatePlayer_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *playerServiceClient) AttackPlayer(ctx context.Context, in *Attack, opts ...grpc.CallOption) (*Player, error) {
	out := new(Player)
	err := c.cc.Invoke(ctx, PlayerService_AttackPlayer_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// PlayerServiceServer is the server API for PlayerService service.
// All implementations must embed UnimplementedPlayerServiceServer
// for forward compatibility
type PlayerServiceServer interface {
	UpdatePlayer(context.Context, *Player) (*Player, error)
	AttackPlayer(context.Context, *Attack) (*Player, error)
	mustEmbedUnimplementedPlayerServiceServer()
}

// UnimplementedPlayerServiceServer must be embedded to have forward compatible implementations.
type UnimplementedPlayerServiceServer struct {
}

func (UnimplementedPlayerServiceServer) UpdatePlayer(context.Context, *Player) (*Player, error) {
	return nil, status.Errorf(codes.Unimplemented, "method UpdatePlayer not implemented")
}
func (UnimplementedPlayerServiceServer) AttackPlayer(context.Context, *Attack) (*Player, error) {
	return nil, status.Errorf(codes.Unimplemented, "method AttackPlayer not implemented")
}
func (UnimplementedPlayerServiceServer) mustEmbedUnimplementedPlayerServiceServer() {}

// UnsafePlayerServiceServer may be embedded to opt out of forward compatibility for this service.
// Use of this interface is not recommended, as added methods to PlayerServiceServer will
// result in compilation errors.
type UnsafePlayerServiceServer interface {
	mustEmbedUnimplementedPlayerServiceServer()
}

func RegisterPlayerServiceServer(s grpc.ServiceRegistrar, srv PlayerServiceServer) {
	s.RegisterService(&PlayerService_ServiceDesc, srv)
}

func _PlayerService_UpdatePlayer_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(Player)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(PlayerServiceServer).UpdatePlayer(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: PlayerService_UpdatePlayer_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(PlayerServiceServer).UpdatePlayer(ctx, req.(*Player))
	}
	return interceptor(ctx, in, info, handler)
}

func _PlayerService_AttackPlayer_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(Attack)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(PlayerServiceServer).AttackPlayer(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: PlayerService_AttackPlayer_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(PlayerServiceServer).AttackPlayer(ctx, req.(*Attack))
	}
	return interceptor(ctx, in, info, handler)
}

// PlayerService_ServiceDesc is the grpc.ServiceDesc for PlayerService service.
// It's only intended for direct use with grpc.RegisterService,
// and not to be introspected or modified (even as a copy)
var PlayerService_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "Shard.PlayerService",
	HandlerType: (*PlayerServiceServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "UpdatePlayer",
			Handler:    _PlayerService_UpdatePlayer_Handler,
		},
		{
			MethodName: "AttackPlayer",
			Handler:    _PlayerService_AttackPlayer_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "proto/player.proto",
}
