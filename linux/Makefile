PLUGIN_NAME = stk_min
SRC_DIR = ../src
FLUTTER_ROOT = /usr/local/flutter
BUILD_DIR = build
LIB = $(BUILD_DIR)/lib$(PLUGIN_NAME).so

GTK_FLAGS = $(shell pkg-config --cflags --libs gtk+-3.0)

all: $(LIB)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(BUILD_DIR)
	g++ -c -fPIC \
		$(GTK_FLAGS) \
		-I$(SRC_DIR) \
		-I$(SRC_DIR)/stk \
		-I$(FLUTTER_ROOT)/bin/cache/artifacts/engine/linux-x64/flutter_linux \
		$< -o $@

$(LIB): $(BUILD_DIR)/Flute.o $(BUILD_DIR)/StkMini.o stk_min_plugin.cc
	@mkdir -p $(BUILD_DIR)
	g++ -shared -o $@ \
		$(GTK_FLAGS) \
		-I$(FLUTTER_ROOT)/bin/cache/artifacts/engine/linux-x64 \
		-I$(FLUTTER_ROOT/bin/cache/artifacts/engine/linux-x64/flutter_linux) \
		-I$(SRC_DIR) \
		stk_min_plugin.cc \
		$(BUILD_DIR)/Flute.o $(BUILD_DIR)/StkMini.o \
		-lpthread -ldl

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean

