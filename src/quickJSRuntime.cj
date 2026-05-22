package interop_javascript

import extern.*
import std.math.numeric.BigInt

foreign func runtime_create(): CPointer<Unit>
foreign func runtime_last_error(handle: CPointer<Unit>): CString
foreign func runtime_enable_std_module(handle: CPointer<Unit>): Int64

foreign func runtime_eval_value(handle: CPointer<Unit>, source: CString): CPointer<Unit>
foreign func runtime_get_global_property(handle: CPointer<Unit>, name: CString): CPointer<Unit>
foreign func runtime_new_bool(handle: CPointer<Unit>, value: Int64): CPointer<Unit>
foreign func runtime_new_number(handle: CPointer<Unit>, value: Float64): CPointer<Unit>
foreign func runtime_new_string(handle: CPointer<Unit>, value: CString): CPointer<Unit>
foreign func runtime_import_module(handle: CPointer<Unit>, path: CString): CPointer<Unit>

foreign func value_destroy(handle: CPointer<Unit>): Unit
foreign func value_kind(handle: CPointer<Unit>): Int64
foreign func value_to_bool(handle: CPointer<Unit>): Int64
foreign func value_to_number(handle: CPointer<Unit>): Float64
foreign func value_to_string(handle: CPointer<Unit>): CString
foreign func bridge_free_string(value: CString): Unit
foreign func value_is_array(handle: CPointer<Unit>): Int64
foreign func value_array_length(handle: CPointer<Unit>): Int64
foreign func value_get_property(handle: CPointer<Unit>, name: CString): CPointer<Unit>
foreign func value_set_property(handle: CPointer<Unit>, name: CString, value: CPointer<Unit>): Int64
foreign func value_get_index(handle: CPointer<Unit>, index: Int64): CPointer<Unit>
foreign func value_set_index(handle: CPointer<Unit>, index: Int64, value: CPointer<Unit>): Int64
foreign func value_call(function: CPointer<Unit>, thisValue: CPointer<Unit>, args: CPointer<CPointer<Unit>>, numArgs: Int32): CPointer<Unit>
foreign func value_construct(function: CPointer<Unit>, args: CPointer<CPointer<Unit>>, numArgs: Int32): CPointer<Unit>

private let jsValueBoolKind: Int64 = 2
private let jsValueNumberKind: Int64 = 3
private let jsValueStringKind: Int64 = 4
private let jsValueBigIntKind: Int64 = 5
private let jsValueObjectKind: Int64 = 6
private let jsValueFunctionKind: Int64 = 7

private func createRuntime(): CPointer<Unit> {
    let handle = unsafe { runtime_create() }
    if (handle.isNull()) {
        throw ExternDynamicException("failed to create QuickJS runtime")
    }

    handle
}

private func boolAsInt64(value: Bool): Int64 {
    if (value) {
        1
    } else {
        0
    }
}

private func ownedCStringToString(value: CString): String {
    if (value.isNull()) {
        return ""
    }

    let result = value.toString()
    unsafe { bridge_free_string(value) }
    result
}

private func runtimeError(runtime: CPointer<Unit>): String {
    unsafe { runtime_last_error(runtime).toString() }
}

private func valueFromRuntimeHandle(runtime: CPointer<Unit>, value: CPointer<Unit>): CPointer<Unit> {
    if (value.isNull()) {
        throw ExternDynamicException(runtimeError(runtime))
    }

    value
}

private func valueFromCallHandle(runtime: CPointer<Unit>, value: CPointer<Unit>): CPointer<Unit> {
    if (value.isNull()) {
        let message = runtimeError(runtime)
        if (message.isEmpty()) {
            throw ExternDynamicException("JavaScript function call failed")
        }
        throw ExternDynamicException(message)
    }

    value
}

private func valueKind(value: CPointer<Unit>): Int64 {
    if (value.isNull()) {
        throw ExternDynamicException("JavaScript value handle must not be null")
    }

    unsafe { value_kind(value) }
}

