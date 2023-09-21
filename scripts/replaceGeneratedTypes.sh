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

# for table in the table/ directory, replace the generated types
find "src/codegen/tables" -type f | while read -r input_file; do
  echo $input_file;
  target='import { BlockDirection } from "./../Types.sol"'
  replacement='import { BlockDirection } from "@tenet-utils/src/Types.sol"'
  awk -v target="$target" -v replacement="$replacement" '{ gsub(target, replacement); print }' $input_file > temp && mv temp $input_file

  target='import { NoaBlockType } from "./../Types.sol"'
  replacement='import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol"'
  awk -v target="$target" -v replacement="$replacement" '{ gsub(target, replacement); print }' $input_file > temp && mv temp $input_file

  start_pattern="struct VoxelTypeData {"
  end_pattern="}"
  replacement='import { VoxelTypeData } from "@tenet-utils/src/Types.sol";'

  awk -v start="$start_pattern" -v end="$end_pattern" -v rep="$replacement" '
    !p && $0 ~ start { p=1; print rep; next }
    p && $0 ~ end { p=0; next }
    !p
  ' "$input_file" > "$temp_file" && mv "$temp_file" "$input_file"


  start_pattern="struct BodyPhysicsData {"
  end_pattern="}"
  replacement='import { BodyPhysicsData } from "@tenet-utils/src/Types.sol";'

  awk -v start="$start_pattern" -v end="$end_pattern" -v rep="$replacement" '
    !p && $0 ~ start { p=1; print rep; next }
    p && $0 ~ end { p=0; next }
    !p
  ' "$input_file" > "$temp_file" && mv "$temp_file" "$input_file"
done

echo "[TENET] Replaced generated types in Types.sol"
