package extern_primitive_types

import extern.Extern
import interop_javascript.JSRuntime
import std.math.numeric.BigInt
import std.math.*

class AssertionFailedException <: Exception {

    public init(message: String) {
        super(message)
    }
}

func assert(condition: Bool, message: String) {
    if (!condition) {
        throw AssertionFailedException(message)
    }
}

func float_equal(a: Float64, b: Float64): Bool {
    abs(a - b) < 1e-6
}

func float_equal(a: Float32, b: Float32): Bool {
    abs(a - b) < 1e-6
}

func float_equal(a: Float16, b: Float16): Bool {
    abs(a - b) < 1e-6
}

func testPrimitiveTypes() {
    testBool()
    testString()
    testInt8()
    testInt32()
    testInt64()
    testBigInt()
    testFloat16()
    testFloat32()
    testFloat64()
}

func testBool() {
    println("---- Bool ----")
    // let js_true_bool: Extern<JSRuntime> = true
    // ->
    let js_true_bool : Extern<JSRuntime> = JSRuntime.toExtern(true)

    // let true_bool : Bool = js_true_bool
    // ->
    let true_bool : Bool = JSRuntime.fromExtern<Bool>(js_true_bool)
    println("Bool true: ${true_bool}")
    assert(true_bool == true, "Bool true should be true")

    // let js_false_bool: Extern<JSRuntime> = false
    // ->
    let js_false_bool : Extern<JSRuntime> = JSRuntime.toExtern(false)

    // let false_bool : Bool = js_false_bool
    // ->
    let false_bool : Bool = JSRuntime.fromExtern<Bool>(js_false_bool)
    println("Bool false: ${false_bool}")
    assert(false_bool == false, "Bool false should be false")
}

func testString() {
    println("---- String ----")
    // let js_hello_string: Extern<JSRuntime> = "Hello World!"
    // ->
    let js_hello_string : Extern<JSRuntime> = JSRuntime.toExtern("Hello World!")

    // let hello_string : String = js_hello_string
    // ->
    let hello_string : String = JSRuntime.fromExtern<String>(js_hello_string)
    println("String: ${hello_string}")
    assert(hello_string == "Hello World!", "String should be 'Hello World!'")
}

func testInt8() {
    println("---- Int8 ----")
    // let js_fourty_two_from_int8: Extern<JSRuntime> = 42
    // ->
    let js_fourty_two_from_int8 : Extern<JSRuntime> = JSRuntime.toExtern(Int8(42))

    // let fourty_two_int8 : Int8 = js_fourty_two_from_int8
    // ->
     let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(js_fourty_two_from_int8)
     println("Int8: ${fourty_two_int8}")
     assert(fourty_two_int8 == Int8(42), "Int8 should be 42")

    // let fourty_two_int16 : Int16 = js_fourty_two_from_int8
    // ->
     let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(js_fourty_two_from_int8)
     println("Int16: ${fourty_two_int16}")
     assert(fourty_two_int16 == Int16(42), "Int16 should be 42")

    // let fourty_two_int32 : Int32 = js_fourty_two_from_int8
    // ->
     let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(js_fourty_two_from_int8)
     println("Int32: ${fourty_two_int32}")
     assert(fourty_two_int32 == Int32(42), "Int32 should be 42")

    // let fourty_two_int64 : Int64 = js_fourty_two_from_int8
    // ->
     let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(js_fourty_two_from_int8)
     println("Int64: ${fourty_two_int64}")
     assert(fourty_two_int64 == Int64(42), "Int64 should be 42")

    // let fourty_two_bigInt : BigInt = js_fourty_two_from_int8
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(js_fourty_two_from_int8)
     println("BigInt: ${fourty_two_bigInt}")
     assert(fourty_two_bigInt == BigInt(42), "BigInt should be 42")

    // let fourty_two_float16 : Float16 = js_fourty_two_from_int8
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(js_fourty_two_from_int8)
     println("Float16: ${fourty_two_float16}")
     assert(float_equal(fourty_two_float16, Float16(42.0)), "Float16 should be 42.0")

    // let fourty_two_float32 : Float32 = js_fourty_two_from_int8
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(js_fourty_two_from_int8)
     println("Float32: ${fourty_two_float32}")
     assert(float_equal(fourty_two_float32, Float32(42.0)), "Float32 should be 42.0")

    // let fourty_two_float64 : Float64 = js_fourty_two_from_int8
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(js_fourty_two_from_int8)
     println("Float64: ${fourty_two_float64}")
     assert(float_equal(fourty_two_float64, Float64(42.0)), "Float64 should be 42.0")
}

