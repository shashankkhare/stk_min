#!/bin/bash
set -e

PLUGIN_NAME="stk_min"
PLUGIN_DIR="$(dirname "$0")"
SRC_DIR="$PLUGIN_DIR/../src"
FLUTTER_ROOT="/usr/local/flutter"

BUILD_DIR="$PLUGIN_DIR/build"
LIB_DIR="$BUILD_DIR/lib$PLUGIN_NAME.so"

mkdir -p "$BUILD_DIR"

# Check Flutter headers
FLUTTER_HEADERS="$FLUTTER_ROOT/bin/cache/artifacts/engine/linux-x64/flutter_linux/flutter_linux.h"
if [ ! -f "$FLUTTER_HEADERS" ]; then
    echo "❌ Flutter headers missing: $FLUTTER_HEADERS"
    exit 1
fi

echo "✅ Flutter headers found"

echo "🔨 Building STK static library..."
g++ -c -fPIC \
    -I"$SRC_DIR" \
    -I"$SRC_DIR/stk" \
    "$SRC_DIR/Flute.cpp" \
    -o "$BUILD_DIR/Flute.o" || exit 1

g++ -c -fPIC \
    -I"$SRC_DIR" \
    -I"$SRC_DIR/stk" \
    "$SRC_DIR/StkMini.cpp" \
    -o "$BUILD_DIR/StkMini.o" || exit 1

ar rcs "$BUILD_DIR/libstk.a" "$BUILD_DIR/Flute.o" "$BUILD_DIR/StkMini.o"

echo "🔨 Building main plugin..."
GTK_FLAGS=$(pkg-config --cflags --libs gtk+-3.0)

g++ -shared -o "$LIB_DIR" \
    -I"$FLUTTER_ROOT/bin/cache/artifacts/engine/linux-x64" \
    -I"$FLUTTER_ROOT/bin/cache/artifacts/engine/linux-x64/flutter_linux" \
    -I"$SYMLINK_DIR" \
    -I"$SRC_DIR" \
    $GTK_FLAGS \
    "$PLUGIN_DIR/stk_min_plugin.cc" \
    "$BUILD_DIR/libstk.a" \
    -lpthread -ldl \
    -Wl,-rpath,"$FLUTTER_ROOT/bin/cache/artifacts/engine/linux-x64"

echo "✅ Plugin built: $LIB_DIR"

