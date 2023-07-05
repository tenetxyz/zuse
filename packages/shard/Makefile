
generate:
	mkdir -p ../client/src/codegen/proto
	# Generate Go code
	protoc --go_out=./codegen --go-grpc_out=codegen ./proto/player.proto

	PROTO_DIR=../client/src/codegen

	# Generate JavaScript code
	npx grpc_tools_node_protoc \
		--js_out=import_style=commonjs,binary:${PROTO_DIR} \
		--grpc_out=grpc_js:${PROTO_DIR} \
		--plugin=protoc-gen-grpc=../../node_modules/.bin/grpc_tools_node_protoc_plugin \
		-I ./proto \
		player.proto

	# Generate TypeScript code
	mkdir -p ../client/src/codegen
	../../node_modules/.bin/grpc_tools_node_protoc \
		--plugin=protoc-gen-ts_proto=../../node_modules/.bin/protoc-gen-ts_proto \
		--ts_proto_out=../client/src/codegen \
		--ts_proto_opt=env=browser,outputServices=nice-grpc,outputServices=generic-definitions,outputJsonMethods=false,useExactTypes=false \
		--proto_path=./proto \
		./proto/player.proto

# .PHONY generate

generate2:
	--plugin=protoc-gen-ts=../../node_modules/.bin/protoc-gen-ts \
	--js_out=import_style=commonjs,binary:../client/src/codegen \
	--ts_out=service=grpc-web:../client/src/codegen \
	--proto_path=./proto \
	./proto/player.proto
gen3:
	mkdir -p ../client/src/codegen
	protoc \
 	--plugin protoc-gen-js=../../node_modules/.bin/protoc-gen-js \
 	--plugin protoc-gen-ts=../../node_modules/.bin/protoc-gen-ts \
 	--js_out=import_style=commonjs:../client/src/codegen \
	--ts_out ../client/src/codegen --proto_path "./proto" ./proto/player.proto
gen4:
	mkdir -p ../client/src/codegen
	npx protoc \
		--plugin protoc-gen-grpc-web=../../node_modules/.bin/protoc-gen-grpc-web \
		--plugin protoc-gen-js=../../node_modules/.bin/protoc-gen-js \
		--ts_out ../client/src/codegen \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:../client/src/codegen \
		--proto_path proto ./proto/player.proto

# --js_out=import_style=commonjs:$OUT_DIR \
# # Generate gRPC-Web code
# protoc \
# 	--plugin protoc-gen-grpc-web=../../node_modules/.bin/protoc-gen-grpc-web \
# 	--plugin protoc-gen-js=../../node_modules/.bin/protoc-gen-js \
# 	--js_out=import_style=commonjs:../client/src/codegen \
# 	--grpc-web_out=import_style=typescript,mode=grpcwebtext:../client/src/codegen \
# 	./proto/player.proto

# Generate TypeScript code
# mkdir -p ../client/src/codegen
# protoc \
# 	--plugin protoc-gen-ts_proto=../../node_modules/.bin/protoc-gen-ts_proto \
# 	--ts_proto_out=../client/src/codegen \
# 	--ts_proto_opt=env=browser,outputServices=nice-grpc,outputServices=generic-definitions,outputJsonMethods=false,useExactTypes=false,eslint_disable,esModuleInterop=true,importSuffix=.js \
# 	--grpc-gateway-ts_out=../client/src/codegen \
# 	./proto/player.proto
# mv ../client/src/codegen/proto/player.ts  ../client/src/codegen/proto/player_pb.ts


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
