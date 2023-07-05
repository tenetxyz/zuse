generate-proto:
	mkdir -p codegen
	protoc --go_out=./codegen --go-grpc_out=codegen ./proto/player.proto

	mkdir -p ../client/src/codegen
	npx protoc \
		--ts_out ../client/src/codegen \
		--ts_opt long_type_string \
		--plugin protoc-gen-grpc-web=../../node_modules/.bin/protoc-gen-grpc-web \
		--grpc-web_out=import_style=typescript,mode=grpcwebtext:../client/src/codegen \
		--proto_path proto \
		./proto/player.proto
.PHONY: generate-proto

install-deps:
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
.PHONY: install-deps

run:
	make generate-proto && go build && ./shard
.PHONY: run