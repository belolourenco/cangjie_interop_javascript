package interop_javascript.jsinterop

import interop_javascript.quickjs_backend.*

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
    let backend: QuickJSRuntime

    public init() {
        backend = QuickJSRuntime()
    }

    public func evalScript(source: String): JSEvalResult {
        let result = backend.evalScript(source)
        if (result.isOk()) {
            return JSEvalResult(
                true,
                JSValue(result.valueKind(), result.asBool(), result.asFloat64(), result.asString()),
                JSError("")
            )
        }

        return JSEvalResult(false, JSValue.undefined(), JSError(result.errorMessage()))
    }

    public func setGlobal(name: String, value: JSValue): Unit {
        let error = backend.setGlobal(
            name,
            QuickJSPrimitiveValue(
                value.valueKind(),
                value.rawBool(),
                value.rawFloat64(),
                value.rawString()
            )
        )
        if (!error.isEmpty()) {
            throw Exception(error)
        }
    }

    public func isClosed(): Bool {
        backend.isClosed()
    }

    public func close(): Unit {
        backend.close()
    }
}

