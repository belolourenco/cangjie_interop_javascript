package interop_javascript.jsinterop

foreign func quickjs_runtime_create(): CPointer<Unit>
foreign func quickjs_runtime_destroy(handle: CPointer<Unit>): Unit
foreign func quickjs_runtime_last_error(handle: CPointer<Unit>): CString

foreign func quickjs_runtime_eval_value(handle: CPointer<Unit>, source: CString): CPointer<Unit>
foreign func quickjs_runtime_new_undefined(handle: CPointer<Unit>): CPointer<Unit>
foreign func quickjs_runtime_new_null(handle: CPointer<Unit>): CPointer<Unit>
foreign func quickjs_runtime_new_bool(handle: CPointer<Unit>, value: Int64): CPointer<Unit>
foreign func quickjs_runtime_new_number(handle: CPointer<Unit>, value: Float64): CPointer<Unit>
foreign func quickjs_runtime_new_string(handle: CPointer<Unit>, value: CString): CPointer<Unit>
foreign func quickjs_runtime_set_global_value(handle: CPointer<Unit>, name: CString, value: CPointer<Unit>): Int64

foreign func quickjs_value_destroy(handle: CPointer<Unit>): Unit
foreign func quickjs_value_kind(handle: CPointer<Unit>): Int64
foreign func quickjs_value_to_bool(handle: CPointer<Unit>): Int64
foreign func quickjs_value_to_number(handle: CPointer<Unit>): Float64
foreign func quickjs_value_to_string(handle: CPointer<Unit>): CString
foreign func quickjs_bridge_free_string(value: CString): Unit

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

func jsValueObjectKind(): Int64 {
    6
}

func boolAsInt64(value: Bool): Int64 {
    if (value) {
        1
    } else {
        0
    }
}

func ownedCStringToString(value: CString): String {
    if (value.isNull()) {
        return ""
    }

    let result = value.toString()
    unsafe { quickjs_bridge_free_string(value) }
    return result
}

public class JSError {
    public let message: String

    public init(message: String) {
        this.message = message
    }
}

public class JSValue <: Resource {
    var handle: CPointer<Unit>
    var closed: Bool = false

    public init(handle: CPointer<Unit>) {
        if (handle.isNull()) {
            throw Exception("JavaScript value handle must not be null")
        }

        this.handle = handle
    }

    ~init() {
        if (!closed) {
            unsafe { quickjs_value_destroy(handle) }
            handle = CPointer<Unit>()
            closed = true
        }
    }

    public static func undefined(runtime: JSRuntime): JSValue {
        runtime.newUndefined()
    }

    public static func null(runtime: JSRuntime): JSValue {
        runtime.newNull()
    }

    public static func bool(runtime: JSRuntime, value: Bool): JSValue {
        runtime.newBool(value)
    }

    public static func int64(runtime: JSRuntime, value: Int64): JSValue {
        runtime.newFloat64(Float64(value))
    }

    public static func float64(runtime: JSRuntime, value: Float64): JSValue {
        runtime.newFloat64(value)
    }

    public static func string(runtime: JSRuntime, value: String): JSValue {
        runtime.newString(value)
    }

    func ensureOpen(): Unit {
        if (closed) {
            throw Exception("JavaScript value is closed")
        }
    }

    func nativeHandle(): CPointer<Unit> {
        ensureOpen()
        handle
    }

    public func valueKind(): Int64 {
        ensureOpen()
        unsafe { quickjs_value_kind(handle) }
    }

    public func isUndefined(): Bool {
        valueKind() == jsValueUndefinedKind()
    }

    public func isNull(): Bool {
        valueKind() == jsValueNullKind()
    }

    public func isBool(): Bool {
        valueKind() == jsValueBoolKind()
    }

    public func isNumber(): Bool {
        valueKind() == jsValueNumberKind()
    }

    public func isString(): Bool {
        valueKind() == jsValueStringKind()
    }

