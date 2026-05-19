package interop_javascript_smoke

import interop_javascript.jsinterop.*

main(): Int64 {
    if (jsInteropVersion() != "0.1.0-phase2") {
        println("unexpected jsinterop version")
        return 1
    }

    if (jsInteropSmokeTest() != "jsinterop phase2 ok") {
        println("unexpected jsinterop smoke message")
        return 2
    }

    try (runtime = JSRuntime()) {
        println("runtime created")
        println("runtime eval: 1 + 2")
        let result = runtime.evalScript("1 + 2")
        println("result: ${result.isOk()} - ${result.asFloat64()}")
        if (!result.isOk()) {
            println("unexpected eval error: ${result.errorMessage()}")
            return 3
        }
        if (result.asFloat64() != 3.0) {
            println("unexpected eval result")
            return 4
        }

        println("runtime eval: function {")
        let syntaxError = runtime.evalScript("function {")
        println("syntaxError: ${syntaxError.isOk()} - ${syntaxError.errorMessage()}")
        if (syntaxError.isOk()) {
            println("invalid JavaScript unexpectedly succeeded")
            return 5
        }
        if (syntaxError.errorMessage().isEmpty()) {
            println("missing JavaScript syntax error message")
            return 6
        }
    }

    println("runtime eval: repeated runtime creation and eval 100 times")
    for (_ in 0..100) {
        try (runtime = JSRuntime()) {
            let result = runtime.evalScript("1 + 2")
            if (!result.isOk() || result.asFloat64() != 3.0) {
                println("repeated eval failed")
                return 7
            }
        }
    }
    println("runtime eval: repeated runtime creation and eval 100 times completed")

    println(jsInteropSmokeTest())
    return 0
}
