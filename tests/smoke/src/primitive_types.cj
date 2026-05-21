package smoke

import extern.Extern
import interop_javascript.JSRuntime
import std.math.numeric.BigInt

func runPrimitiveTypesSmoke(): Int64 {
    let boolValue: Extern<JSRuntime> = JSRuntime.toExtern(true)
    if (!JSRuntime.fromExtern<Bool>(boolValue)) {
        println("unexpected Cangjie bool conversion")
        return 1
    }

    let intValue: Extern<JSRuntime> = JSRuntime.toExtern(Int64(42))
    if (JSRuntime.fromExtern<Int64>(intValue) != 42) {
        println("unexpected Cangjie Int64 conversion")
        return 2
    }
    JSRuntime.close(intValue)

    let stringValue: Extern<JSRuntime> = JSRuntime.toExtern("hello")
    if (JSRuntime.fromExtern<String>(stringValue) != "hello") {
        println("unexpected Cangjie string conversion")
        return 3
    }
    JSRuntime.close(stringValue)

    let floatValue: Extern<JSRuntime> = JSRuntime.toExtern(Float64(42.5))
    if (JSRuntime.fromExtern<Float64>(floatValue) != 42.5) {
        println("unexpected Cangjie Float64 conversion")
        return 4
    }
    JSRuntime.close(floatValue)

    let bigIntValue: Extern<JSRuntime> = JSRuntime.toExtern(BigInt.parse("9007199254740993"))
    if (JSRuntime.fromExtern<BigInt>(bigIntValue) != BigInt.parse("9007199254740993")) {
        println("unexpected Cangjie BigInt conversion")
        return 5
    }
    JSRuntime.close(bigIntValue)

    let numberResult: Extern<JSRuntime> = JSRuntime.evalScript("1 + 2")
    if (JSRuntime.fromExtern<Float64>(numberResult) != 3.0) {
        println("unexpected numeric eval result")
        return 6
    }
    JSRuntime.close(numberResult)

    let firstStringResult: Extern<JSRuntime> = JSRuntime.evalScript("'hello'")
    let secondStringResult: Extern<JSRuntime> = JSRuntime.evalScript("'world'")
    if (JSRuntime.fromExtern<String>(firstStringResult) != "hello" ||
        JSRuntime.fromExtern<String>(secondStringResult) != "world") {
        println("native value handles were overwritten by later eval")
        return 7
    }
    JSRuntime.close(firstStringResult)
    JSRuntime.close(secondStringResult)

    try {
        JSRuntime.fromExtern<Float64>(boolValue)
        println("boolean converted to number unexpectedly")
        return 8
    } catch (_) {
        ()
    }
    JSRuntime.close(boolValue)

    println("primitive_types ok")
    return 0
}
