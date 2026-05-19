# Environment Setup And Requirements

This document lists the required tools for building and testing the Cangjie JavaScript interop library on macOS.

## Required System Tools

### Cangjie Toolchain

Required commands:

- `cjc`
- `cjpm`

The build environment must provide both commands on `PATH`. Load the Cangjie SDK environment before building:

```sh
source /path/to/cangjie/envsetup.sh
```

Verify:

```sh
cjc --version
cjpm --version
```

### Native Build Toolchain

Required commands:

- `clang`
- `make`
- `ar`
- `ranlib`

On macOS, install the native build toolchain with Xcode Command Line Tools:

```sh
xcode-select --install
```

Verify:

```sh
clang --version
make --version
which ar
which ranlib
```

Apple's `ar` and `ranlib` do not support `--version` or `-v` as version checks, even when the tools are installed. Use `which` to verify that the commands exist.

### Source Control

Required command:

- `git`

Verify:

```sh
git --version
```

## Project Source Dependency

QuickJS is the JavaScript engine used by the first backend. The project vendors QuickJS `2025-09-13` from the official `quickjs-2025-09-13-2.tar.xz` source archive under:

```text
native/quickjs/
```

The native bridge build compiles the vendored QuickJS source together with the C bridge sources. The system does not require a separate QuickJS installation.

## Verification Checklist

Run these commands before building:

```sh
source /path/to/cangjie/envsetup.sh
cjc --version
cjpm --version
clang --version
make --version
which ar
which ranlib
git --version
```

All commands must succeed.