func testInt32() {
    println("---- Int32 ----")
    // let js_fourty_two_from_int32: Extern<JSRuntime> = Int32.Max
    // ->
    let js_fourty_two_from_int32 : Extern<JSRuntime> = JSRuntime.toExtern(Int32.Max)

    // let fourty_two_int8 : Int8 = js_fourty_two_from_int32
    // ->
    try {
        let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(js_fourty_two_from_int32)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int8: expected overflow")
    }

    // let fourty_two_int16 : Int16 = js_fourty_two_from_int32
    // ->
    try {
        let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(js_fourty_two_from_int32)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int16: expected overflow")
    }

    // let fourty_two_int32 : Int32 = js_fourty_two_from_int32
    // ->
    let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(js_fourty_two_from_int32)
    println("Int32: ${fourty_two_int32}")
    assert(fourty_two_int32 == Int32.Max, "Int32 should be Int32.Max")

    // let fourty_two_int64 : Int64 = js_fourty_two_from_int32
    // ->
     let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(js_fourty_two_from_int32)
     println("Int64: ${fourty_two_int64}")
     assert(fourty_two_int64 == Int64(Int32.Max), "Int64 should be Int64(Int32.Max)")

    // let fourty_two_bigInt : BigInt = js_fourty_two_from_int32
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(js_fourty_two_from_int32)
     println("BigInt: ${fourty_two_bigInt}")
     assert(fourty_two_bigInt == BigInt(Int32.Max), "BigInt should be BigInt(Int32.Max)")

    // let fourty_two_float16 : Float16 = js_fourty_two_from_int32
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(js_fourty_two_from_int32)
     println("Float16: ${fourty_two_float16}")
     assert(fourty_two_float16 == Float16.getInf(), "Float16 should be inf")

    // let fourty_two_float32 : Float32 = js_fourty_two_from_int32
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(js_fourty_two_from_int32)
     println("Float32: ${fourty_two_float32}")
     assert(float_equal(fourty_two_float32, Float32(Int32.Max)), "Float32 should be Float32(Int32.Max)")

    // let fourty_two_float64 : Float64 = js_fourty_two_from_int32
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(js_fourty_two_from_int32)
     println("Float64: ${fourty_two_float64}")
     assert(float_equal(fourty_two_float64, Float64(Int32.Max)), "Float64 should be Float64(Int32.Max)")
}

func testInt64() {
    println("---- Int64 ----")
    // let js_fourty_two_from_int64: Extern<JSRuntime> = Int64.Max
    // ->
    let js_fourty_two_from_int64 : Extern<JSRuntime> = JSRuntime.toExtern(Int64.Max)

    // let fourty_two_int8 : Int8 = js_fourty_two_from_int64
    // ->
    try {
        let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(js_fourty_two_from_int64)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int8: expected overflow")
    }

    // let fourty_two_int16 : Int16 = js_fourty_two_from_int64
    // ->
    try {
        let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(js_fourty_two_from_int64)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int16: expected overflow")
    }

    // let fourty_two_int32 : Int32 = js_fourty_two_from_int64
    // ->
    try {
        let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(js_fourty_two_from_int64)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int32: expected overflow")
    }

    // let fourty_two_int64 : Int64 = js_fourty_two_from_int64
    // ->
     let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(js_fourty_two_from_int64)
     println("Int64: ${fourty_two_int64}")
     assert(fourty_two_int64 == Int64.Max, "Int64 should be Int64.Max")

    // let fourty_two_bigInt : BigInt = js_fourty_two_from_int64
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(js_fourty_two_from_int64)
     println("BigInt: ${fourty_two_bigInt}")
     assert(fourty_two_bigInt == BigInt(Int64.Max), "BigInt should be BigInt(Int64.Max)")

    // let fourty_two_float16 : Float16 = js_fourty_two_from_int64
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(js_fourty_two_from_int64)
     println("Float16: ${fourty_two_float16}")
     assert(fourty_two_float16 == Float16.getInf(), "Float16 should be inf")

    // let fourty_two_float32 : Float32 = js_fourty_two_from_int64
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(js_fourty_two_from_int64)
     println("Float32: ${fourty_two_float32}")
     assert(float_equal(fourty_two_float32, Float32(Int64.Max)), "Float32 should be Float32(Int64.Max)")

    // let fourty_two_float64 : Float64 = js_fourty_two_from_int64
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(js_fourty_two_from_int64)
     println("Float64: ${fourty_two_float64}")
     assert(float_equal(fourty_two_float64, Float64(Int64.Max)), "Float64 should be Float64(Int64.Max)")
}

