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
SMOKE_SOURCES := tests/smoke/main.cj $(filter-out tests/smoke/main.cj,$(wildcard tests/smoke/*.cj))
SMOKE_BIN := $(SMOKE_BUILD_DIR)/smoke
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

.PHONY: native cangjie build test extern-primitive-types-build extern-primitive-types-test extern-with-modules-1-build extern-with-modules-1-test extern-with-modules-2-build extern-with-modules-2-test clean

native: $(NATIVE_LIB)

cangjie: native
	$(CJPM) build

build: native cangjie $(SMOKE_BIN)

test: build
	$(SMOKE_BIN)
	$(MAKE) extern-primitive-types-test
	$(MAKE) extern-with-modules-1-test
	$(MAKE) extern-with-modules-2-test

extern-primitive-types-build: native
	cd $(EXTERN_PRIMITIVE_TYPES_DIR) && $(CJPM) build

extern-primitive-types-test: extern-primitive-types-build
	cd $(EXTERN_PRIMITIVE_TYPES_DIR) && $(CJPM) run

extern-with-modules-1-build: native
	cd $(EXTERN_WITH_MODULES_1_DIR) && $(CJPM) build

extern-with-modules-1-test: extern-with-modules-1-build
	cd $(EXTERN_WITH_MODULES_1_DIR) && $(CJPM) run

extern-with-modules-2-build: native
	cd $(EXTERN_WITH_MODULES_2_DIR) && $(CJPM) build

extern-with-modules-2-test: extern-with-modules-2-build
	cd $(EXTERN_WITH_MODULES_2_DIR) && $(CJPM) run

clean:
	rm -rf $(BUILD_DIR) target
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

$(NATIVE_BRIDGE_OBJECT): native/quickjs_bridge.c native/quickjs_bridge.h $(QUICKJS_DIR)/quickjs.h
	mkdir -p $(@D)
	$(CC) $(COMMON_CFLAGS) -Inative -c $< -o $@

$(SMOKE_BIN): $(SMOKE_SOURCES) $(NATIVE_LIB) cangjie
	mkdir -p $(@D)
	$(CJC) $(SMOKE_SOURCES) \
		--set-runtime-rpath \
		--import-path $(PACKAGE_BUILD_DIR) \
		-L $(PACKAGE_BUILD_DIR) \
		-linterop_javascript.jsinterop \
		-L $(NATIVE_BUILD_DIR) \
		-lquickjs_bridge \
		-o $@
