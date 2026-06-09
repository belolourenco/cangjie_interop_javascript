package interop_javascript

import std.math.numeric.BigInt

foreign func runtime_create(): CPointer<Unit>
foreign func runtime_destroy(handle: CPointer<Unit>): Unit
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

private class JSRuntimeRef {
    private let handle: CPointer<Unit>

    init(handle: CPointer<Unit>) {
        this.handle = handle
    }

    func pointer(): CPointer<Unit> {
        handle
    }

    ~init() {
        unsafe { runtime_destroy(handle) }
    }
}

private class JSValueRef {
    private let handle: CPointer<Unit>

    init(handle: CPointer<Unit>) {
        this.handle = handle
    }

    func pointer(): CPointer<Unit> {
        handle
    }

    ~init() {
        unsafe { value_destroy(handle) }
    }
}

private class JSMethodRef {
    let function: JSValueRef
    let receiver: JSValueRef

    init(function: JSValueRef, receiver: JSValueRef) {
        this.function = function
        this.receiver = receiver
    }
}

private func jsExtern(handle: CPointer<Unit>): Extern<JSRuntime> {
    Extern<JSRuntime>(JSValueRef(handle))
}

private func jsExtern(ref: JSValueRef): Extern<JSRuntime> {
    Extern<JSRuntime>(ref)
}

private func jsExtern(method: JSMethodRef): Extern<JSRuntime> {
    Extern<JSRuntime>(method)
}

