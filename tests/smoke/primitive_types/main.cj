package interop_javascript_smoke_primitive_types

import interop_javascript.jsinterop.*

main(): Int64 {
    if (jsInteropVersion() != "0.1.0-phase7") {
        println("unexpected jsinterop version")
        return 1
    }

    if (jsInteropSmokeTest() != "jsinterop phase7 ok") {
        println("unexpected jsinterop smoke message")
        return 2
    }

    let runtime = JSRuntime(".")

    let boolValue = JSValue.bool(runtime, true)
    if (!boolValue.isBool() || !boolValue.asBool()) {
        println("unexpected Cangjie bool JSValue conversion")
        return 3
    }
    boolValue.close()

    let intValue = JSValue.int64(runtime, 42)
    if (!intValue.isNumber() || intValue.asFloat64() != 42.0) {
        println("unexpected Cangjie Int64 JSValue conversion")
        return 4
    }
    intValue.close()

    let stringValue = JSValue.string(runtime, "hello")
    if (!stringValue.isString() || stringValue.asString() != "hello") {
        println("unexpected Cangjie string JSValue conversion")
        return 5
    }
    stringValue.close()

    let nullValue = JSValue.null(runtime)
    let undefinedValue = JSValue.undefined(runtime)
    if (!nullValue.isNull() || !undefinedValue.isUndefined()) {
        println("unexpected Cangjie null/undefined JSValue conversion")
        return 6
    }
    nullValue.close()
    undefinedValue.close()

    let numberResult = runtime.evalScript("1 + 2")
    if (!numberResult.isOk() || !numberResult.isNumber() || numberResult.asFloat64() != 3.0) {
        println("unexpected numeric eval result")
        return 7
    }
    numberResult.close()

    let boolResult = runtime.evalScript("true")
    if (!boolResult.isOk() || !boolResult.isBool() || !boolResult.asBool()) {
        println("unexpected boolean eval result")
        return 8
    }

    try {
        boolResult.asFloat64()
        println("boolean converted to number unexpectedly")
        return 9
    } catch (_) {
        ()
    }
    boolResult.close()

    let firstStringResult = runtime.evalScript("'hello'")
    let secondStringResult = runtime.evalScript("'world'")
    if (firstStringResult.asString() != "hello" || secondStringResult.asString() != "world") {
        println("native value handles were overwritten by later eval")
        return 10
    }
    firstStringResult.close()
    secondStringResult.close()

    let stringResult = runtime.evalScript("'hello from js'")
    if (!stringResult.isOk() || !stringResult.isString() || stringResult.asString() != "hello from js") {
        println("unexpected string eval result")
        return 11
    }
    stringResult.close()

    let nullResult = runtime.evalScript("null")
    if (!nullResult.isOk() || !nullResult.isNull()) {
        println("unexpected null eval result")
        return 12
    }
    nullResult.close()

    let undefinedResult = runtime.evalScript("undefined")
    if (!undefinedResult.isOk() || !undefinedResult.isUndefined()) {
        println("unexpected undefined eval result")
        return 13
    }
    undefinedResult.close()

    let bigIntResult = runtime.evalScript("9007199254740993n")
    if (!bigIntResult.isOk() || !bigIntResult.isBigInt() || bigIntResult.asString() != "9007199254740993") {
        println("unexpected bigint eval result")
        return 14
    }
    bigIntResult.close()

    let globalBool = JSValue.bool(runtime, true)
    runtime.setGlobal("fromCangjieBool", globalBool)
    globalBool.close()
    let globalBoolResult = runtime.evalScript("fromCangjieBool")
    if (!globalBoolResult.asBool()) {
        println("Cangjie bool global did not round trip")
        return 15
    }
    globalBoolResult.close()

    let globalInt = JSValue.int64(runtime, 42)
    runtime.setGlobal("fromCangjieInt", globalInt)
    globalInt.close()
    let globalIntResult = runtime.evalScript("fromCangjieInt + 1")
    if (globalIntResult.asFloat64() != 43.0) {
        println("Cangjie Int64 global did not round trip")
        return 16
    }
    globalIntResult.close()

    let globalFloat = JSValue.float64(runtime, 1.5)
    runtime.setGlobal("fromCangjieFloat", globalFloat)
    globalFloat.close()
    let globalFloatResult = runtime.evalScript("fromCangjieFloat + 0.5")
    if (globalFloatResult.asFloat64() != 2.0) {
        println("Cangjie Float64 global did not round trip")
        return 17
    }
    globalFloatResult.close()

    let globalString = JSValue.string(runtime, "hello")
    runtime.setGlobal("fromCangjieString", globalString)
    globalString.close()
    let globalStringResult = runtime.evalScript("fromCangjieString + ' js'")
    if (globalStringResult.asString() != "hello js") {
        println("Cangjie string global did not round trip")
        return 18
    }
    globalStringResult.close()

    let globalNull = JSValue.null(runtime)
    runtime.setGlobal("fromCangjieNull", globalNull)
    globalNull.close()
    let globalNullResult = runtime.evalScript("fromCangjieNull")
    if (!globalNullResult.isNull()) {
        println("Cangjie null global did not round trip")
        return 19
    }
    globalNullResult.close()

    let globalUndefined = JSValue.undefined(runtime)
    runtime.setGlobal("fromCangjieUndefined", globalUndefined)
    globalUndefined.close()
    let globalUndefinedResult = runtime.evalScript("fromCangjieUndefined")
    if (!globalUndefinedResult.isUndefined()) {
        println("Cangjie undefined global did not round trip")
        return 20
    }
    globalUndefinedResult.close()

    runtime.close()

    println("primitive_types ok")
    return 0
}

