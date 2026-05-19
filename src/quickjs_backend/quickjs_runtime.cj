package interop_javascript.quickjs_backend

foreign func quickjs_runtime_create(): CPointer<Unit>
foreign func quickjs_runtime_destroy(handle: CPointer<Unit>): Unit
foreign func quickjs_runtime_eval_number(handle: CPointer<Unit>, source: CString): Int64
foreign func quickjs_runtime_last_number(handle: CPointer<Unit>): Float64
foreign func quickjs_runtime_last_error(handle: CPointer<Unit>): CString

public func quickJSBackendSmokeTest(): String {
    "quickjs backend phase2 ok"
}

public class QuickJSEvalResult {
    let ok: Bool
    let numberValue: Float64
    let error: String

    public init(ok: Bool, numberValue: Float64, error: String) {
        this.ok = ok
        this.numberValue = numberValue
        this.error = error
    }

    public func isOk(): Bool {
        ok
    }

    public func asFloat64(): Float64 {
        numberValue
    }

    public func errorMessage(): String {
        error
    }
}

public class QuickJSRuntime <: Resource {
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

    public func evalScriptNumber(source: String): QuickJSEvalResult {
        if (closed) {
            return QuickJSEvalResult(false, 0.0, "QuickJS runtime is closed")
        }

        let cSource = unsafe { LibC.mallocCString(source) }
        let status = unsafe { quickjs_runtime_eval_number(handle, cSource) }
        unsafe { LibC.free(cSource) }

        if (status == 0) {
            return QuickJSEvalResult(true, unsafe { quickjs_runtime_last_number(handle) }, "")
        }

        let error = unsafe { quickjs_runtime_last_error(handle) }
        return QuickJSEvalResult(false, 0.0, error.toString())
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

