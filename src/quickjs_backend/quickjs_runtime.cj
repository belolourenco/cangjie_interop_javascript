package interop_javascript.quickjs_backend

foreign func quickjs_runtime_create(): CPointer<Unit>
foreign func quickjs_runtime_destroy(handle: CPointer<Unit>): Unit
foreign func quickjs_runtime_eval_value(handle: CPointer<Unit>, source: CString): Int64
foreign func quickjs_runtime_set_global_value(
    handle: CPointer<Unit>,
    name: CString,
    kind: Int64,
    boolValue: Int64,
    numberValue: Float64,
    stringValue: CString
): Int64
foreign func quickjs_runtime_last_kind(handle: CPointer<Unit>): Int64
foreign func quickjs_runtime_last_bool(handle: CPointer<Unit>): Int64
foreign func quickjs_runtime_last_number(handle: CPointer<Unit>): Float64
foreign func quickjs_runtime_last_string(handle: CPointer<Unit>): CString
foreign func quickjs_runtime_last_error(handle: CPointer<Unit>): CString

public func quickJSBackendSmokeTest(): String {
    "quickjs backend phase3 ok"
}

public class QuickJSEvalResult {
    let ok: Bool
    let kind: Int64
    let boolValue: Bool
    let numberValue: Float64
    let stringValue: String
    let error: String

    public init(ok: Bool, kind: Int64, boolValue: Bool, numberValue: Float64, stringValue: String, error: String) {
        this.ok = ok
        this.kind = kind
        this.boolValue = boolValue
        this.numberValue = numberValue
        this.stringValue = stringValue
        this.error = error
    }

    public func isOk(): Bool {
        ok
    }

    public func valueKind(): Int64 {
        kind
    }

    public func asBool(): Bool {
        boolValue
    }

    public func asFloat64(): Float64 {
        numberValue
    }

    public func asString(): String {
        stringValue
    }

    public func errorMessage(): String {
        error
    }
}

public class QuickJSPrimitiveValue {
    let kind: Int64
    let boolValue: Bool
    let numberValue: Float64
    let stringValue: String

    public init(kind: Int64, boolValue: Bool, numberValue: Float64, stringValue: String) {
        this.kind = kind
        this.boolValue = boolValue
        this.numberValue = numberValue
        this.stringValue = stringValue
    }

    public func valueKind(): Int64 {
        kind
    }

    public func asBoolInt64(): Int64 {
        if (boolValue) {
            1
        } else {
            0
        }
    }

    public func asFloat64(): Float64 {
        numberValue
    }

    public func asString(): String {
        stringValue
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

    public func evalScript(source: String): QuickJSEvalResult {
        if (closed) {
            return QuickJSEvalResult(false, 0, false, 0.0, "", "QuickJS runtime is closed")
        }

        let cSource = unsafe { LibC.mallocCString(source) }
        let status = unsafe { quickjs_runtime_eval_value(handle, cSource) }
        unsafe { LibC.free(cSource) }

        if (status == 0) {
            let kind = unsafe { quickjs_runtime_last_kind(handle) }
            let boolValue = unsafe { quickjs_runtime_last_bool(handle) != 0 }
            let numberValue = unsafe { quickjs_runtime_last_number(handle) }
            let stringValue = unsafe { quickjs_runtime_last_string(handle).toString() }
            return QuickJSEvalResult(true, kind, boolValue, numberValue, stringValue, "")
        }

        let error = unsafe { quickjs_runtime_last_error(handle) }
        return QuickJSEvalResult(false, 0, false, 0.0, "", error.toString())
    }

    public func setGlobal(name: String, value: QuickJSPrimitiveValue): String {
        if (closed) {
            return "QuickJS runtime is closed"
        }

        let cName = unsafe { LibC.mallocCString(name) }
        let cStringValue = unsafe { LibC.mallocCString(value.asString()) }
        let status = unsafe {
            quickjs_runtime_set_global_value(
                handle,
                cName,
                value.valueKind(),
                value.asBoolInt64(),
                value.asFloat64(),
                cStringValue
            )
        }
        unsafe {
            LibC.free(cName)
            LibC.free(cStringValue)
        }

        if (status == 0) {
            return ""
        }

        let error = unsafe { quickjs_runtime_last_error(handle) }
        return error.toString()
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