private func valueIsBool(value: CPointer<Unit>): Bool {
    valueKind(value) == jsValueBoolKind
}

private func valueIsNumber(value: CPointer<Unit>): Bool {
    valueKind(value) == jsValueNumberKind
}

private func valueIsString(value: CPointer<Unit>): Bool {
    valueKind(value) == jsValueStringKind
}

private func valueIsBigInt(value: CPointer<Unit>): Bool {
    valueKind(value) == jsValueBigIntKind
}

private func valueIsObject(value: CPointer<Unit>): Bool {
    valueKind(value) == jsValueObjectKind
}

private func valueIsFunction(value: CPointer<Unit>): Bool {
    valueKind(value) == jsValueFunctionKind
}

private func valueIsArray(value: CPointer<Unit>): Bool {
    unsafe { value_is_array(value) != 0 }
}

private func valueAsBool(value: CPointer<Unit>): Bool {
    if (!valueIsBool(value)) {
        throw ExternConversionException("JavaScript value is not a boolean")
    }

    unsafe { value_to_bool(value) != 0 }
}

private func valueAsFloat64(value: CPointer<Unit>): Float64 {
    if (!valueIsNumber(value)) {
        throw ExternConversionException("JavaScript value is not a number")
    }

    unsafe { value_to_number(value) }
}

private func valueAsString(value: CPointer<Unit>): String {
    if (!valueIsString(value) && !valueIsBigInt(value)) {
        throw ExternConversionException("JavaScript value is not a string")
    }

    ownedCStringToString(unsafe { value_to_string(value) })
}

private func getProperty(value: CPointer<Unit>, name: String): CPointer<Unit> {
    if (!valueIsObject(value) && !valueIsFunction(value)) {
        throw ExternDynamicException("JavaScript value is not an object")
    }

    let cName = unsafe { LibC.mallocCString(name) }
    let result = unsafe { value_get_property(value, cName) }
    unsafe { LibC.free(cName) }
    if (result.isNull()) {
        throw ExternDynamicException("failed to read JavaScript property")
    }

    result
}

private func setProperty(target: CPointer<Unit>, name: String, value: CPointer<Unit>): Unit {
    if (!valueIsObject(target) && !valueIsFunction(target)) {
        throw ExternDynamicException("JavaScript value is not an object")
    }

    let cName = unsafe { LibC.mallocCString(name) }
    let status = unsafe { value_set_property(target, cName, value) }
    unsafe { LibC.free(cName) }
    if (status != 0) {
        throw ExternDynamicException("failed to write JavaScript property")
    }
}

private func getIndex(value: CPointer<Unit>, index: Int64): CPointer<Unit> {
    if (!valueIsArray(value)) {
        throw ExternDynamicException("Expected JavaScript array")
    }

    let length = unsafe { value_array_length(value) }
    if (index < 0 || index >= length) {
        throw ExternDynamicException("JavaScript array index is out of range")
    }

    let result = unsafe { value_get_index(value, index) }
    if (result.isNull()) {
        throw ExternDynamicException("failed to read JavaScript array index")
    }

    result
}

private func setIndex(target: CPointer<Unit>, index: Int64, value: CPointer<Unit>): Unit {
    if (!valueIsArray(target)) {
        throw ExternDynamicException("Expected JavaScript array")
    }

    let length = unsafe { value_array_length(target) }
    if (index < 0 || index >= length) {
        throw ExternDynamicException("JavaScript array index is out of range")
    }

    let status = unsafe { value_set_index(target, index, value) }
    if (status != 0) {
        throw ExternDynamicException("failed to write JavaScript array index")
    }
}

private func jsIndex(arg: Any): Int64 {
    match (arg) {
        case i: Int8 => Int64(i)
        case i: Int16 => Int64(i)
        case i: Int32 => Int64(i)
        case i: Int64 => i
        case i: UInt8 => Int64(i)
        case i: UInt16 => Int64(i)
        case i: UInt32 => Int64(i)
        case _ => throw ExternConversionException("JavaScript array index must be an integer")
    }
}

