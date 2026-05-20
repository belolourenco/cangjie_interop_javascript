package interop_javascript.jsinterop

import std.collection.*

foreign func quickjs_runtime_create(): CPointer<Unit>
foreign func quickjs_runtime_destroy(handle: CPointer<Unit>): Unit
foreign func quickjs_runtime_last_error(handle: CPointer<Unit>): CString
foreign func quickjs_runtime_enable_std_module(handle: CPointer<Unit>): Int64

foreign func quickjs_runtime_eval_value(handle: CPointer<Unit>, source: CString): CPointer<Unit>
foreign func quickjs_runtime_new_undefined(handle: CPointer<Unit>): CPointer<Unit>
foreign func quickjs_runtime_new_null(handle: CPointer<Unit>): CPointer<Unit>
foreign func quickjs_runtime_new_bool(handle: CPointer<Unit>, value: Int64): CPointer<Unit>
foreign func quickjs_runtime_new_number(handle: CPointer<Unit>, value: Float64): CPointer<Unit>
foreign func quickjs_runtime_new_string(handle: CPointer<Unit>, value: CString): CPointer<Unit>
foreign func quickjs_runtime_set_global_value(handle: CPointer<Unit>, name: CString, value: CPointer<Unit>): Int64
foreign func quickjs_runtime_import_module(handle: CPointer<Unit>, path: CString): CPointer<Unit>

foreign func quickjs_value_destroy(handle: CPointer<Unit>): Unit
foreign func quickjs_value_kind(handle: CPointer<Unit>): Int64
foreign func quickjs_value_to_bool(handle: CPointer<Unit>): Int64
foreign func quickjs_value_to_number(handle: CPointer<Unit>): Float64
foreign func quickjs_value_to_string(handle: CPointer<Unit>): CString
foreign func quickjs_bridge_free_string(value: CString): Unit
foreign func quickjs_value_is_array(handle: CPointer<Unit>): Int64
foreign func quickjs_value_array_length(handle: CPointer<Unit>): Int64
foreign func quickjs_value_get_property(handle: CPointer<Unit>, name: CString): CPointer<Unit>
foreign func quickjs_value_set_property(handle: CPointer<Unit>, name: CString, value: CPointer<Unit>): Int64
foreign func quickjs_value_get_index(handle: CPointer<Unit>, index: Int64): CPointer<Unit>
foreign func quickjs_value_set_index(handle: CPointer<Unit>, index: Int64, value: CPointer<Unit>): Int64
foreign func quickjs_value_key_count(handle: CPointer<Unit>): Int64
foreign func quickjs_value_key_at(handle: CPointer<Unit>, index: Int64): CString
foreign func quickjs_value_runtime_last_error(handle: CPointer<Unit>): CString
foreign func quickjs_value_is_function(handle: CPointer<Unit>): Int64
foreign func quickjs_value_call0(function: CPointer<Unit>): CPointer<Unit>
foreign func quickjs_value_call1(function: CPointer<Unit>, arg0: CPointer<Unit>): CPointer<Unit>
foreign func quickjs_value_call2(function: CPointer<Unit>, arg0: CPointer<Unit>, arg1: CPointer<Unit>): CPointer<Unit>
foreign func quickjs_value_call_method0(function: CPointer<Unit>, thisValue: CPointer<Unit>): CPointer<Unit>
foreign func quickjs_value_call_method1(function: CPointer<Unit>, thisValue: CPointer<Unit>, arg0: CPointer<Unit>): CPointer<Unit>
foreign func quickjs_value_call_method2(function: CPointer<Unit>, thisValue: CPointer<Unit>, arg0: CPointer<Unit>, arg1: CPointer<Unit>): CPointer<Unit>
foreign func quickjs_value_construct(function: CPointer<Unit>, args: CPointer<CPointer<Unit>>, numArgs: Int32): CPointer<Unit>

public func jsInteropVersion(): String {
    "0.1.0-phase7"
}

