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

start_pattern="enum ElementType {"
end_pattern="}"
replacement='import { ElementType } from "@tenet-utils/src/Types.sol";'

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

  target='import { ElementType } from "./../Types.sol"'
  replacement='import { ElementType } from "@tenet-utils/src/Types.sol"'
  awk -v target="$target" -v replacement="$replacement" '{ gsub(target, replacement); print }' $input_file > temp && mv temp $input_file

  target='import { SimTable } from "./../Types.sol"'
  replacement='import { SimTable } from "@tenet-utils/src/Types.sol"'
  awk -v target="$target" -v replacement="$replacement" '{ gsub(target, replacement); print }' $input_file > temp && mv temp $input_file

  target='import { CreatureMove } from "./../Types.sol"'
  replacement='import { CreatureMove } from "@tenet-creatures/src/codegen/Types.sol"'
  awk -v target="$target" -v replacement="$replacement" '{ gsub(target, replacement); print }' $input_file > temp && mv temp $input_file

  start_pattern="struct CombatMoveData {"
  end_pattern="}"
  replacement='import { CombatMoveData } from "@tenet-utils/src/Types.sol";'

  awk -v start="$start_pattern" -v end="$end_pattern" -v rep="$replacement" '
    !p && $0 ~ start { p=1; print rep; next }
    p && $0 ~ end { p=0; next }
    !p
  ' "$input_file" > "$temp_file" && mv "$temp_file" "$input_file"

done

echo "[ZUSE] Replaced generated types in Types.sol"
