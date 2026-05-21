.DEFAULT_GOAL := build

CJPM = cjpm
CC = clang
AR = ar
RANLIB = ranlib
CANGJIE_RUNTIME_LIB_DIR := $(shell find "$$CANGJIE_HOME/runtime/lib" -name libcangjie-runtime.dylib -exec dirname {} \; 2>/dev/null | head -n 1)
TEST_BINARY_ENV := DYLD_LIBRARY_PATH=$(CANGJIE_RUNTIME_LIB_DIR):$$DYLD_LIBRARY_PATH

BUILD_DIR := build
NATIVE_BUILD_DIR := $(BUILD_DIR)/native

QUICKJS_DIR := native/quickjs
QUICKJS_VERSION := $(shell cat $(QUICKJS_DIR)/VERSION)
QUICKJS_SOURCES := quickjs.c dtoa.c libregexp.c libunicode.c cutils.c quickjs-libc.c
QUICKJS_OBJECTS := $(addprefix $(NATIVE_BUILD_DIR)/quickjs/,$(QUICKJS_SOURCES:.c=.o))

NATIVE_BRIDGE_DIR := native/bridge
NATIVE_BRIDGE_SOURCE := $(NATIVE_BRIDGE_DIR)/quickjs_bridge.c
NATIVE_BRIDGE_HEADER := $(NATIVE_BRIDGE_DIR)/quickjs_bridge.h
NATIVE_BRIDGE_OBJECT := $(NATIVE_BUILD_DIR)/bridge/quickjs_bridge.o
NATIVE_OBJECTS := $(QUICKJS_OBJECTS) $(NATIVE_BRIDGE_OBJECT)
NATIVE_LIB := $(NATIVE_BUILD_DIR)/libquickjs_bridge.a

SMOKE_DIR := tests/smoke
EXTERN_PRIMITIVE_TYPES_DIR := tests/extern_primitive_types
EXTERN_WITH_MODULES_1_DIR := tests/extern_with_modules_1
EXTERN_WITH_MODULES_2_DIR := tests/extern_with_modules_2

COMMON_CFLAGS := -std=c11 -O2 -g -Wall -Wextra -Wno-unused-parameter
COMMON_CFLAGS += -Wno-sign-compare -Wno-missing-field-initializers
COMMON_CFLAGS += -fwrapv -funsigned-char -D_GNU_SOURCE
COMMON_CFLAGS += -DCONFIG_VERSION=\"$(QUICKJS_VERSION)\"

ifeq ($(shell uname -s),Darwin)
COMMON_CFLAGS += -mmacosx-version-min=12.0
endif

.PHONY: all native cangjie build test smoke-build smoke-test extern-primitive-types-build extern-primitive-types-test extern-with-modules-1-build extern-with-modules-1-test extern-with-modules-2-build extern-with-modules-2-test clean

all: test

native: $(NATIVE_LIB)

cangjie: native
	$(CJPM) build

build: cangjie

test: build
	$(MAKE) smoke-test
	$(MAKE) extern-primitive-types-test
	$(MAKE) extern-with-modules-1-test
	$(MAKE) extern-with-modules-2-test

smoke-build: native
	cd $(SMOKE_DIR) && $(CJPM) build

smoke-test: smoke-build
	cd $(SMOKE_DIR) && $(TEST_BINARY_ENV) target/release/bin/main

extern-primitive-types-build: native
	cd $(EXTERN_PRIMITIVE_TYPES_DIR) && $(CJPM) build

extern-primitive-types-test: extern-primitive-types-build
	cd $(EXTERN_PRIMITIVE_TYPES_DIR) && $(TEST_BINARY_ENV) target/release/bin/main

extern-with-modules-1-build: native
	cd $(EXTERN_WITH_MODULES_1_DIR) && $(CJPM) build

extern-with-modules-1-test: extern-with-modules-1-build
	cd $(EXTERN_WITH_MODULES_1_DIR) && $(TEST_BINARY_ENV) target/release/bin/main

extern-with-modules-2-build: native
	cd $(EXTERN_WITH_MODULES_2_DIR) && $(CJPM) build

extern-with-modules-2-test: extern-with-modules-2-build
	cd $(EXTERN_WITH_MODULES_2_DIR) && $(TEST_BINARY_ENV) target/release/bin/main

clean:
	rm -rf $(BUILD_DIR) target
	rm -rf $(SMOKE_DIR)/target $(SMOKE_DIR)/build-script-cache
	rm -rf $(EXTERN_PRIMITIVE_TYPES_DIR)/target $(EXTERN_PRIMITIVE_TYPES_DIR)/build-script-cache
	rm -rf $(EXTERN_WITH_MODULES_1_DIR)/target $(EXTERN_WITH_MODULES_1_DIR)/build-script-cache
	rm -rf $(EXTERN_WITH_MODULES_2_DIR)/target $(EXTERN_WITH_MODULES_2_DIR)/build-script-cache

$(NATIVE_LIB): $(NATIVE_OBJECTS)
	mkdir -p $(@D)
	$(AR) rcs $@ $^
	$(RANLIB) $@

$(NATIVE_BUILD_DIR)/quickjs/%.o: $(QUICKJS_DIR)/%.c
	mkdir -p $(@D)
	$(CC) $(COMMON_CFLAGS) -I$(QUICKJS_DIR) -c $< -o $@

$(NATIVE_BRIDGE_OBJECT): $(NATIVE_BRIDGE_SOURCE) $(NATIVE_BRIDGE_HEADER) $(QUICKJS_DIR)/quickjs.h
	mkdir -p $(@D)
	$(CC) $(COMMON_CFLAGS) -Inative -c $< -o $@
