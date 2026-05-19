package interop_javascript_smoke

import interop_javascript.jsinterop.*

func runFunctionsSmoke(): Int64 {
    let runtime = JSRuntime(".")

    let addValue = runtime.evalScript("function add(a, b) { return a + b }; add")
    if (!addValue.isFunction() || addValue.typeOf() != "function") {
        println("function eval did not return a function")
        return 1
    }
    let add = addValue.asFunction()
    let left = JSValue.int64(runtime, 2)
    let right = JSValue.int64(runtime, 3)
    let sum = add.call([left, right])
    if (!sum.isNumber() || sum.asFloat64() != 5.0) {
        println("two-argument function call failed")
        return 2
    }
    sum.close()
    right.close()
    left.close()
    addValue.close()

    let fortyTwoValue = runtime.evalScript("function fortyTwo() { return 42 }; fortyTwo")
    let fortyTwo = fortyTwoValue.asFunction()
    let fortyTwoResult = fortyTwo.call([])
    if (fortyTwoResult.asFloat64() != 42.0) {
        println("zero-argument function call failed")
        return 3
    }
    fortyTwoResult.close()
    fortyTwoValue.close()

    let doubleValue = runtime.evalScript("function double(x) { return x * 2 }; double")
    let double = doubleValue.asFunction()
    let doubleArg = JSValue.int64(runtime, 21)
    let doubleResult = double.call([doubleArg])
    if (doubleResult.asFloat64() != 42.0) {
        println("one-argument function call failed")
        return 4
    }
    doubleResult.close()
    doubleArg.close()
    doubleValue.close()

    let objectValue = runtime.evalScript("({ base: 10, add(n) { return this.base + n } })")
    let object = objectValue.asObject()
    let methodValue = object.get("add")
    let method = methodValue.asFunction()
    let methodArg = JSValue.int64(runtime, 5)
    let methodResult = method.callWithThis(objectValue.asValue(), [methodArg])
    if (methodResult.asFloat64() != 15.0) {
        println("method call did not preserve this value")
        return 5
    }
    methodResult.close()
    methodArg.close()
    methodValue.close()

    let helperArg = JSValue.int64(runtime, 7)
    let helperResult = object.call("add", [helperArg])
    if (helperResult.asFloat64() != 17.0) {
        println("object call helper did not preserve this value")
        return 6
    }
    helperResult.close()
    helperArg.close()
    objectValue.close()
    runtime.close()

    println("functions ok")
    return 0
}
