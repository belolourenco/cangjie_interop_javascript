package interop_javascript_smoke

import interop_javascript.jsinterop.*

main(): Int64 {
    if (jsInteropVersion() != "0.1.0-phase3") {
        println("unexpected jsinterop version")
        return 1
    }

    if (jsInteropSmokeTest() != "jsinterop phase3 ok") {
        println("unexpected jsinterop smoke message")
        return 2
    }

    if (!JSValue.bool(true).isBool() || !JSValue.bool(true).asBool()) {
        println("unexpected Cangjie bool JSValue conversion")
        return 3
    }

    if (!JSValue.int64(42).isNumber() || JSValue.int64(42).asFloat64() != 42.0) {
        println("unexpected Cangjie Int64 JSValue conversion")
        return 4
    }

    if (!JSValue.string("hello").isString() || JSValue.string("hello").asString() != "hello") {
        println("unexpected Cangjie string JSValue conversion")
        return 5
    }

    if (!JSValue.null().isNull() || !JSValue.undefined().isUndefined()) {
        println("unexpected Cangjie null/undefined JSValue conversion")
        return 6
    }

    try (runtime = JSRuntime()) {
        println("runtime created")
        println("runtime eval: 1 + 2")
        let result = runtime.evalScript("1 + 2")
        println("result: ${result.isOk()} - ${result.asFloat64()}")
        if (!result.isOk() || !result.isNumber()) {
            println("unexpected eval error: ${result.errorMessage()}")
            return 7
        }
        if (result.asFloat64() != 3.0) {
            println("unexpected eval result")
            return 8
        }

        let boolResult = runtime.evalScript("true")
        if (!boolResult.isOk() || !boolResult.isBool() || !boolResult.asBool()) {
            println("unexpected boolean eval result")
            return 9
        }

        try {
            boolResult.asFloat64()
            println("boolean converted to number unexpectedly")
            return 10
        } catch (_) {
            ()
        }

        let stringResult = runtime.evalScript("'hello from js'")
        if (!stringResult.isOk() || !stringResult.isString() || stringResult.asString() != "hello from js") {
            println("unexpected string eval result")
            return 11
        }

        let nullResult = runtime.evalScript("null")
        if (!nullResult.isOk() || !nullResult.isNull()) {
            println("unexpected null eval result")
            return 12
        }

        let undefinedResult = runtime.evalScript("undefined")
        if (!undefinedResult.isOk() || !undefinedResult.isUndefined()) {
            println("unexpected undefined eval result")
            return 13
        }

        let bigIntResult = runtime.evalScript("9007199254740993n")
        if (!bigIntResult.isOk() || !bigIntResult.isBigInt() || bigIntResult.asString() != "9007199254740993") {
            println("unexpected bigint eval result")
            return 14
        }

        let objectResult = runtime.evalScript("({ name: 'not phase 3' })")
        if (objectResult.isOk() || objectResult.errorMessage().isEmpty()) {
            println("unsupported object eval unexpectedly succeeded")
            return 15
        }

        runtime.setGlobal("fromCangjieBool", JSValue.bool(true))
        if (!runtime.evalScript("fromCangjieBool").asBool()) {
            println("Cangjie bool global did not round trip")
            return 16
        }

        runtime.setGlobal("fromCangjieInt", JSValue.int64(42))
        if (runtime.evalScript("fromCangjieInt + 1").asFloat64() != 43.0) {
            println("Cangjie Int64 global did not round trip")
            return 17
        }

        runtime.setGlobal("fromCangjieFloat", JSValue.float64(1.5))
        if (runtime.evalScript("fromCangjieFloat + 0.5").asFloat64() != 2.0) {
            println("Cangjie Float64 global did not round trip")
            return 18
        }

        runtime.setGlobal("fromCangjieString", JSValue.string("hello"))
        if (runtime.evalScript("fromCangjieString + ' js'").asString() != "hello js") {
            println("Cangjie string global did not round trip")
            return 19
        }

        runtime.setGlobal("fromCangjieNull", JSValue.null())
        if (!runtime.evalScript("fromCangjieNull").isNull()) {
            println("Cangjie null global did not round trip")
            return 20
        }

        runtime.setGlobal("fromCangjieUndefined", JSValue.undefined())
        if (!runtime.evalScript("fromCangjieUndefined").isUndefined()) {
            println("Cangjie undefined global did not round trip")
            return 21
        }

        println("runtime eval: function {")
        let syntaxError = runtime.evalScript("function {")
        println("syntaxError: ${syntaxError.isOk()} - ${syntaxError.errorMessage()}")
        if (syntaxError.isOk()) {
            println("invalid JavaScript unexpectedly succeeded")
            return 22
        }
        if (syntaxError.errorMessage().isEmpty()) {
            println("missing JavaScript syntax error message")
            return 23
        }
    } catch (e: Exception) {
        println("runtime creation failed: ${e.toString()}")
        return 24
    }

    println("runtime eval: repeated runtime creation and eval 100 times")
    for (_ in 0..100) {
        try (runtime = JSRuntime()) {
            let result = runtime.evalScript("1 + 2")
            if (!result.isOk() || result.asFloat64() != 3.0) {
                println("repeated eval failed")
                return 25
            }
        }
    }
    println("runtime eval: repeated runtime creation and eval 100 times completed")

    println(jsInteropSmokeTest())
    return 0
}