private func externContentToValue(content: Any): CPointer<Unit> {
    match (content) {
        case value: CPointer<Unit> => value
        case _ => throw ExternConversionException("Extern value does not contain a JavaScript value")
    }
}

private func closeExternContent(content: Any): Unit {
    match (content) {
        case value: CPointer<Unit> => unsafe { value_destroy(value) }
        case methodAndThis: (CPointer<Unit>, CPointer<Unit>) => unsafe { value_destroy(methodAndThis[0]) }
        case _ => ()
    }
}

extend Extern<JSRuntime> {
    public func close(): Unit {
        closeExternContent(content)
    }
}

private func closeExtern(e: Extern<JSRuntime>): Unit {
    e.close()
}

private func quickJS2Cangjie<T>(value: CPointer<Unit>, cjType: Option<T>) {
    match (cjType) {
        case _: Option<Bool> =>
            if (valueIsBool(value)) {
                return (valueAsBool(value) as T).getOrThrow()
            }
        case _: Option<String> =>
            if (valueIsString(value) || valueIsBigInt(value)) {
                return (valueAsString(value) as T).getOrThrow()
            }
        case _: Option<Int8> =>
            if (valueIsNumber(value)) {
                return (Int8(valueAsFloat64(value)) as T).getOrThrow()
            } else if (valueIsBigInt(value)) {
                return (BigInt.parse(valueAsString(value)).toInt8() as T).getOrThrow()
            }
        case _: Option<Int16> =>
            if (valueIsNumber(value)) {
                return (Int16(valueAsFloat64(value)) as T).getOrThrow()
            } else if (valueIsBigInt(value)) {
                return (BigInt.parse(valueAsString(value)).toInt16() as T).getOrThrow()
            }
        case _: Option<Int32> =>
            if (valueIsNumber(value)) {
                return (Int32(valueAsFloat64(value)) as T).getOrThrow()
            } else if (valueIsBigInt(value)) {
                return (BigInt.parse(valueAsString(value)).toInt32() as T).getOrThrow()
            }
        case _: Option<Int64> =>
            if (valueIsNumber(value)) {
                return (Int64(valueAsFloat64(value)) as T).getOrThrow()
            } else if (valueIsBigInt(value)) {
                return (BigInt.parse(valueAsString(value)).toInt64() as T).getOrThrow()
            }
        case _: Option<UInt8> =>
            if (valueIsNumber(value)) {
                return (UInt8(valueAsFloat64(value)) as T).getOrThrow()
            } else if (valueIsBigInt(value)) {
                return (BigInt.parse(valueAsString(value)).toUInt8() as T).getOrThrow()
            }
        case _: Option<UInt16> =>
            if (valueIsNumber(value)) {
                return (UInt16(valueAsFloat64(value)) as T).getOrThrow()
            } else if (valueIsBigInt(value)) {
                return (BigInt.parse(valueAsString(value)).toUInt16() as T).getOrThrow()
            }
        case _: Option<UInt32> =>
            if (valueIsNumber(value)) {
                return (UInt32(valueAsFloat64(value)) as T).getOrThrow()
            } else if (valueIsBigInt(value)) {
                return (BigInt.parse(valueAsString(value)).toUInt32() as T).getOrThrow()
            }
        case _: Option<UInt64> =>
            if (valueIsNumber(value)) {
                return (UInt64(valueAsFloat64(value)) as T).getOrThrow()
            } else if (valueIsBigInt(value)) {
                return (BigInt.parse(valueAsString(value)).toUInt64() as T).getOrThrow()
            }
        case _: Option<BigInt> =>
            if (valueIsNumber(value)) {
                return (BigInt(valueAsFloat64(value)) as T).getOrThrow()
            } else if (valueIsBigInt(value)) {
                return (BigInt.parse(valueAsString(value)) as T).getOrThrow()
            }
        case _: Option<Float16> =>
            if (valueIsNumber(value)) {
                return (Float16(valueAsFloat64(value)) as T).getOrThrow()
            } else if (valueIsBigInt(value)) {
                return (BigInt.parse(valueAsString(value)).toFloat16() as T).getOrThrow()
            }
        case _: Option<Float32> =>
            if (valueIsNumber(value)) {
                return (Float32(valueAsFloat64(value)) as T).getOrThrow()
            } else if (valueIsBigInt(value)) {
                return (BigInt.parse(valueAsString(value)).toFloat32() as T).getOrThrow()
            }
        case _: Option<Float64> =>
            if (valueIsNumber(value)) {
                return (valueAsFloat64(value) as T).getOrThrow()
            } else if (valueIsBigInt(value)) {
                return (BigInt.parse(valueAsString(value)).toFloat64() as T).getOrThrow()
            }
        case _ => ()
    }

    throw ExternConversionException("Unsupported type conversion by JSRuntime")
}

