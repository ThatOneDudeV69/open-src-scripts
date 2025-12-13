#!/bin/bash
GAME_NAME="$1"
if [ -z "$GAME_NAME" ]; then
    echo "Usage: ./build.sh gamename"
    exit 1
fi

SRC_PATH="games/$GAME_NAME/src/init.lua"
OUT_PATH="dist/$GAME_NAME.lua"
HEADER="header.txt"

if [ ! -f "$SRC_PATH" ]; then
    echo "Error: $SRC_PATH does not exist."
    exit 1
fi

mkdir -p dist
TMP_BUILD="tmp_build_$GAME_NAME"
mkdir -p "$TMP_BUILD"

cp -r "games/$GAME_NAME/src/." "$TMP_BUILD/"
cp -r "shared/." "$TMP_BUILD/shared/"

TEMP_OUT="$TMP_BUILD/compiled.lua"

./darklua process "$TMP_BUILD/init.lua" "$TEMP_OUT"
if [ $? -ne 0 ]; then
    echo "Darklua failed."
    rm -rf "$TMP_BUILD"
    exit 1
fi

{
    cat "$HEADER"
    echo ""
    cat "$TEMP_OUT"
} > "$OUT_PATH"

rm -rf "$TMP_BUILD"

echo "Built -> $OUT_PATH"
