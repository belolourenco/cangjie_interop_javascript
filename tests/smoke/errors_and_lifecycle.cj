package interop_javascript_smoke

import interop_javascript.jsinterop.*

func runErrorsAndLifecycleSmoke(): Int64 {
    let runtime = JSRuntime(".")

    let throwingFunctionValue = runtime.evalScript("function fail() { throw new Error('function failed') }; fail")
    let fail = throwingFunctionValue.asFunction()
    try {
        let unexpected = fail.call([])
        unexpected.close()
        println("throwing function unexpectedly succeeded")
        return 1
    } catch (e: Exception) {
        if (!e.toString().contains("function failed")) {
            println("throwing function error message was not preserved")
            return 2
        }
    }
    throwingFunctionValue.close()

    let throwingConstructorValue = runtime.evalScript("class Broken { constructor() { throw new Error('constructor failed') } }; Broken")
    let broken = throwingConstructorValue.asFunction()
    try {
        let unexpected = broken.construct([])
        unexpected.close()
        println("throwing constructor unexpectedly succeeded")
        return 3
    } catch (e: Exception) {
        if (!e.toString().contains("constructor failed")) {
            println("throwing constructor error message was not preserved")
            return 4
        }
    }
    throwingConstructorValue.close()

    try {
        let unexpected = runtime.importModule("tests/smoke/js_examples/nok/missing_module.js")
        unexpected.close()
        println("missing module unexpectedly loaded")
        return 5
    } catch (e: Exception) {
        if (!e.toString().contains("failed to read JavaScript module file")) {
            println("missing module error message was not preserved")
            return 6
        }
    }

    try {
        let unexpected = runtime.importModule("tests/smoke/js_examples/nok/broken_module.js")
        unexpected.close()
        println("broken module unexpectedly loaded")
        return 7
    } catch (e: Exception) {
        if (e.toString().isEmpty()) {
            println("broken module error message was not preserved")
            return 8
        }
    }

    let syntaxError = runtime.evalScript("function {")
    if (syntaxError.isOk()) {
        println("invalid JavaScript unexpectedly succeeded")
        return 9
    }
    if (syntaxError.errorMessage().isEmpty()) {
        println("missing JavaScript syntax error message")
        return 10
    }
    syntaxError.close()
    runtime.close()

    for (_ in 0..100) {
        let repeatedRuntime = JSRuntime()
        let result = repeatedRuntime.evalScript("1 + 2")
        if (!result.isOk() || result.asFloat64() != 3.0) {
            println("repeated eval failed")
            return 11
        }
        result.close()
        repeatedRuntime.close()
    }

    println("errors_and_lifecycle ok")
    return 0
}
