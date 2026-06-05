package smoke

import interop_javascript.JSRuntime

func runErrorsAndLifecycleSmoke(): Int64 {
    let throwingFunction: Extern<JSRuntime> = JSRuntime.evalScript("function fail() { throw new Error('function failed') }; fail")
    try {
        let unexpected: Extern<JSRuntime> = JSRuntime.functionCall(throwingFunction, [])
        println("throwing function unexpectedly succeeded")
        return 1
    } catch (e: Exception) {
        if (!e.toString().contains("function failed")) {
            println("throwing function error message was not preserved")
            return 2
        }
    }

    let throwingConstructor: Extern<JSRuntime> = JSRuntime.evalScript("class Broken { constructor() { throw new Error('constructor failed') } }; Broken")
    try {
        let unexpected: Extern<JSRuntime> = JSRuntime.functionCall(throwingConstructor, [])
        println("throwing constructor unexpectedly succeeded")
        return 3
    } catch (e: Exception) {
        if (!e.toString().contains("constructor failed")) {
            println("throwing constructor error message was not preserved")
            return 4
        }
    }

    try {
        let unexpected: Extern<JSRuntime> = JSRuntime.getModule("js_examples/nok/missing_module.js")
        println("missing module unexpectedly loaded")
        return 5
    } catch (e: Exception) {
        if (!e.toString().contains("failed to read JavaScript module file")) {
            println("missing module error message was not preserved")
            return 6
        }
    }

    try {
        let unexpected: Extern<JSRuntime> = JSRuntime.getModule("js_examples/nok/broken_module.js")
        println("broken module unexpectedly loaded")
        return 7
    } catch (e: Exception) {
        if (e.toString().isEmpty()) {
            println("broken module error message was not preserved")
            return 8
        }
    }

    try {
        let unexpected: Extern<JSRuntime> = JSRuntime.evalScript("function {")
        println("invalid JavaScript unexpectedly succeeded")
        return 9
    } catch (e: Exception) {
        if (e.toString().isEmpty()) {
            println("missing JavaScript syntax error message")
            return 10
        }
    }

    for (_ in 0..100) {
        let result: Extern<JSRuntime> = JSRuntime.evalScript("1 + 2")
        if (JSRuntime.fromExtern<Float64>(result) != 3.0) {
            println("repeated eval failed")
            return 11
        }
    }

    println("errors_and_lifecycle ok")
    return 0
}
