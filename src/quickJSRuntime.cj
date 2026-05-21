package interop_javascript

import extern.*
import interop_javascript.jsinterop.JSValue
import interop_javascript.jsinterop.JSEvalResult
import interop_javascript.jsinterop.JSFunction
import interop_javascript.jsinterop.JSModule
import interop_javascript.jsinterop.JSRuntime as JSNativeRuntime
import std.math.numeric.BigInt

private func externContentToJSValue(content: Any): JSValue {
    match (content) {
        case jsValue: JSValue => jsValue
        case result: JSEvalResult => result.asValue()
        case _ => throw ExternConversionException("Extern value does not contain a QuickJS value")
    }
}

extend Extern<JSRuntime> {
    public func close(): Unit {
        match (content) {
            case jsValue: JSValue => jsValue.close()
            case result: JSEvalResult => result.close()
            case module: JSModule => module.close()
            case methodAndThis: (JSFunction, JSValue) => methodAndThis[0].close()
            case _ => ()
        }
    }
}

private func closeExternContent(content: Any): Unit {
    Extern<JSRuntime>(content).close()
}

private func quickJS2Cangjie<T>(value: JSValue, cjType: Option<T>) {
    match (cjType) {
        case _: Option<Bool> =>
            if (value.isBool()) {
                return (value.asBool() as T).getOrThrow()
            }
        case _: Option<String> =>
            if (value.isString() || value.isBigInt()) {
                return (value.asString() as T).getOrThrow()
            }
        case _: Option<Int8> =>
            if (value.isNumber()) {
                return (Int8(value.asFloat64()) as T).getOrThrow()
            } else if (value.isBigInt()) {
                return (BigInt.parse(value.asString()).toInt8() as T).getOrThrow()
            }
        case _: Option<Int16> =>
            if (value.isNumber()) {
                return (Int16(value.asFloat64()) as T).getOrThrow()
            } else if (value.isBigInt()) {
                return (BigInt.parse(value.asString()).toInt16() as T).getOrThrow()
            }
        case _: Option<Int32> =>
            if (value.isNumber()) {
                return (Int32(value.asFloat64()) as T).getOrThrow()
            } else if (value.isBigInt()) {
                return (BigInt.parse(value.asString()).toInt32() as T).getOrThrow()
            }
        case _: Option<Int64> =>
            if (value.isNumber()) {
                return (Int64(value.asFloat64()) as T).getOrThrow()
            } else if (value.isBigInt()) {
                return (BigInt.parse(value.asString()).toInt64() as T).getOrThrow()
            }
        case _: Option<UInt8> =>
            if (value.isNumber()) {
                return (UInt8(value.asFloat64()) as T).getOrThrow()
            } else if (value.isBigInt()) {
                return (BigInt.parse(value.asString()).toUInt8() as T).getOrThrow()
            }
        case _: Option<UInt16> =>
            if (value.isNumber()) {
                return (UInt16(value.asFloat64()) as T).getOrThrow()
            } else if (value.isBigInt()) {
                return (BigInt.parse(value.asString()).toUInt16() as T).getOrThrow()
            }
        case _: Option<UInt32> =>
            if (value.isNumber()) {
                return (UInt32(value.asFloat64()) as T).getOrThrow()
            } else if (value.isBigInt()) {
                return (BigInt.parse(value.asString()).toUInt32() as T).getOrThrow()
            }
        case _: Option<UInt64> =>
            if (value.isNumber()) {
                return (UInt64(value.asFloat64()) as T).getOrThrow()
            } else if (value.isBigInt()) {
                return (BigInt.parse(value.asString()).toUInt64() as T).getOrThrow()
            }
        case _: Option<BigInt> =>
            if (value.isNumber()) {
                return (BigInt(value.asFloat64()) as T).getOrThrow()
            } else if (value.isBigInt()) {
                return (BigInt.parse(value.asString()) as T).getOrThrow()
            }
        case _: Option<Float16> =>
            if (value.isNumber()) {
                return (Float16(value.asFloat64()) as T).getOrThrow()
            } else if (value.isBigInt()) {
                return (BigInt.parse(value.asString()).toFloat16() as T).getOrThrow()
            }
        case _: Option<Float32> =>
            if (value.isNumber()) {
                return (Float32(value.asFloat64()) as T).getOrThrow()
            } else if (value.isBigInt()) {
                return (BigInt.parse(value.asString()).toFloat32() as T).getOrThrow()
            }
        case _: Option<Float64> =>
            if (value.isNumber()) {
                return (value.asFloat64() as T).getOrThrow()
            } else if (value.isBigInt()) {
                return (BigInt.parse(value.asString()).toFloat64() as T).getOrThrow()
            }
        case _: Option<JSValue> =>
            return (value as T).getOrThrow()
        case _ => ()
    }

    throw ExternConversionException("Unsupported type conversion by JSRuntime")
}

abstract public class JSRuntime <: Runtime<JSRuntime> {
    private static let runtime = JSNativeRuntime(".")

