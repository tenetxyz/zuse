gen4:
	mkdir -p ../client/src/codegen
	npx protoc \
		--ts_out .\
		--ts_opt long_type_string \
		--proto_path proto \
		./proto/player.proto
# --plugin protoc-gen-grpc-web=../../node_modules/.bin/protoc-gen-grpc-web \
# --grpc-web_out=import_style=typescript,mode=grpcwebtext:../client/src/codegen \
# --plugin protoc-gen-js=../../node_modules/.bin/protoc-gen-js \
# --js_out=import_style=commonjs:../client/src/codegen \