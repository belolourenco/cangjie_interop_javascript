package interop_javascript.jsinterop

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

public func jsInteropVersion(): String {
    "0.1.0-phase3"
}

public func jsInteropSmokeTest(): String {
    "jsinterop phase3 ok"
}

func jsValueUndefinedKind(): Int64 {
    0
}

func jsValueNullKind(): Int64 {
    1
}

func jsValueBoolKind(): Int64 {
    2
}

func jsValueNumberKind(): Int64 {
    3
}

func jsValueStringKind(): Int64 {
    4
}

func jsValueBigIntKind(): Int64 {
    5
}

func boolAsInt64(value: Bool): Int64 {
    if (value) {
        1
    } else {
        0
    }
}

public class JSError {
    public let message: String

    public init(message: String) {
        this.message = message
    }
}

public class JSValue {
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

    public static func undefined(): JSValue {
        JSValue(jsValueUndefinedKind(), false, 0.0, "")
    }

    public static func null(): JSValue {
        JSValue(jsValueNullKind(), false, 0.0, "")
    }

    public static func bool(value: Bool): JSValue {
        JSValue(jsValueBoolKind(), value, 0.0, "")
    }

    public static func int64(value: Int64): JSValue {
        JSValue(jsValueNumberKind(), false, Float64(value), "")
    }

    public static func float64(value: Float64): JSValue {
        JSValue(jsValueNumberKind(), false, value, "")
    }

    public static func string(value: String): JSValue {
        JSValue(jsValueStringKind(), false, 0.0, value)
    }

    public func valueKind(): Int64 {
        kind
    }

    public func rawBool(): Bool {
        boolValue
    }

    public func rawFloat64(): Float64 {
        numberValue
    }

    public func rawString(): String {
        stringValue
    }

    public func isUndefined(): Bool {
        kind == jsValueUndefinedKind()
    }

    public func isNull(): Bool {
        kind == jsValueNullKind()
    }

    public func isBool(): Bool {
        kind == jsValueBoolKind()
    }

    public func isNumber(): Bool {
        kind == jsValueNumberKind()
    }

    public func isString(): Bool {
        kind == jsValueStringKind()
    }

    public func isBigInt(): Bool {
        kind == jsValueBigIntKind()
    }

    public func asBool(): Bool {
        if (!isBool()) {
            throw Exception("JavaScript value is not a boolean")
        }

        boolValue
    }

    public func asFloat64(): Float64 {
        if (!isNumber()) {
            throw Exception("JavaScript value is not a number")
        }

        numberValue
    }

    public func asString(): String {
        if (!isString() && !isBigInt()) {
            throw Exception("JavaScript value is not a string")
        }

        stringValue
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

    public func isUndefined(): Bool {
        value.isUndefined()
    }

    public func isNull(): Bool {
        value.isNull()
    }

    public func isBool(): Bool {
        value.isBool()
    }

    public func isNumber(): Bool {
        value.isNumber()
    }

    public func isString(): Bool {
        value.isString()
    }

    public func isBigInt(): Bool {
        value.isBigInt()
    }

    public func asBool(): Bool {
        value.asBool()
    }

    public func asFloat64(): Float64 {
        value.asFloat64()
    }

    public func asString(): String {
        value.asString()
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
            return JSEvalResult(false, JSValue.undefined(), JSError("QuickJS runtime is closed"))
        }

        let cSource = unsafe { LibC.mallocCString(source) }
        let status = unsafe { quickjs_runtime_eval_value(handle, cSource) }
        unsafe { LibC.free(cSource) }

        if (status == 0) {
            return JSEvalResult(
                true,
                JSValue(
                    unsafe { quickjs_runtime_last_kind(handle) },
                    unsafe { quickjs_runtime_last_bool(handle) != 0 },
                    unsafe { quickjs_runtime_last_number(handle) },
                    unsafe { quickjs_runtime_last_string(handle).toString() }
                ),
                JSError("")
            )
        }

        return JSEvalResult(false, JSValue.undefined(), JSError(unsafe { quickjs_runtime_last_error(handle).toString() }))
    }

    public func setGlobal(name: String, value: JSValue): Unit {
        if (closed) {
            throw Exception("QuickJS runtime is closed")
        }

        let cName = unsafe { LibC.mallocCString(name) }
        let cStringValue = unsafe { LibC.mallocCString(value.rawString()) }
        let status = unsafe {
            quickjs_runtime_set_global_value(
                handle,
                cName,
                value.valueKind(),
                boolAsInt64(value.rawBool()),
                value.rawFloat64(),
                cStringValue
            )
        }
        unsafe {
            LibC.free(cName)
            LibC.free(cStringValue)
        }

        if (status != 0) {
            throw Exception(unsafe { quickjs_runtime_last_error(handle).toString() })
        }
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