    public func isBigInt(): Bool {
        valueKind() == jsValueBigIntKind()
    }

    public func isObject(): Bool {
        valueKind() == jsValueObjectKind()
    }

    public func asBool(): Bool {
        if (!isBool()) {
            throw Exception("JavaScript value is not a boolean")
        }

        unsafe { quickjs_value_to_bool(handle) != 0 }
    }

    public func asFloat64(): Float64 {
        if (!isNumber()) {
            throw Exception("JavaScript value is not a number")
        }

        unsafe { quickjs_value_to_number(handle) }
    }

    public func asString(): String {
        if (!isString() && !isBigInt()) {
            throw Exception("JavaScript value is not a string")
        }

        ownedCStringToString(unsafe { quickjs_value_to_string(handle) })
    }

    public func isClosed(): Bool {
        closed
    }

    public func close(): Unit {
        if (!closed) {
            unsafe { quickjs_value_destroy(handle) }
            handle = CPointer<Unit>()
            closed = true
        }
    }
}

public class JSEvalResult <: Resource {
    let ok: Bool
    let value: JSValue
    let error: JSError

    public init(ok: Bool, value: JSValue, error: JSError) {
        this.ok = ok
        this.value = value
        this.error = error
    }

    ~init() {
        value.close()
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

    public func isObject(): Bool {
        value.isObject()
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

    public func isClosed(): Bool {
        value.isClosed()
    }

    public func close(): Unit {
        value.close()
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

    ~init() {
        if (!closed) {
            unsafe { quickjs_runtime_destroy(handle) }
            handle = CPointer<Unit>()
            closed = true
        }
    }

    func ensureOpen(): Unit {
        if (closed) {
            throw Exception("QuickJS runtime is closed")
        }
    }

    func runtimeError(): String {
        unsafe { quickjs_runtime_last_error(handle).toString() }
    }

    func valueFromHandle(valueHandle: CPointer<Unit>): JSValue {
        if (valueHandle.isNull()) {
            throw Exception(runtimeError())
        }

        JSValue(valueHandle)
    }

    public func newUndefined(): JSValue {
        ensureOpen()
        valueFromHandle(unsafe { quickjs_runtime_new_undefined(handle) })
    }

    public func newNull(): JSValue {
        ensureOpen()
        valueFromHandle(unsafe { quickjs_runtime_new_null(handle) })
    }

    public func newBool(value: Bool): JSValue {
        ensureOpen()
        valueFromHandle(unsafe { quickjs_runtime_new_bool(handle, boolAsInt64(value)) })
    }

    public func newFloat64(value: Float64): JSValue {
        ensureOpen()
        valueFromHandle(unsafe { quickjs_runtime_new_number(handle, value) })
    }

    public func newString(value: String): JSValue {
        ensureOpen()
        let cValue = unsafe { LibC.mallocCString(value) }
        let valueHandle = unsafe { quickjs_runtime_new_string(handle, cValue) }
        unsafe { LibC.free(cValue) }
        valueFromHandle(valueHandle)
    }

    public func evalScript(source: String): JSEvalResult {
        ensureOpen()

        let cSource = unsafe { LibC.mallocCString(source) }
        let valueHandle = unsafe { quickjs_runtime_eval_value(handle, cSource) }
        unsafe { LibC.free(cSource) }

        if (!valueHandle.isNull()) {
            return JSEvalResult(true, JSValue(valueHandle), JSError(""))
        }

        let error = runtimeError()
        return JSEvalResult(false, newUndefined(), JSError(error))
    }

    public func setGlobal(name: String, value: JSValue): Unit {
        ensureOpen()

        let cName = unsafe { LibC.mallocCString(name) }
        let status = unsafe { quickjs_runtime_set_global_value(handle, cName, value.nativeHandle()) }
        unsafe { LibC.free(cName) }

        if (status != 0) {
            throw Exception(runtimeError())
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