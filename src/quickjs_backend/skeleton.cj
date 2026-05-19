package interop_javascript.quickjs_backend

foreign func quickjs_runtime_create(): CPointer<Unit>
foreign func quickjs_runtime_destroy(handle: CPointer<Unit>): Unit
foreign func quickjs_runtime_eval_number(handle: CPointer<Unit>, source: CString): Int64
foreign func quickjs_runtime_last_number(handle: CPointer<Unit>): Float64
foreign func quickjs_runtime_last_error(handle: CPointer<Unit>): CString

public func quickJSBackendSmokeTest(): String {
    "quickjs backend skeleton ok"
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
    var handle: CPointer<Unit> = CPointer<Unit>()
    var closed: Bool = true

    public init() {
        let created = unsafe { quickjs_runtime_create() }
        if (created.isNull()) {
            throw Exception("failed to create QuickJS runtime")
        }

        handle = created
        closed = false
    }

    public func evalScript(source: String): JSEvalResult {
        if (closed) {
            return JSEvalResult(false, JSValue(0.0), JSError("QuickJS runtime is closed"))
        }

        let cSource = unsafe { LibC.mallocCString(source) }
        let status = unsafe { quickjs_runtime_eval_number(handle, cSource) }
        unsafe { LibC.free(cSource) }

        if (status == 0) {
            return JSEvalResult(
                true,
                JSValue(unsafe { quickjs_runtime_last_number(handle) }),
                JSError("")
            )
        }

        let error = unsafe { quickjs_runtime_last_error(handle) }
        return JSEvalResult(false, JSValue(0.0), JSError(error.toString()))
    }

    public func isClosed(): Bool {
        closed
    }

    public func close(): Unit {
        if (!closed) {
            unsafe { quickjs_runtime_destroy(handle) }
            handle = CPointer<Unit>()
            closed = true
        }
    }
}

