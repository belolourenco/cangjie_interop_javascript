package smoke

import extern.Extern
import interop_javascript.JSRuntime

func runFunctionsSmoke(): Int64 {
    let add: Extern<JSRuntime> = JSRuntime.evalScript("function add(a, b) { return a + b }; add")
    let sum: Extern<JSRuntime> = JSRuntime.evalFunctionCall(add, [Int32(2), Int32(3)])
    if (JSRuntime.fromExtern<Float64>(sum) != 5.0) {
        println("two-argument function call failed")
        return 1
    }
    JSRuntime.close(sum)
    JSRuntime.close(add)

    let fortyTwo: Extern<JSRuntime> = JSRuntime.evalScript("function fortyTwo() { return 42 }; fortyTwo")
    let fortyTwoResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(fortyTwo, [])
    if (JSRuntime.fromExtern<Float64>(fortyTwoResult) != 42.0) {
        println("zero-argument function call failed")
        return 2
    }
    JSRuntime.close(fortyTwoResult)
    JSRuntime.close(fortyTwo)

    let double: Extern<JSRuntime> = JSRuntime.evalScript("function double(x) { return x * 2 }; double")
    let doubleResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(double, [Int32(21)])
    if (JSRuntime.fromExtern<Float64>(doubleResult) != 42.0) {
        println("one-argument function call failed")
        return 3
    }
    JSRuntime.close(doubleResult)
    JSRuntime.close(double)

    let objectValue: Extern<JSRuntime> = JSRuntime.evalScript("({ base: 10, add(n) { return this.base + n } })")
    let method: Extern<JSRuntime> = JSRuntime.evalMemberAccess(objectValue, "add")
    let methodResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(method, [Int32(5)])
    if (JSRuntime.fromExtern<Float64>(methodResult) != 15.0) {
        println("method call did not preserve this value")
        return 4
    }
    JSRuntime.close(methodResult)
    JSRuntime.close(method)
    JSRuntime.close(objectValue)

    println("functions ok")
    return 0
}
