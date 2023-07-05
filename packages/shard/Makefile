generate:
	mkdir -p ../client/src/codegen/proto
	# Generate Go code
	protoc --go_out=./codegen --go-grpc_out=codegen ./proto/player.proto

	# Generate TypeScript code
	mkdir -p ../client/src/codegen
	protoc \
		--plugin protoc-gen-ts_proto=../../node_modules/.bin/protoc-gen-ts_proto \
		--ts_proto_out=import_style=es6,binary:../client/src/codegen \
		--ts_proto_opt=env=browser,outputServices=nice-grpc,outputServices=generic-definitions,outputJsonMethods=false,useExactTypes=false,eslint_disable,esModuleInterop=true,importSuffix=.js \
		./proto/player.proto

	# Generate gRPC-Web code
	protoc \
		--plugin protoc-gen-grpc-web=../../node_modules/.bin/protoc-gen-grpc-web \
		--grpc-web_out=import_style=typescript,mode=grpcwebtext:../client/src/codegen \
		./proto/player.proto


# protoc \
# --ts_proto_out=import_style=commonjs,binary:../client/src/codegen \
# --plugin protoc-gen-ts_proto=../../node_modules/.bin/protoc-gen-ts \
# --ts_proto_out ../client/src/codegen \
# --ts_proto_opt=env=browser,outputServices=nice-grpc,outputServices=generic-definitions,outputJsonMethods=false,useExactTypes=false,eslint_disable,esModuleInterop=true,importSuffix=.ts \
# ./proto/player.proto 
# flatc --ts -o ../client/src/codegen --grpc player.fbs
# flatc --go -o codegen --grpc player.fbs
run:
	make generate && go build && ./main
.PHONY: run

install-deps:
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	go install github.com/grpc-ecosystem/protoc-gen-grpc-gateway-ts
.PHONY: generate
