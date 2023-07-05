gen4:
	mkdir -p ../client/src/codegen
	npx protoc \
		--plugin protoc-gen-grpc-web=../../node_modules/.bin/protoc-gen-grpc-web \
		--plugin protoc-gen-js=../../node_modules/.bin/protoc-gen-js \
		--ts_out ../client/src/codegen \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:../client/src/codegen \
		--proto_path proto ./proto/player.proto