public func jsInteropSmokeTest(): String {
    "jsinterop phase7 ok"
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

func jsValueFunctionKind(): Int64 {
    7
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

    public func isFunction(): Bool {
        ensureOpen()
        valueKind() == jsValueFunctionKind() || unsafe { quickjs_value_is_function(handle) != 0 }
    }

    public func isArray(): Bool {
        ensureOpen()
        unsafe { quickjs_value_is_array(handle) != 0 }
    }

    public func typeOf(): String {
        if (isUndefined()) {
            return "undefined"
        }
        if (isNull()) {
            return "null"
        }
        if (isBool()) {
            return "boolean"
        }
        if (isNumber()) {
            return "number"
        }
        if (isString()) {
            return "string"
        }
        if (isBigInt()) {
            return "bigint"
        }
        if (isFunction()) {
            return "function"
        }
        if (isArray()) {
            return "array"
        }
        if (isObject()) {
            return "object"
        }

        "unknown"
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

    public func asObject(): JSObject {
        if (!isObject()) {
            throw Exception("JavaScript value is not an object")
        }

        JSObject(this)
    }

    public func asArray(): JSArray {
        if (!isArray()) {
            throw Exception("JavaScript value is not an array")
        }

        JSArray(this)
    }

    public func asFunction(): JSFunction {
        if (!isFunction()) {
            throw Exception("JavaScript value is not a function")
        }

        JSFunction(this)
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

    public func isFunction(): Bool {
        value.isFunction()
    }

    public func isArray(): Bool {
        value.isArray()
    }

    public func typeOf(): String {
        value.typeOf()
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

    public func asObject(): JSObject {
        value.asObject()
    }

    public func asArray(): JSArray {
        value.asArray()
    }

    public func asFunction(): JSFunction {
        value.asFunction()
    }

    public func asValue(): JSValue {
        value
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

public class JSObject {
    let value: JSValue

    public init(value: JSValue) {
        this.value = value
    }

    public func get(name: String): JSValue {
        value.ensureOpen()
        let cName = unsafe { LibC.mallocCString(name) }
        let result = unsafe { quickjs_value_get_property(value.nativeHandle(), cName) }
        unsafe { LibC.free(cName) }
        if (result.isNull()) {
            throw Exception("failed to read JavaScript property")
        }

        JSValue(result)
    }

    public func getBool(name: String): Bool {
        let propertyValue = get(name)
        let result = propertyValue.asBool()
        propertyValue.close()
        result
    }

    public func getFloat64(name: String): Float64 {
        let propertyValue = get(name)
        let result = propertyValue.asFloat64()
        propertyValue.close()
        result
    }

    public func getString(name: String): String {
        let propertyValue = get(name)
        let result = propertyValue.asString()
        propertyValue.close()
        result
    }

    public func getArray(name: String): JSValue {
        let propertyValue = get(name)
        if (!propertyValue.isArray()) {
            propertyValue.close()
            throw Exception("JavaScript property is not an array")
        }

        propertyValue
    }

    public func call(name: String, args: Array<JSValue>): JSValue {
        let functionValue = get(name)
        let function = functionValue.asFunction()
        let result = function.callWithThis(value, args)
        functionValue.close()
        result
    }

    public func construct(name: String, args: Array<JSValue>): JSValue {
        let constructorValue = get(name)
        let constructor = constructorValue.asFunction()
        let result = constructor.construct(args)
        constructorValue.close()
        result
    }

    public func set(name: String, propertyValue: JSValue): Unit {
        value.ensureOpen()
        let cName = unsafe { LibC.mallocCString(name) }
        let status = unsafe { quickjs_value_set_property(value.nativeHandle(), cName, propertyValue.nativeHandle()) }
        unsafe { LibC.free(cName) }
        if (status != 0) {
            throw Exception("failed to write JavaScript property")
        }
    }

    public func keys(): ArrayList<String> {
        value.ensureOpen()
        let count = unsafe { quickjs_value_key_count(value.nativeHandle()) }
        if (count < 0) {
            throw Exception("failed to enumerate JavaScript object keys")
        }

        let result = ArrayList<String>()
        for (index in 0..count) {
            let key = unsafe { quickjs_value_key_at(value.nativeHandle(), index) }
            if (key.isNull()) {
                throw Exception("failed to read JavaScript object key")
            }
            result.add(ownedCStringToString(key))
        }

        result
    }
}

public class JSArray {
    let value: JSValue

    public init(value: JSValue) {
        this.value = value
    }

    public func length(): Int64 {
        value.ensureOpen()
        let length = unsafe { quickjs_value_array_length(value.nativeHandle()) }
        if (length < 0) {
            throw Exception("failed to read JavaScript array length")
        }

        length
    }

    public func get(index: Int64): JSValue {
        value.ensureOpen()
        if (index < 0 || index >= length()) {
            throw Exception("JavaScript array index is out of range")
        }

        let result = unsafe { quickjs_value_get_index(value.nativeHandle(), index) }
        if (result.isNull()) {
            throw Exception("failed to read JavaScript array index")
        }

        JSValue(result)
    }

    public func getBool(index: Int64): Bool {
        let element = get(index)
        let result = element.asBool()
        element.close()
        result
    }

    public func getFloat64(index: Int64): Float64 {
        let element = get(index)
        let result = element.asFloat64()
        element.close()
        result
    }

    public func getString(index: Int64): String {
        let element = get(index)
        let result = element.asString()
        element.close()
        result
    }

    public func getArray(index: Int64): JSValue {
        let element = get(index)
        if (!element.isArray()) {
            element.close()
            throw Exception("JavaScript array element is not an array")
        }

        element
    }

    public func set(index: Int64, element: JSValue): Unit {
        value.ensureOpen()
        if (index < 0) {
            throw Exception("JavaScript array index is out of range")
        }

        let status = unsafe { quickjs_value_set_index(value.nativeHandle(), index, element.nativeHandle()) }
        if (status != 0) {
            throw Exception("failed to write JavaScript array index")
        }
    }
}

public class JSFunction {
    let value: JSValue

    public init(value: JSValue) {
        this.value = value
    }

    func runtimeError(): String {
        unsafe { quickjs_value_runtime_last_error(value.nativeHandle()).toString() }
    }

    func valueFromCallResult(result: CPointer<Unit>): JSValue {
        if (result.isNull()) {
            let error = runtimeError()
            if (error.isEmpty()) {
                throw Exception("JavaScript function call failed")
            }
            throw Exception(error)
        }

        JSValue(result)
    }

    public func call(args: Array<JSValue>): JSValue {
        value.ensureOpen()
        if (args.size == 0) {
            return valueFromCallResult(unsafe { quickjs_value_call0(value.nativeHandle()) })
        }
        if (args.size == 1) {
            return valueFromCallResult(unsafe { quickjs_value_call1(value.nativeHandle(), args[0].nativeHandle()) })
        }
        if (args.size == 2) {
            return valueFromCallResult(unsafe { quickjs_value_call2(value.nativeHandle(), args[0].nativeHandle(), args[1].nativeHandle()) })
        }

        throw Exception("JavaScript function calls support up to two arguments in Phase 5")
    }

    public func callWithThis(thisValue: JSValue, args: Array<JSValue>): JSValue {
        value.ensureOpen()
        thisValue.ensureOpen()
        if (args.size == 0) {
            return valueFromCallResult(unsafe { quickjs_value_call_method0(value.nativeHandle(), thisValue.nativeHandle()) })
        }
        if (args.size == 1) {
            return valueFromCallResult(unsafe { quickjs_value_call_method1(value.nativeHandle(), thisValue.nativeHandle(), args[0].nativeHandle()) })
        }
        if (args.size == 2) {
            return valueFromCallResult(unsafe { quickjs_value_call_method2(value.nativeHandle(), thisValue.nativeHandle(), args[0].nativeHandle(), args[1].nativeHandle()) })
        }

        throw Exception("JavaScript method calls support up to two arguments in Phase 5")
    }

    public func construct(args: Array<JSValue>): JSValue {
        value.ensureOpen()
        let nativeArgs = args.map { it => it.nativeHandle() }
        unsafe {
            let rawNativeArgs = acquireArrayRawData(nativeArgs) 
            try {
                let result = valueFromCallResult(quickjs_value_construct(value.nativeHandle(), rawNativeArgs.pointer, Int32(args.size)))
                releaseArrayRawData(rawNativeArgs)
                return result
            } catch (e: Exception) {
                releaseArrayRawData(rawNativeArgs)
                throw e
            }
        }

        throw Exception("JavaScript constructors support up to two arguments in Phase 5")
    }
}

public class JSModule <: Resource {
    let namespace: JSValue

    public init(namespace: JSValue) {
        this.namespace = namespace
    }

    ~init() {
        namespace.close()
    }

    public func get(name: String): JSValue {
        namespace.asObject().get(name)
    }

    public func getBool(name: String): Bool {
        namespace.asObject().getBool(name)
    }

    public func getFloat64(name: String): Float64 {
        namespace.asObject().getFloat64(name)
    }

    public func getString(name: String): String {
        namespace.asObject().getString(name)
    }

    public func getArray(name: String): JSValue {
        namespace.asObject().getArray(name)
    }

    public func call(name: String, args: Array<JSValue>): JSValue {
        namespace.asObject().call(name, args)
    }

    public func construct(name: String, args: Array<JSValue>): JSValue {
        namespace.asObject().construct(name, args)
    }

    public func keys(): ArrayList<String> {
        namespace.asObject().keys()
    }

    public func isClosed(): Bool {
        namespace.isClosed()
    }

    public func close(): Unit {
        namespace.close()
    }
}

public class JSRuntime <: Resource {
    var handle: CPointer<Unit> = CPointer<Unit>()
    var closed: Bool = true
    let moduleRoot: String

    public init() {
        this.moduleRoot = "."
        let created = unsafe { quickjs_runtime_create() }
        if (created.isNull()) {
            throw Exception("failed to create QuickJS runtime")
        }

        handle = created
        closed = false
    }

    public init(moduleRoot: String) {
        this.moduleRoot = moduleRoot
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

    func resolveModulePath(path: String): String {
        if (moduleRoot.isEmpty() || moduleRoot == ".") {
            return path
        }

        "${moduleRoot}/${path}"
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

    public func enableStdModule(): Unit {
        ensureOpen()
        let status = unsafe { quickjs_runtime_enable_std_module(handle) }
        if (status != 0) {
            throw Exception(runtimeError())
        }
    }

    public func importModule(path: String): JSModule {
        ensureOpen()
        let resolvedPath = resolveModulePath(path)
        let cPath = unsafe { LibC.mallocCString(resolvedPath) }
        let namespaceHandle = unsafe { quickjs_runtime_import_module(handle, cPath) }
        unsafe { LibC.free(cPath) }
        if (namespaceHandle.isNull()) {
            throw Exception(runtimeError())
        }

        JSModule(JSValue(namespaceHandle))
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
