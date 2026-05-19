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

    try (runtime = JSRuntime()) {
        try (value = JSValue.bool(runtime, true)) {
            if (!value.isBool() || !value.asBool()) {
                println("unexpected Cangjie bool JSValue conversion")
                return 3
            }
        }

        try (value = JSValue.int64(runtime, 42)) {
            if (!value.isNumber() || value.asFloat64() != 42.0) {
                println("unexpected Cangjie Int64 JSValue conversion")
                return 4
            }
        }

        try (value = JSValue.string(runtime, "hello")) {
            if (!value.isString() || value.asString() != "hello") {
                println("unexpected Cangjie string JSValue conversion")
                return 5
            }
        }

        try (nullValue = JSValue.null(runtime)) {
            try (undefinedValue = JSValue.undefined(runtime)) {
                if (!nullValue.isNull() || !undefinedValue.isUndefined()) {
                    println("unexpected Cangjie null/undefined JSValue conversion")
                    return 6
                }
            }
        }

        println("runtime created")
        println("runtime eval: 1 + 2")
        try (result = runtime.evalScript("1 + 2")) {
            println("result: ${result.isOk()} - ${result.asFloat64()}")
            if (!result.isOk() || !result.isNumber()) {
                println("unexpected eval error: ${result.errorMessage()}")
                return 7
            }
            if (result.asFloat64() != 3.0) {
                println("unexpected eval result")
                return 8
            }
        }

        try (boolResult = runtime.evalScript("true")) {
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
        }

        try (first = runtime.evalScript("'hello'")) {
            try (second = runtime.evalScript("'world'")) {
                if (first.asString() != "hello" || second.asString() != "world") {
                    println("native value handles were overwritten by later eval")
                    return 11
                }
            }
        }

        try (stringResult = runtime.evalScript("'hello from js'")) {
            if (!stringResult.isOk() || !stringResult.isString() || stringResult.asString() != "hello from js") {
                println("unexpected string eval result")
                return 12
            }
        }

        try (nullResult = runtime.evalScript("null")) {
            if (!nullResult.isOk() || !nullResult.isNull()) {
                println("unexpected null eval result")
                return 13
            }
        }

        try (undefinedResult = runtime.evalScript("undefined")) {
            if (!undefinedResult.isOk() || !undefinedResult.isUndefined()) {
                println("unexpected undefined eval result")
                return 14
            }
        }

        try (bigIntResult = runtime.evalScript("9007199254740993n")) {
            if (!bigIntResult.isOk() || !bigIntResult.isBigInt() || bigIntResult.asString() != "9007199254740993") {
                println("unexpected bigint eval result")
                return 15
            }
        }

        try (objectResult = runtime.evalScript("({ name: 'handle only for now' })")) {
            if (!objectResult.isOk() || !objectResult.isObject()) {
                println("object eval did not return a native value handle")
                return 16
            }
        }

        try (value = JSValue.bool(runtime, true)) {
            runtime.setGlobal("fromCangjieBool", value)
        }
        try (result = runtime.evalScript("fromCangjieBool")) {
            if (!result.asBool()) {
                println("Cangjie bool global did not round trip")
                return 17
            }
        }

        try (value = JSValue.int64(runtime, 42)) {
            runtime.setGlobal("fromCangjieInt", value)
        }
        try (result = runtime.evalScript("fromCangjieInt + 1")) {
            if (result.asFloat64() != 43.0) {
                println("Cangjie Int64 global did not round trip")
                return 18
            }
        }

        try (value = JSValue.float64(runtime, 1.5)) {
            runtime.setGlobal("fromCangjieFloat", value)
        }
        try (result = runtime.evalScript("fromCangjieFloat + 0.5")) {
            if (result.asFloat64() != 2.0) {
                println("Cangjie Float64 global did not round trip")
                return 19
            }
        }

        try (value = JSValue.string(runtime, "hello")) {
            runtime.setGlobal("fromCangjieString", value)
        }
        try (result = runtime.evalScript("fromCangjieString + ' js'")) {
            if (result.asString() != "hello js") {
                println("Cangjie string global did not round trip")
                return 20
            }
        }

        try (value = JSValue.null(runtime)) {
            runtime.setGlobal("fromCangjieNull", value)
        }
        try (result = runtime.evalScript("fromCangjieNull")) {
            if (!result.isNull()) {
                println("Cangjie null global did not round trip")
                return 21
            }
        }

        try (value = JSValue.undefined(runtime)) {
            runtime.setGlobal("fromCangjieUndefined", value)
        }
        try (result = runtime.evalScript("fromCangjieUndefined")) {
            if (!result.isUndefined()) {
                println("Cangjie undefined global did not round trip")
                return 22
            }
        }

        println("runtime eval: function {")
        try (syntaxError = runtime.evalScript("function {")) {
            println("syntaxError: ${syntaxError.isOk()} - ${syntaxError.errorMessage()}")
            if (syntaxError.isOk()) {
                println("invalid JavaScript unexpectedly succeeded")
                return 23
            }
            if (syntaxError.errorMessage().isEmpty()) {
                println("missing JavaScript syntax error message")
                return 24
            }
        }
    } catch (e: Exception) {
        println("runtime test failed: ${e.toString()}")
        return 25
    }

    println("runtime eval: repeated runtime creation and eval 100 times")
    for (_ in 0..100) {
        try (runtime = JSRuntime()) {
            try (result = runtime.evalScript("1 + 2")) {
                if (!result.isOk() || result.asFloat64() != 3.0) {
                    println("repeated eval failed")
                    return 26
                }
            }
        }
    }
    println("runtime eval: repeated runtime creation and eval 100 times completed")

    println(jsInteropSmokeTest())
    return 0
}