    private static func toJSBigInt(value: String): JSEvalResult {
        let result = runtime.evalScript("${value}n")
        if (!result.isOk()) {
            let message = result.errorMessage()
            closeExternContent(result)
            throw ExternConversionException(message)
        }

        result
    }

    private static func toJSValue(value: Any): JSValue {
        match (value) {
            case e: Extern<JSRuntime> =>
                externContentToJSValue(e.content)
            case jsValue: JSValue =>
                jsValue
            case i: Int8 =>
                JSValue.int64(runtime, Int64(i))
            case i: Int16 =>
                JSValue.int64(runtime, Int64(i))
            case i: Int32 =>
                JSValue.int64(runtime, Int64(i))
            case i: Int64 =>
                toJSBigInt("${i}").asValue()
            case i: UInt8 =>
                JSValue.int64(runtime, Int64(i))
            case i: UInt16 =>
                JSValue.int64(runtime, Int64(i))
            case i: UInt32 =>
                toJSBigInt("${i}").asValue()
            case i: UInt64 =>
                toJSBigInt("${i}").asValue()
            case i: BigInt =>
                toJSBigInt("${i}").asValue()
            case f: Float16 =>
                JSValue.float64(runtime, Float64(f))
            case f: Float32 =>
                JSValue.float64(runtime, Float64(f))
            case f: Float64 =>
                JSValue.float64(runtime, f)
            case b: Bool =>
                JSValue.bool(runtime, b)
            case s: String =>
                JSValue.string(runtime, s)
            case _ => throw ExternConversionException("Unsupported type by JSRuntime")
        }
    }

    private static func toJSValues(args: Array<Any>): Array<JSValue> {
        args.map(toJSValue)
    }

    public static func evalScript(source: String): Extern<JSRuntime> {
        let result = runtime.evalScript(source)
        if (!result.isOk()) {
            let message = result.errorMessage()
            closeExternContent(result)
            throw ExternDynamicException(message)
        }

        Extern<JSRuntime>(result)
    }

    public static func enableStdModule(): Unit {
        runtime.enableStdModule()
    }

    public static func getModule(moduleName: String): Extern<JSRuntime> {
        Extern<JSRuntime>(runtime.importModule(moduleName))
    }

    public static func evalMemberAccess(e: Extern<JSRuntime>, field: String): Extern<JSRuntime> {
        match (e.content) {
            case module: JSModule =>
                let fieldValue = module.get(field)
                Extern<JSRuntime>(fieldValue)
            case jsValue: JSValue =>
                let fieldValue = jsValue.asObject().get(field)
                if (fieldValue.isFunction()) {
                    Extern<JSRuntime>((fieldValue.asFunction(), jsValue))
                } else {
                    Extern<JSRuntime>(fieldValue)
                }
            case _ => throw ExternDynamicException("Unsupported member access")
        }
    }

    public static func evalFunctionCall(e: Extern<JSRuntime>, args: Array<Any>): Extern<JSRuntime> {
        match (e.content) {
            case methodAndThis: (JSFunction, JSValue) =>
                Extern<JSRuntime>(methodAndThis[0].callWithThis(methodAndThis[1], toJSValues(args)))
            case jsValue: JSValue =>
                let function = jsValue.asFunction()
                try {
                    return Extern<JSRuntime>(function.call(toJSValues(args)))
                } catch (_) {
                    return Extern<JSRuntime>(function.construct(toJSValues(args)))
                }
            case _ => throw ExternDynamicException("Expected function or class")
        }
    }

    public static func evalAssignment(e: Extern<JSRuntime>, field: String, value: Any): Unit {
        match (e.content) {
            case jsValue: JSValue =>
                jsValue.asObject().set(field, toJSValue(value))
            case module: JSModule =>
                throw ExternDynamicException("Cannot assign to JavaScript module namespace")
            case _ => throw ExternDynamicException("Unsupported assignment")
        }
    }

    public static func evalIndexAccess(e: Extern<JSRuntime>, arg: Any): Extern<JSRuntime> {
        let index = match (arg) {
            case i: Int8 => Int64(i)
            case i: Int16 => Int64(i)
            case i: Int32 => Int64(i)
            case i: Int64 => i
            case i: UInt8 => Int64(i)
            case i: UInt16 => Int64(i)
            case i: UInt32 => Int64(i)
            case _ => throw ExternConversionException("JavaScript array index must be an integer")
        }

        match (e.content) {
            case jsValue: JSValue =>
                Extern<JSRuntime>(jsValue.asArray().get(index))
            case _ => throw ExternDynamicException("Expected JavaScript array")
        }
    }

    public static func fromExtern<T>(e: Extern<JSRuntime>): T {
        let dummy: Option<T> = None
        match (e.content) {
            case jsValue: JSValue =>
                quickJS2Cangjie(jsValue, dummy)
            case result: JSEvalResult =>
                quickJS2Cangjie(result.asValue(), dummy)
            case _ => throw ExternConversionException("Extern value does not contain a QuickJS value")
        }
    }

    public static func toExtern<T>(value: T): Extern<JSRuntime> {
        Extern<JSRuntime>(toJSValue(value))
    }
}