abstract public class JSRuntime <: Runtime<JSRuntime> {
    private static let runtime = createRuntime()

    private static func toJSBigInt(value: String): CPointer<Unit> {
        let result = evalScript("${value}n")
        externContentToValue(result.content)
    }

    private static func toJSValue(value: Any): CPointer<Unit> {
        match (value) {
            case e: Extern<JSRuntime> =>
                externContentToValue(e.content)
            case handle: CPointer<Unit> =>
                handle
            case i: Int8 =>
                valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(i)) })
            case i: Int16 =>
                valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(i)) })
            case i: Int32 =>
                valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(i)) })
            case i: Int64 =>
                toJSBigInt("${i}")
            case i: UInt8 =>
                valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(i)) })
            case i: UInt16 =>
                valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(i)) })
            case i: UInt32 =>
                toJSBigInt("${i}")
            case i: UInt64 =>
                toJSBigInt("${i}")
            case i: BigInt =>
                toJSBigInt("${i}")
            case f: Float16 =>
                valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(f)) })
            case f: Float32 =>
                valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(f)) })
            case f: Float64 =>
                valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, f) })
            case b: Bool =>
                valueFromRuntimeHandle(runtime, unsafe { runtime_new_bool(runtime, boolAsInt64(b)) })
            case s: String =>
                let cValue = unsafe { LibC.mallocCString(s) }
                let handle = unsafe { runtime_new_string(runtime, cValue) }
                unsafe { LibC.free(cValue) }
                valueFromRuntimeHandle(runtime, handle)
            case _ => throw ExternConversionException("Unsupported type by JSRuntime")
        }
    }

    private static func toJSValues(args: Array<Any>): Array<CPointer<Unit>> {
        args.map(toJSValue)
    }

    private static func callValue(function: CPointer<Unit>, thisValue: CPointer<Unit>, args: Array<CPointer<Unit>>): CPointer<Unit> {
        let nativeArgs = args
        unsafe {
            let rawNativeArgs = acquireArrayRawData(nativeArgs)
            try {
                let result = valueFromCallHandle(runtime, value_call(function, thisValue, rawNativeArgs.pointer, Int32(args.size)))
                releaseArrayRawData(rawNativeArgs)
                return result
            } catch (e: Exception) {
                releaseArrayRawData(rawNativeArgs)
                throw e
            }
        }
    }

    private static func constructValue(constructor: CPointer<Unit>, args: Array<CPointer<Unit>>): CPointer<Unit> {
        let nativeArgs = args
        unsafe {
            let rawNativeArgs = acquireArrayRawData(nativeArgs)
            try {
                let result = valueFromCallHandle(runtime, value_construct(constructor, rawNativeArgs.pointer, Int32(args.size)))
                releaseArrayRawData(rawNativeArgs)
                return result
            } catch (e: Exception) {
                releaseArrayRawData(rawNativeArgs)
                throw e
            }
        }
    }

    public static func evalScript(source: String): Extern<JSRuntime> {
        let cSource = unsafe { LibC.mallocCString(source) }
        let value = unsafe { runtime_eval_value(runtime, cSource) }
        unsafe { LibC.free(cSource) }
        if (value.isNull()) {
            throw ExternDynamicException(runtimeError(runtime))
        }

        Extern<JSRuntime>(value)
    }

    public static func enableStdModule(): Unit {
        let status = unsafe { runtime_enable_std_module(runtime) }
        if (status != 0) {
            throw ExternDynamicException(runtimeError(runtime))
        }
    }

    public static func globalAccess(name: String): Extern<JSRuntime> {
        let cName = unsafe { LibC.mallocCString(name) }
        let value = unsafe { runtime_get_global_property(runtime, cName) }
        unsafe { LibC.free(cName) }
        if (value.isNull()) {
            throw ExternDynamicException(runtimeError(runtime))
        }

        Extern<JSRuntime>(value)
    }

    public static func getModule(moduleName: String): Extern<JSRuntime> {
        let cPath = unsafe { LibC.mallocCString(moduleName) }
        let namespace = unsafe { runtime_import_module(runtime, cPath) }
        unsafe { LibC.free(cPath) }
        if (namespace.isNull()) {
            throw ExternDynamicException(runtimeError(runtime))
        }

        Extern<JSRuntime>(namespace)
    }

    public static func memberAccess(e: Extern<JSRuntime>, field: String): Extern<JSRuntime> {
        match (e.content) {
            case value: CPointer<Unit> =>
                let fieldValue = getProperty(value, field)
                if (valueIsFunction(fieldValue)) {
                    Extern<JSRuntime>((fieldValue, value))
                } else {
                    Extern<JSRuntime>(fieldValue)
                }
            case _ => throw ExternDynamicException("Unsupported member access")
        }
    }

    public static func functionCall(e: Extern<JSRuntime>, args: Array<Any>): Extern<JSRuntime> {
        match (e.content) {
            case methodAndThis: (CPointer<Unit>, CPointer<Unit>) =>
                let jsArgs = toJSValues(args)
                try {
                    return Extern<JSRuntime>(callValue(methodAndThis[0], methodAndThis[1], jsArgs))
                } catch (_) {
                    return Extern<JSRuntime>(constructValue(methodAndThis[0], jsArgs))
                }
            case value: CPointer<Unit> =>
                let jsArgs = toJSValues(args)
                try {
                    return Extern<JSRuntime>(callValue(value, CPointer<Unit>(), jsArgs))
                } catch (_) {
                    return Extern<JSRuntime>(constructValue(value, jsArgs))
                }
            case _ => throw ExternDynamicException("Expected function or class")
        }
    }

    public static func memberUpdate(e: Extern<JSRuntime>, field: String, value: Any): Unit {
        match (e.content) {
            case target: CPointer<Unit> =>
                setProperty(target, field, toJSValue(value))
            case _ => throw ExternDynamicException("Unsupported assignment")
        }
    }

    public static func indexAccess(e: Extern<JSRuntime>, arg: Any): Extern<JSRuntime> {
        match (e.content) {
            case value: CPointer<Unit> =>
                match (arg) {
                    case key: String => Extern<JSRuntime>(getProperty(value, key))
                    case _ => Extern<JSRuntime>(getIndex(value, jsIndex(arg)))
                }
            case _ => throw ExternDynamicException("Expected JavaScript array or object")
        }
    }

    public static func indexUpdate(e: Extern<JSRuntime>, arg: Any, value: Any): Unit {
        match (e.content) {
            case target: CPointer<Unit> =>
                match (arg) {
                    case key: String => setProperty(target, key, toJSValue(value))
                    case _ => setIndex(target, jsIndex(arg), toJSValue(value))
                }
            case _ => throw ExternDynamicException("Expected JavaScript array or object")
        }
    }

    public static func fromExtern<T>(e: Extern<JSRuntime>): T {
        let dummy: Option<T> = None
        quickJS2Cangjie(externContentToValue(e.content), dummy)
    }

    public static func toExtern<T>(value: T): Extern<JSRuntime> {
        Extern<JSRuntime>(toJSValue(value))
    }

    public static func close(e: Extern<JSRuntime>): Unit {
        closeExtern(e)
    }
}
