# Cangjie JavaScript Interop

`interop_javascript` is a Cangjie library for calling JavaScript from Cangjie.
It embeds the vendored QuickJS engine and exposes a Cangjie-facing runtime API in
`src/quickJSRuntime.cj`.

The direction of interop is Cangjie to JavaScript: Cangjie code evaluates
JavaScript, loads JavaScript modules, accesses JavaScript values, calls
JavaScript functions, constructs JavaScript classes, and converts selected
primitive values back to Cangjie.

## Project Layout

```text
.
├── Makefile
├── cjpm.toml
├── native/
│   ├── bridge/
│   │   ├── quickjs_bridge.c
│   │   └── quickjs_bridge.h
│   └── quickjs/
├── src/
│   └── quickJSRuntime.cj
└── tests/
    ├── smoke/
    ├── extern_primitive_types/
    ├── extern_with_modules_1/
    └── extern_with_modules_2/
```

- `src/quickJSRuntime.cj` is the public Cangjie API.
- `native/quickjs/` contains the vendored QuickJS source.
- `native/bridge/` contains the small C bridge used by Cangjie foreign
  functions.
- `tests/*` are standalone `cjpm` packages executed by the root `Makefile`.

## Requirements

Required tools:

- Cangjie toolchain with `cjc` and `cjpm`
- `clang`
- `make`
- `ar`
- `ranlib`
- `git`

The project currently targets the Cangjie version declared in `cjpm.toml`:

```text
cjc-version = "1.0.5"
```

QuickJS is vendored in `native/quickjs/`, so no system QuickJS installation is
required.

For a full machine setup checklist, see
`docs/environment_setup.md`.

## Build

From the project root:

```sh
source /path/to/cangjie/envsetup.sh
make build
```

This builds:

- the native QuickJS bridge archive at `build/native/libquickjs_bridge.a`;
- the root Cangjie library package.

## Test

Run the full test suite with:

```sh
make test
```

`make test` builds and executes:

- `tests/smoke`
- `tests/extern_primitive_types`
- `tests/extern_with_modules_1`
- `tests/extern_with_modules_2`

The test executables return non-zero exit codes on failure, so `make test`
fails when a test fails.

`make all` also runs the test suite.

## Clean

```sh
make clean
```

This removes the root build output and the generated output from each test
package.

## Public API

The public runtime API is `JSRuntime` in `src/quickJSRuntime.cj`.

Main operations:

- `JSRuntime.evalScript(source: String)`
- `JSRuntime.enableStdModule()`
- `JSRuntime.globalAccess(name: String)`
- `JSRuntime.getModule(moduleName: String)`
- `JSRuntime.memberAccess(e, field)`
- `JSRuntime.memberUpdate(e, field, value)`
- `JSRuntime.indexAccess(e, arg)`
- `JSRuntime.indexUpdate(e, arg, value)`
- `JSRuntime.functionCall(e, args)`
- `JSRuntime.toExtern(value)`
- `JSRuntime.fromExtern<T>(e)`

JavaScript values are represented as `Extern<JSRuntime>`.

## Example

```cj
package example

import extern.Extern
import interop_javascript.JSRuntime

main(): Int64 {
    let sum: Extern<JSRuntime> = JSRuntime.evalScript("1 + 2")
    let result: Float64 = JSRuntime.fromExtern<Float64>(sum)
    println(result)

    let object: Extern<JSRuntime> = JSRuntime.evalScript("({ name: 'shape', width: 10 })")
    let name: String = JSRuntime.fromExtern<String>(
        JSRuntime.memberAccess(object, "name")
    )
    println(name)

    JSRuntime.memberUpdate(object, "width", Float64(20.0))
    let width: Float64 = JSRuntime.fromExtern<Float64>(
        JSRuntime.memberAccess(object, "width")
    )
    println(width)

    return 0
}
```

## Module Access

JavaScript modules can be loaded with `JSRuntime.getModule(path)`.

```cj
let module = JSRuntime.getModule("js_examples/my_module.js")
let value = JSRuntime.memberAccess(module, "globalNumber")
let number: Float64 = JSRuntime.fromExtern<Float64>(value)
```

The module path is resolved by QuickJS from the current working directory of the
running test or application.

## Value Lifetime

JavaScript values returned to Cangjie are owned by small Cangjie wrapper objects.
Those wrappers release their native QuickJS handles from finalizers, so user code
does not call an explicit `close` method.

The native runtime is also owned by a Cangjie wrapper. The bridge delays
destroying the underlying QuickJS runtime until the runtime owner has finalized
and all outstanding JavaScript value handles have been released.

## Supported Conversions

The current conversion layer supports:

- `Bool`
- `String`
- signed and unsigned integer types
- floating-point types
- `BigInt`

Objects, arrays, functions, classes, and modules remain JavaScript values and
are manipulated through `Extern<JSRuntime>`.
