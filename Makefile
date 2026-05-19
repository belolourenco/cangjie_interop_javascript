.DEFAULT_GOAL := build

CJPM = cjpm
CJC = cjc
CC = clang
AR = ar
RANLIB = ranlib

BUILD_DIR := build
NATIVE_BUILD_DIR := $(BUILD_DIR)/native
SMOKE_BUILD_DIR := $(BUILD_DIR)/smoke

QUICKJS_DIR := native/quickjs
QUICKJS_VERSION := $(shell cat $(QUICKJS_DIR)/VERSION)
QUICKJS_SOURCES := quickjs.c dtoa.c libregexp.c libunicode.c cutils.c quickjs-libc.c
QUICKJS_OBJECTS := $(addprefix $(NATIVE_BUILD_DIR)/quickjs/,$(QUICKJS_SOURCES:.c=.o))

NATIVE_BRIDGE_OBJECT := $(NATIVE_BUILD_DIR)/quickjs_bridge.o
NATIVE_OBJECTS := $(QUICKJS_OBJECTS) $(NATIVE_BRIDGE_OBJECT)
NATIVE_LIB := $(NATIVE_BUILD_DIR)/libquickjs_bridge.a

PACKAGE_BUILD_DIR := target/release/interop_javascript
SMOKE_BIN := $(SMOKE_BUILD_DIR)/jsinterop_smoke

COMMON_CFLAGS := -std=c11 -O2 -g -Wall -Wextra -Wno-unused-parameter
COMMON_CFLAGS += -Wno-sign-compare -Wno-missing-field-initializers
COMMON_CFLAGS += -fwrapv -funsigned-char -D_GNU_SOURCE
COMMON_CFLAGS += -DCONFIG_VERSION=\"$(QUICKJS_VERSION)\"

ifeq ($(shell uname -s),Darwin)
COMMON_CFLAGS += -mmacosx-version-min=12.0
endif

.PHONY: native cangjie build test clean

native: $(NATIVE_LIB)

cangjie: native
	$(CJPM) build

build: native cangjie $(SMOKE_BIN)

test: build
	$(SMOKE_BIN)

clean:
	rm -rf $(BUILD_DIR) target

$(NATIVE_LIB): $(NATIVE_OBJECTS)
	mkdir -p $(@D)
	$(AR) rcs $@ $^
	$(RANLIB) $@

$(NATIVE_BUILD_DIR)/quickjs/%.o: $(QUICKJS_DIR)/%.c
	mkdir -p $(@D)
	$(CC) $(COMMON_CFLAGS) -I$(QUICKJS_DIR) -c $< -o $@

$(NATIVE_BRIDGE_OBJECT): native/quickjs_bridge.c native/quickjs_bridge.h $(QUICKJS_DIR)/quickjs.h
	mkdir -p $(@D)
	$(CC) $(COMMON_CFLAGS) -Inative -c $< -o $@

$(SMOKE_BIN): tests/smoke/smoke.cj $(NATIVE_LIB)
	mkdir -p $(@D)
	$(CJC) tests/smoke/smoke.cj \
		--set-runtime-rpath \
		--import-path $(PACKAGE_BUILD_DIR) \
		-L $(PACKAGE_BUILD_DIR) \
		-linterop_javascript.jsinterop \
		-L $(NATIVE_BUILD_DIR) \
		-lquickjs_bridge \
		-o $@
