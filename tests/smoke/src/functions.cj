package smoke

import std.interop.Extern
import interop_javascript.JSRuntime

func runFunctionsSmoke(): Int64 {
    let add: Extern<JSRuntime> = JSRuntime.evalScript("function add(a, b) { return a + b }; add")
    let sum: Extern<JSRuntime> = JSRuntime.functionCall(add, [Int32(2), Int32(3)])
    if (JSRuntime.fromExtern<Float64>(sum) != 5.0) {
        println("two-argument function call failed")
        return 1
    }

    let fortyTwo: Extern<JSRuntime> = JSRuntime.evalScript("function fortyTwo() { return 42 }; fortyTwo")
    let fortyTwoResult: Extern<JSRuntime> = JSRuntime.functionCall(fortyTwo, [])
    if (JSRuntime.fromExtern<Float64>(fortyTwoResult) != 42.0) {
        println("zero-argument function call failed")
        return 2
    }

    let double: Extern<JSRuntime> = JSRuntime.evalScript("function double(x) { return x * 2 }; double")
    let doubleResult: Extern<JSRuntime> = JSRuntime.functionCall(double, [Int32(21)])
    if (JSRuntime.fromExtern<Float64>(doubleResult) != 42.0) {
        println("one-argument function call failed")
        return 3
    }

    let objectValue: Extern<JSRuntime> = JSRuntime.evalScript("({ base: 10, add(n) { return this.base + n } })")
    let method: Extern<JSRuntime> = JSRuntime.memberAccess(objectValue, "add")
    let methodResult: Extern<JSRuntime> = JSRuntime.functionCall(method, [Int32(5)])
    if (JSRuntime.fromExtern<Float64>(methodResult) != 15.0) {
        println("method call did not preserve this value")
        return 4
    }

    println("functions ok")
    return 0
}