func testBigInt() {
    println("---- Int64 ----")
    let bi = BigInt(Int64.Max) + BigInt(1)
    // let js_fourty_two_from_bigInt: Extern<JSRuntime> = bi
    // ->
    let js_fourty_two_from_bigInt : Extern<JSRuntime> = JSRuntime.toExtern(bi)

    // let fourty_two_int8 : Int8 = js_fourty_two_from_bigInt
    // ->
    try {
        let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(js_fourty_two_from_bigInt)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int8: expected overflow")
    }

    // let fourty_two_int16 : Int16 = js_fourty_two_from_bigInt
    // ->
    try {
        let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(js_fourty_two_from_bigInt)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int16: expected overflow")
    }

    // let fourty_two_int32 : Int32 = js_fourty_two_from_bigInt
    // ->
    try {
        let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(js_fourty_two_from_bigInt)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int32: expected overflow")
    }

    // let fourty_two_int64 : Int64 = js_fourty_two_from_bigInt
    // ->
    try {
        let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(js_fourty_two_from_bigInt)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int64: expected overflow")
    }

    // let fourty_two_bigInt : BigInt = js_fourty_two_from_bigInt
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(js_fourty_two_from_bigInt)
     println("BigInt: ${fourty_two_bigInt}")
     assert(fourty_two_bigInt == bi, "BigInt should be ${bi}")

    // let fourty_two_float16 : Float16 = js_fourty_two_from_bigInt
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(js_fourty_two_from_bigInt)
     println("Float16: ${fourty_two_float16}")
     assert(fourty_two_float16 == Float16.getInf(), "Float16 should be inf")

    // let fourty_two_float32 : Float32 = js_fourty_two_from_bigInt
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(js_fourty_two_from_bigInt)
     println("Float32: ${fourty_two_float32}")
     assert(float_equal(fourty_two_float32, bi.toFloat32()), "Float32 should be Float32(bi)")

    // let fourty_two_float64 : Float64 = js_fourty_two_from_bigInt
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(js_fourty_two_from_bigInt)
     println("Float64: ${fourty_two_float64}")
     assert(float_equal(fourty_two_float64, bi.toFloat64()), "Float64 should be Float64(bi)")
}

func testFloat16() {
    println("---- Float16 ----")
    // let js_fourty_two_from_float16: Extern<JSRuntime> = Float16(42.4242)
    // ->
    let js_fourty_two_from_float16 : Extern<JSRuntime> = JSRuntime.toExtern(Float16(42.4242))

    // let fourty_two_int8 : Int8 = js_fourty_two_from_float16
    // ->
    let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(js_fourty_two_from_float16)
    println("Int8: ${fourty_two_int8}")
    assert(fourty_two_int8 == Int8(42), "Int8 should be 42")

    // let fourty_two_int16 : Int16 = js_fourty_two_from_float16
    // ->
    let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(js_fourty_two_from_float16)
    println("Int16: ${fourty_two_int16}")
    assert(fourty_two_int16 == Int16(42), "Int16 should be 42")

    // let fourty_two_int32 : Int32 = js_fourty_two_from_float16
    // ->
     let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(js_fourty_two_from_float16)
     println("Int32: ${fourty_two_int32}")
     assert(fourty_two_int32 == Int32(42), "Int32 should be 42")

    // let fourty_two_int64 : Int64 = js_fourty_two_from_float16
    // ->
     let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(js_fourty_two_from_float16)
     println("Int64: ${fourty_two_int64}")
     assert(fourty_two_int64 == Int64(42), "Int64 should be 42")

    // let fourty_two_bigInt : BigInt = js_fourty_two_from_float16
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(js_fourty_two_from_float16)
     println("BigInt: ${fourty_two_bigInt}")
     assert(fourty_two_bigInt == BigInt(42), "BigInt should be 42")

    // let fourty_two_float16 : Float16 = js_fourty_two_from_float16
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(js_fourty_two_from_float16)
     println("Float16: ${fourty_two_float16}")
     assert(fourty_two_float16 == Float16(42.4242), "Float16 should be 42.4242")

    // let fourty_two_float32 : Float32 = js_fourty_two_from_float16
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(js_fourty_two_from_float16)
     println("Float32: ${fourty_two_float32}")
     assert(float_equal(fourty_two_float32, Float32(Float16(42.4242))), "Float32 should be 42.4242")

    // let fourty_two_float64 : Float64 = js_fourty_two_from_float16
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(js_fourty_two_from_float16)
     println("Float64: ${fourty_two_float64}")
     assert(float_equal(fourty_two_float64, Float64(Float16(42.4242))), "Float64 should be 42.4242")
}

