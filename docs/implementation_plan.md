# Cangjie JavaScript Interop Library Implementation Plan

## Goal

Create a standalone Cangjie library that lets Cangjie code evaluate JavaScript, load JavaScript modules, call exported functions/classes, and read/write JavaScript values.

The interop direction is intentionally one-way: Cangjie is the host and JavaScript is the embedded guest runtime. Cangjie can drive JavaScript, but JavaScript does not need to call back into Cangjie in the first design.

The first validated development platform is macOS, but the library API should remain portable. The design should stay focused on standalone JavaScript interop and avoid application-platform-specific APIs.

See [Environment Setup And Requirements](environment_setup.md) for system dependencies and verification commands.

## Non-Goals For The First Pass

- Browser DOM APIs.
- Node.js standard library compatibility.
- Automatic conversion for arbitrary Cangjie classes.
- Exposing Cangjie functions or classes to JavaScript.
- JavaScript callbacks into Cangjie.
- A GUI application wrapper.

## Recommended Runtime Backend

Use QuickJS for the first backend.

Why:

- Small embeddable JavaScript engine.
- C API is suitable for a Cangjie FFI bridge.
- Works well for standalone command-line tools and tests.
- Avoids requiring Node, V8, or platform-specific runtime services.

Keep the Cangjie API backend-neutral so a future backend can target JavaScriptCore, V8, or Node subprocesses.

## Proposed Architecture

```text
interop_javascript/
  Makefile
  cjpm.toml
  docs/
  src/
    jsinterop/
      runtime.cj
      value.cj
      object.cj
      function.cj
      module.cj
      conversion.cj
      errors.cj
    quickjs_backend/
      quickjs_runtime.cj
      quickjs_value.cj
      quickjs_ffi.cj
  native/
    quickjs/
    quickjs_bridge.h
    quickjs_bridge.c
  build/
    native/
  examples/
    basic_eval/
    module_call/
    shape_module/
  tests/
```

### Public Cangjie Layer

Expose a small stable API:

- `JSRuntime`: owns the JavaScript engine and global context.
- `JSValue`: dynamic wrapper for JavaScript values.
- `JSObject`: property access, assignment, and key enumeration.
- `JSFunction`: function calls and constructor calls.
- `JSModule`: evaluated or imported module namespace.
- `JSError`: structured errors with JavaScript stack traces when available.
- `JSConverter`: conversions between Cangjie primitives and JavaScript values.

Example target API:

```cangjie
let runtime = JSRuntime()
let module = runtime.importModule("./examples/my_module.js")

let lookup = module.get("lookup").asFunction()
let result = lookup.call([47.6205, -122.3493]).asObject()

let name = result.get("name").asString()
let coordinates = result.get("coordinates").asArray()
```

### Backend Layer

The backend layer should hide engine-specific details behind an internal interface:

- Create/destroy runtime.
- Create/destroy context.
- Evaluate source text.
- Load module from path.
- Convert primitives.
- Read/write object properties.
- Call functions.
- Construct classes.
- Retain/release JavaScript values.
- Extract exception details.

For QuickJS, implement this through a small C shim instead of binding directly to the full QuickJS C API from Cangjie. The shim gives us a stable, narrow FFI surface.

## Build System Plan

Use a top-level `Makefile` as the developer entry point and `cjpm` as the Cangjie package/build tool.

Build responsibilities:

- `Makefile` orchestrates native build, Cangjie build, tests, and cleanup.
- `cjpm.toml` owns Cangjie package metadata and Cangjie compilation.
- The native build compiles QuickJS and `native/quickjs_bridge.c`.
- The native build produces a static archive at `build/native/libquickjs_bridge.a`.
- The Cangjie package build compiles the public Cangjie API and FFI declarations.
- Final executables that use the native bridge link against both the Cangjie package archive and `build/native/libquickjs_bridge.a`.
- Generated native object files and archives live under `build/native/`.
- Vendored QuickJS source stays under `native/quickjs/` and is not modified during normal builds.

Required make targets:

- `make native`: compile QuickJS and the C bridge into `build/native/libquickjs_bridge.a`.
- `make build`: run `make native`, run the Cangjie build, then compile the smoke executable as a link check.
- `make test`: run `make build`, then run the available Cangjie tests and smoke tests. In Phase 1, this may be limited to the skeleton smoke executable.
- `make clean`: remove generated build artifacts.

The build should prefer static linking for the first implementation. That keeps early development free of dynamic-library search path issues.

## Implementation Phases

### Phase 1: Project Skeleton

