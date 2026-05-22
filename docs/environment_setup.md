# Environment Setup And Requirements

This document describes the required environment for building and testing the
Cangjie JavaScript interop library.

The first validated development platform is macOS. The library code should
remain portable, but the commands below are the supported setup for this
project today.

## Required Tools

Install and verify these tools before running the tests.

### Cangjie Toolchain

Required commands:

- `cjc`
- `cjpm`

The project currently targets the Cangjie version declared in `cjpm.toml`:

```text
cjc-version = "1.0.5"
```

Load the Cangjie SDK environment before building:

```sh
source /path/to/cangjie/envsetup.sh
```

Verify:

```sh
cjc --version
cjpm --version
test -n "$CANGJIE_HOME"
```

### Native Build Toolchain

Required commands:

- `clang`
- `make`
- `ar`
- `ranlib`

On macOS, install these with Xcode Command Line Tools:

```sh
xcode-select --install
```

Verify:

```sh
clang --version
make --version
command -v ar
command -v ranlib
```

Apple's `ar` and `ranlib` do not support `--version` or `-v` as version checks,
even when the tools are installed. Use `command -v ar` and `command -v ranlib`.

### Source Control

Required command:

- `git`

Verify:

```sh
git --version
```

`cjpm` uses `git` to fetch the `extern` package dependency.

## Project Dependencies

### QuickJS

QuickJS is vendored in the project under:

```text
native/quickjs/
```

The build compiles the vendored QuickJS sources together with the C bridge. No
system QuickJS installation is required.

Verify that the vendored source is present:

```sh
test -f native/quickjs/quickjs.h
test -f native/quickjs/quickjs-libc.h
test -f native/quickjs/VERSION
```

### Cangjie `extern` Package

The project depends on:

```text
https://github.com/belolourenco/cangjie_extern.git
```

This dependency is declared in the root `cjpm.toml` and in each test package's
`cjpm.toml`. A network connection is required the first time `cjpm` fetches it.

## Build And Test From A Fresh Checkout

From the project root:

```sh
cd /path/to/interop_javascript
source /path/to/cangjie/envsetup.sh
make clean
make test
```

`make test` performs all required steps:

- builds the native QuickJS bridge archive;
- builds the root Cangjie library package;
- builds and runs `tests/smoke`;
- builds and runs `tests/extern_primitive_types`;
- builds and runs `tests/extern_with_modules_1`;
- builds and runs `tests/extern_with_modules_2`.

The test binaries need the Cangjie runtime library on `DYLD_LIBRARY_PATH`.
The Makefile sets this automatically for test execution by locating
`libcangjie-runtime.dylib` under `$CANGJIE_HOME/runtime/lib`.

## Expected Result

The final command should exit with status `0`.

Compiler warnings in the test packages may appear, but they should not stop the
test run. Any non-zero exit from `make test` means the environment or the code
needs attention.

## Quick Verification Checklist

Run this checklist when setting up a new machine:

```sh
source /path/to/cangjie/envsetup.sh
cjc --version
cjpm --version
test -n "$CANGJIE_HOME"
clang --version
make --version
command -v ar
command -v ranlib
git --version
test -f native/quickjs/quickjs.h
test -f native/quickjs/quickjs-libc.h
test -f native/quickjs/VERSION
make clean
make test
```