func testFloat32() {
    println("---- Float32 ----")
    // let js_fourty_two_from_float32: Extern<JSRuntime> = Float32(42.4242)
    // ->
    let js_fourty_two_from_float32 : Extern<JSRuntime> = JSRuntime.toExtern(Float32(42.4242))

    // let fourty_two_int8 : Int8 = js_fourty_two_from_float32
    // ->
    let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(js_fourty_two_from_float32)
    println("Int8: ${fourty_two_int8}")
    assert(fourty_two_int8 == Int8(42), "Int8 should be 42")

    // let fourty_two_int16 : Int16 = js_fourty_two_from_float32
    // ->
    let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(js_fourty_two_from_float32)
    println("Int16: ${fourty_two_int16}")
    assert(fourty_two_int16 == Int16(42), "Int16 should be 42")

    // let fourty_two_int32 : Int32 = js_fourty_two_from_float32
    // ->
     let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(js_fourty_two_from_float32)
     println("Int32: ${fourty_two_int32}")
     assert(fourty_two_int32 == Int32(42), "Int32 should be 42")

    // let fourty_two_int64 : Int64 = js_fourty_two_from_float32
    // ->
     let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(js_fourty_two_from_float32)
     println("Int64: ${fourty_two_int64}")
     assert(fourty_two_int64 == Int64(42), "Int64 should be 42")

    // let fourty_two_bigInt : BigInt = js_fourty_two_from_float32
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(js_fourty_two_from_float32)
     println("BigInt: ${fourty_two_bigInt}")
     assert(fourty_two_bigInt == BigInt(42), "BigInt should be 42")

    // let fourty_two_float16 : Float16 = js_fourty_two_from_float32
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(js_fourty_two_from_float32)
     println("Float16: ${fourty_two_float16}")
     assert(fourty_two_float16 == Float16(42.4242), "Float16 should be 42.4242")

    // let fourty_two_float32 : Float32 = js_fourty_two_from_float32
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(js_fourty_two_from_float32)
     println("Float32: ${fourty_two_float32}")
     assert(float_equal(fourty_two_float32, Float32(42.4242)), "Float32 should be 42.4242")

    // let fourty_two_float64 : Float64 = js_fourty_two_from_float32
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(js_fourty_two_from_float32)
     println("Float64: ${fourty_two_float64}")
     assert(float_equal(fourty_two_float64, Float64(Float32(42.4242))), "Float64 should be 42.4242")
}

func testFloat64() {
    println("---- Float64 ----")
    // let js_fourty_two_from_float64: Extern<JSRuntime> = Float64(42.4242)
    // ->
    let js_fourty_two_from_float64 : Extern<JSRuntime> = JSRuntime.toExtern(Float64(42.4242))

    // let fourty_two_int8 : Int8 = js_fourty_two_from_float64
    // ->
    let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(js_fourty_two_from_float64)
    println("Int8: ${fourty_two_int8}")
    assert(fourty_two_int8 == Int8(42), "Int8 should be 42")

    // let fourty_two_int16 : Int16 = js_fourty_two_from_float64
    // ->
    let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(js_fourty_two_from_float64)
    println("Int16: ${fourty_two_int16}")
    assert(fourty_two_int16 == Int16(42), "Int16 should be 42")

    // let fourty_two_int32 : Int32 = js_fourty_two_from_float64
    // ->
     let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(js_fourty_two_from_float64)
     println("Int32: ${fourty_two_int32}")
     assert(fourty_two_int32 == Int32(42), "Int32 should be 42")

    // let fourty_two_int64 : Int64 = js_fourty_two_from_float64
    // ->
     let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(js_fourty_two_from_float64)
     println("Int64: ${fourty_two_int64}")
     assert(fourty_two_int64 == Int64(42), "Int64 should be 42")

    // let fourty_two_bigInt : BigInt = js_fourty_two_from_float64
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(js_fourty_two_from_float64)
     println("BigInt: ${fourty_two_bigInt}")
     assert(fourty_two_bigInt == BigInt(42), "BigInt should be 42")

    // let fourty_two_float16 : Float16 = js_fourty_two_from_float64
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(js_fourty_two_from_float64)
     println("Float16: ${fourty_two_float16}")
     assert(fourty_two_float16 == Float16(42.4242), "Float16 should be 42.4242")

    // let fourty_two_float32 : Float32 = js_fourty_two_from_float64
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(js_fourty_two_from_float64)
     println("Float32: ${fourty_two_float32}")
     assert(float_equal(fourty_two_float32, Float32(42.4242)), "Float32 should be 42.4242")

    // let fourty_two_float64 : Float64 = js_fourty_two_from_float64
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(js_fourty_two_from_float64)
     println("Float64: ${fourty_two_float64}")
     assert(float_equal(fourty_two_float64, Float64(42.4242)), "Float64 should be 42.4242")
}