- Create a top-level `Makefile` with `native`, `build`, `test`, and `clean` targets.
- Create `cjpm.toml`.
- Add source directories for public API and QuickJS backend.
- Add a native C bridge directory.
- Use the vendored QuickJS source in `native/quickjs/`.
- Add a minimal example and smoke test entry point.
- Keep build requirements documented in `docs/environment_setup.md`.

Deliverable: a skeleton Cangjie library builds on macOS, links against a skeleton native bridge archive, and proves the native build can see the vendored QuickJS headers.

Validation:

- Run the environment verification commands from `docs/environment_setup.md`.
- Run `make clean` to start from generated artifacts removed.
- Run `make native`. This must produce `build/native/libquickjs_bridge.a`.
- Run `make build`. This must compile the Cangjie package and link it against `build/native/libquickjs_bridge.a`.
- Run `make test`. In Phase 1 this target should still exist, even if it only runs the skeleton smoke test. This proves the test entry point is wired into the build system from the start.
- Run `make clean`, then run `make test` again. This proves generated native and Cangjie artifacts are not required in source control and that the full build/test path can rebuild from a clean tree.

Minimal smoke test:

- Compile and run a tiny Cangjie entry point that imports the library package.
- Call one exported Cangjie skeleton function such as `jsInteropVersion()` or `jsInteropSmokeTest()`.
- Link against the native bridge archive and call at least one native bridge symbol from Cangjie.
- The native placeholder must include `native/quickjs/quickjs.h` so Phase 1 validates QuickJS header visibility.
- The native placeholder must not create a JavaScript runtime, evaluate source text, load modules, or convert JavaScript values.
- The smoke test should print or return a fixed success value such as `jsinterop skeleton ok`.
- The smoke test should not evaluate JavaScript yet; JavaScript execution starts in Phase 2.

### Phase 2: QuickJS Native Bridge

Turn the Phase 1 skeleton bridge into the first real QuickJS execution path. This phase proves that Cangjie can own a JavaScript engine instance, evaluate source text through QuickJS, and receive a minimal result or error back across the FFI boundary.

Native bridge responsibilities:

- Extend the skeleton `quickjs_bridge.c` and `quickjs_bridge.h`.
- Add opaque handles for runtime/context ownership, for example `quickjs_runtime_handle`.
- Implement runtime/context creation and cleanup in the native bridge.
- Implement script-source evaluation for plain JavaScript source text.
- Convert the result of simple numeric expressions into a small bridge result shape or equivalent out-parameters.
- Capture QuickJS exceptions and expose an error status plus message text.
- Provide explicit destroy/free functions for any native handles or allocated strings returned to Cangjie.

Cangjie layer responsibilities:

- Add the first public `JSRuntime` wrapper in `jsinterop`, backed by a QuickJS-specific runtime adapter in `quickjs_backend`.
- Expose a small public evaluation API such as `evalScript(source: String): JSValue` or an equivalent result type.
- Add a minimal `JSValue` representation that can carry only the Phase 2 result kinds.
- Add a `JSError` representation that preserves at least the JavaScript error message.
- Keep ownership visible: Cangjie runtime wrappers must release their native runtime/context handles.

Out of scope for this phase:

- File-based module loading and import resolution.
- ES module namespace objects.
- General object, array, function, or class interop.
- Passing Cangjie arguments into JavaScript.
- Full primitive conversion beyond reading the simple result needed for `"1 + 2"`.

Deliverable: Cangjie can evaluate `"1 + 2"` and read `3`.

Validation:

- Add a smoke test that creates and destroys a runtime repeatedly.
- Add an evaluation test for `"1 + 2"`.
- Add a failure test for invalid JavaScript syntax and verify the reported error message.
- Add a cleanup test or loop that repeatedly evaluates a simple expression and releases all owned values.
- Keep Phase 1 smoke coverage passing so the native archive and package link path remain validated.

### Phase 3: Primitive Boundary Conversion

Support Cangjie arguments sent into JavaScript:

- `Bool`
- `String`
- integer types
- floating point types
- `Null` / `Undefined` representation

For this phase, the input boundary can be a narrow primitive global-binding API such as `runtime.setGlobal(name, value)`. Function calls with argument arrays are still part of Phase 5.

Support JavaScript results read back by Cangjie:

- boolean
- string
- number
- bigint where practical, represented as a string until a dedicated Cangjie bigint mapping is added
- null / undefined

This is data conversion at the call boundary, not JavaScript calling Cangjie.

Deliverable: round-trip tests for primitive values.

Validation:

- Add tests for each supported Cangjie argument type.
- Add tests for each supported JavaScript result type.
- Add failed-conversion tests for mismatched types and unsupported values.

### Phase 4: Dynamic Object And Array API

Implement:

- `value.typeOf()`
- `value.isObject()`
- `value.asObject()`
- `object.get(name)`
- `object.set(name, value)`
- `object.keys()`
- `array.length`
- `array.get(index)`
- `array.set(index, value)`

