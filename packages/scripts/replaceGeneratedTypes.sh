#!/bin/bash
input_file="src/codegen/Types.sol"
temp_file="temp.sol"

start_pattern="enum BlockDirection {"
end_pattern="}"
replacement='import { BlockDirection } from "@tenet-utils/src/Types.sol";'

awk -v start="$start_pattern" -v end="$end_pattern" -v rep="$replacement" '
  !p && $0 ~ start { p=1; print rep; next }
  p && $0 ~ end { p=0; next }
  !p
' "$input_file" > "$temp_file" && mv "$temp_file" "$input_file"

echo "[TENET] Replaced generated types in Types.sol"