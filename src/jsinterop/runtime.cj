package interop_javascript.jsinterop

import interop_javascript.quickjs_backend.*

public func jsInteropVersion(): String {
    "0.1.0-phase2"
}

public func jsInteropSmokeTest(): String {
    "jsinterop phase2 ok"
}

public class JSError {
    public let message: String

    public init(message: String) {
        this.message = message
    }
}

public class JSValue {
    let numberValue: Float64

    public init(numberValue: Float64) {
        this.numberValue = numberValue
    }

    public func asFloat64(): Float64 {
        numberValue
    }
}

public class JSEvalResult {
    let ok: Bool
    let value: JSValue
    let error: JSError

    public init(ok: Bool, value: JSValue, error: JSError) {
        this.ok = ok
        this.value = value
        this.error = error
    }

    public func isOk(): Bool {
        ok
    }

    public func asFloat64(): Float64 {
        value.asFloat64()
    }

    public func errorMessage(): String {
        error.message
    }
}

public class JSRuntime <: Resource {
    let backend: QuickJSRuntime

    public init() {
        backend = QuickJSRuntime()
    }

    public func evalScript(source: String): JSEvalResult {
        let result = backend.evalScriptNumber(source)
        if (result.isOk()) {
            return JSEvalResult(true, JSValue(result.asFloat64()), JSError(""))
        }

        return JSEvalResult(false, JSValue(0.0), JSError(result.errorMessage()))
    }

    public func isClosed(): Bool {
        backend.isClosed()
    }

    public func close(): Unit {
        backend.close()
    }
}