Deliverable: Cangjie can consume JavaScript objects like `{ name: "Space Needle", coordinates: [-122.3493, 47.6205] }`.

Validation:

- Add object property read/write tests.
- Add array length, index read, and index write tests.
- Add tests for missing properties and out-of-range array indexes.

### Phase 5: Function And Class Interop

Implement:

- Calling JavaScript functions from Cangjie.
- Passing arguments as `Array<JSValue>` or native Cangjie values through converter helpers.
- Calling methods with a `this` value.
- Constructing JavaScript classes.

Deliverable: Cangjie can call a JavaScript `lookup(lat, long)` function and instantiate a JavaScript `Rectangle` class.

Validation:

- Add tests for function calls with zero, one, and multiple arguments.
- Add method-call tests that depend on the correct `this` value.
- Add constructor tests for a JavaScript class with fields and methods.
- Add tests for JavaScript exceptions thrown from functions and constructors.

### Phase 6: Module Loading

Implement file-based module loading:

- Resolve module paths relative to a configured root.
- Support simple ES module exports.
- Cache loaded modules per runtime.
- Provide meaningful load and syntax errors.

Deliverable: Cangjie can import `examples/shape_module.js` and call its exports.

Validation:

- Add module loading tests for a module with function exports.
- Add module loading tests for a module with class exports.
- Add tests for missing module files and syntax errors.
- Add a cache behavior test that imports the same module twice in one runtime.

### Phase 7: Cangjie-Friendly Access Helpers

Add helper APIs that make JavaScript values pleasant to consume from Cangjie without changing the one-way interop model:

- `getString(name)`
- `getFloat64(name)`
- `getBool(name)`
- `getArray(name)`
- `call(name, args)`
- `construct(name, args)`
- Optional conversion helpers for arrays and records.

Deliverable: Cangjie code can consume common JavaScript APIs with concise, explicit calls while still using the dynamic `JSValue` model underneath.

Validation:

- Add tests proving each helper behaves the same as the lower-level dynamic API.
- Add failure tests for helpers called on incompatible JavaScript values.
- Add example code that uses helpers instead of raw `JSValue` calls.

### Phase 8: Typed Wrapper Layer

Add optional typed helpers on top of the dynamic API:

- Function wrappers with expected return type.
- Object field accessors.
- Generated wrappers from a small schema or TypeScript declaration file.

Deliverable: users can write less dynamic code for stable JavaScript APIs.

Validation:

- Add tests for typed function wrappers with successful and failed return conversions.
- Add tests for typed object field accessors.
- Add a typed wrapper example for the shape module.

### Phase 9: Documentation And Examples

Add examples for:

- Evaluating inline JavaScript.
- Loading a module.
- Calling a function.
- Constructing a class.
- Reading arrays and objects.
- Handling JavaScript exceptions.

Document:

- Supported conversions.
- Ownership and lifetime rules.
- Backend limitations.
- Error handling patterns.

Validation:

- Run every documented example.
- Verify every command in the documentation.
- Check that each completed phase has a matching test or smoke test.

## Testing Strategy

Testing and validation are required after every implementation phase. A phase is not complete until its validation checklist passes.

- Unit tests for primitive conversion.
- Unit tests for object, array, function, and class interop.
- Module loading tests with relative imports.
- Error tests for syntax errors, thrown exceptions, missing properties, and failed conversions.
- Leak-oriented smoke tests that create and release many values.
- End-to-end example that exercises a plain JavaScript shape module.

## Key Design Decisions

- Prefer explicit conversion over implicit magic.
- Keep dynamic interop small and reliable before adding typed convenience wrappers.
- Keep engine-specific code isolated under `quickjs_backend`.
- Make runtime ownership visible so JavaScript values cannot outlive their context.
- Preserve JavaScript exception messages and stack traces whenever possible.
- Keep the first design one-way: Cangjie drives JavaScript, and JavaScript does not call into Cangjie.

## Open Questions

- Should the first module format be ES modules only, CommonJS only, or both?
- How should `undefined` and `null` be represented in Cangjie?
- How much TypeScript declaration parsing should be included in the first typed wrapper layer?
- Do we need a separate `JSArray` wrapper, or is `JSObject` with indexed helpers enough for the first version?

## Next Concrete Milestone

Build the first real JavaScript execution path after the Phase 1 skeleton:

1. Cangjie creates a JavaScript runtime.
2. Cangjie evaluates `1 + 2`.
3. Cangjie reads the JavaScript result as a number.
4. The example or smoke test prints or verifies `3`.
5. A failure test verifies that invalid JavaScript syntax reports a useful error.