private func externContentToRef(content: Any): JSValueRef {
    match (content) {
        case value: JSValueRef => value
        case value: CPointer<Unit> => JSValueRef(value)
        case _ => throw ExternConversionException("Extern value does not contain a JavaScript value")
    }
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
    externContentToRef(content).pointer()
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
    private static let runtimeOwner = JSRuntimeRef(createRuntime())
    private static let runtime = runtimeOwner.pointer()

    private static func toJSBigInt(value: String): JSValueRef {
        let result = evalScript("${value}")
        externContentToRef(getPayload(result))
    }

    private static func toJSValue(value: Any): JSValueRef {
        match (value) {
            case e: Extern<JSRuntime> =>
                externContentToRef(getPayload(e))
            case handle: CPointer<Unit> =>
                JSValueRef(handle)
            case i: Int8 =>
                JSValueRef(valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(i)) }))
            case i: Int16 =>
                JSValueRef(valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(i)) }))
            case i: Int32 =>
                JSValueRef(valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(i)) }))
            case i: Int64 =>
                toJSBigInt("${i}")
            case i: UInt8 =>
                JSValueRef(valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(i)) }))
            case i: UInt16 =>
                JSValueRef(valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(i)) }))
            case i: UInt32 =>
                toJSBigInt("${i}")
            case i: UInt64 =>
                toJSBigInt("${i}")
            case i: BigInt =>
                toJSBigInt("${i}")
            case f: Float16 =>
                JSValueRef(valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(f)) }))
            case f: Float32 =>
                JSValueRef(valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, Float64(f)) }))
            case f: Float64 =>
                JSValueRef(valueFromRuntimeHandle(runtime, unsafe { runtime_new_number(runtime, f) }))
            case b: Bool =>
                JSValueRef(valueFromRuntimeHandle(runtime, unsafe { runtime_new_bool(runtime, boolAsInt64(b)) }))
            case s: String =>
                let cValue = unsafe { LibC.mallocCString(s) }
                let handle = unsafe { runtime_new_string(runtime, cValue) }
                unsafe { LibC.free(cValue) }
                JSValueRef(valueFromRuntimeHandle(runtime, handle))
            case _ => throw ExternConversionException("Unsupported type by JSRuntime")
        }
    }

    private static func toJSValues(args: Array<Any>): Array<JSValueRef> {
        args.map(toJSValue)
    }

    private static func refPointer(ref: JSValueRef): CPointer<Unit> {
        ref.pointer()
    }

    private static func callValue(function: JSValueRef, thisValue: JSValueRef, args: Array<JSValueRef>): CPointer<Unit> {
        let nativeArgs = args.map(refPointer)
        unsafe {
            let rawNativeArgs = acquireArrayRawData(nativeArgs)
            try {
                let result = valueFromCallHandle(runtime, value_call(function.pointer(), thisValue.pointer(), rawNativeArgs.pointer, Int32(args.size)))
                releaseArrayRawData(rawNativeArgs)
                return result
            } catch (e: Exception) {
                releaseArrayRawData(rawNativeArgs)
                throw e
            }
        }
    }

    private static func constructValue(constructor: JSValueRef, args: Array<JSValueRef>): CPointer<Unit> {
        let nativeArgs = args.map(refPointer)
        unsafe {
            let rawNativeArgs = acquireArrayRawData(nativeArgs)
            try {
                let result = valueFromCallHandle(runtime, value_construct(constructor.pointer(), rawNativeArgs.pointer, Int32(args.size)))
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

        jsExtern(value)
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

        jsExtern(value)
    }

    public static func getModule(moduleName: String): Extern<JSRuntime> {
        let cPath = unsafe { LibC.mallocCString(moduleName) }
        let namespace = unsafe { runtime_import_module(runtime, cPath) }
        unsafe { LibC.free(cPath) }
        if (namespace.isNull()) {
            throw ExternDynamicException(runtimeError(runtime))
        }

        jsExtern(namespace)
    }

    public static func memberAccess(e: Extern<JSRuntime>, field: String): Extern<JSRuntime> {
        match (getPayload(e)) {
            case value: JSValueRef =>
                let fieldValue = getProperty(value.pointer(), field)
                if (valueIsFunction(fieldValue)) {
                    jsExtern(JSMethodRef(JSValueRef(fieldValue), value))
                } else {
                    jsExtern(fieldValue)
                }
            case _ => throw ExternDynamicException("Unsupported member access")
        }
    }

    public static func functionCall(e: Extern<JSRuntime>, args: Array<Any>): Extern<JSRuntime> {
        match (getPayload(e)) {
            case method: JSMethodRef =>
                let jsArgs = toJSValues(args)
                try {
                    return jsExtern(callValue(method.function, method.receiver, jsArgs))
                } catch (_) {
                    return jsExtern(constructValue(method.function, jsArgs))
                }
            case value: JSValueRef =>
                let jsArgs = toJSValues(args)
                try {
                    return jsExtern(callValue(value, JSValueRef(CPointer<Unit>()), jsArgs))
                } catch (_) {
                    return jsExtern(constructValue(value, jsArgs))
                }
            case _ => throw ExternDynamicException("Expected function or class")
        }
    }

    public static func memberUpdate(e: Extern<JSRuntime>, field: String, value: Any): Unit {
        match (getPayload(e)) {
            case target: JSValueRef =>
                let jsValue = toJSValue(value)
                setProperty(target.pointer(), field, jsValue.pointer())
            case _ => throw ExternDynamicException("Unsupported assignment")
        }
    }

    public static func indexAccess(e: Extern<JSRuntime>, arg: Any): Extern<JSRuntime> {
        match (getPayload(e)) {
            case value: JSValueRef =>
                match (arg) {
                    case key: String => jsExtern(getProperty(value.pointer(), key))
                    case _ => jsExtern(getIndex(value.pointer(), jsIndex(arg)))
                }
            case _ => throw ExternDynamicException("Expected JavaScript array or object")
        }
    }

    public static func indexUpdate(e: Extern<JSRuntime>, arg: Any, value: Any): Unit {
        match (getPayload(e)) {
            case target: JSValueRef =>
                match (arg) {
                    case key: String =>
                        let jsValue = toJSValue(value)
                        setProperty(target.pointer(), key, jsValue.pointer())
                    case _ =>
                        let jsValue = toJSValue(value)
                        setIndex(target.pointer(), jsIndex(arg), jsValue.pointer())
                }
            case _ => throw ExternDynamicException("Expected JavaScript array or object")
        }
    }

    public static func fromExtern<T>(e: Extern<JSRuntime>): T {
        let dummy: Option<T> = None
        quickJS2Cangjie(externContentToValue(getPayload(e)), dummy)
    }

    public static func toExtern<T>(value: T): Extern<JSRuntime> {
        jsExtern(toJSValue(value))
    }
}
