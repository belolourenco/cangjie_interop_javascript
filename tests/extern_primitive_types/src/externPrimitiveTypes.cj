package extern_primitive_types

import extern.Extern
import interop_javascript.JSRuntime
import std.math.numeric.BigInt

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
    // let arkTs_true_bool: Extern<JSRuntime> = true
    // ->
    let arkTs_true_bool : Extern<JSRuntime> = JSRuntime.toExtern(true)

    // let true_bool : Bool = arkTs_true_bool
    // ->
    let true_bool : Bool = JSRuntime.fromExtern<Bool>(arkTs_true_bool)
    println("Bool true: ${true_bool}")

    // let arkTs_false_bool: Extern<JSRuntime> = false
    // ->
    let arkTs_false_bool : Extern<JSRuntime> = JSRuntime.toExtern(false)

    // let false_bool : Bool = arkTs_false_bool
    // ->
    let false_bool : Bool = JSRuntime.fromExtern<Bool>(arkTs_false_bool)
    println("Bool false: ${false_bool}")
}

func testString() {
    println("---- String ----")
    // let arkTs_hello_string: Extern<JSRuntime> = "Hello World!"
    // ->
    let arkTs_hello_string : Extern<JSRuntime> = JSRuntime.toExtern("Hello World!")

    // let hello_string : String = arkTs_hello_string
    // ->
    let hello_string : String = JSRuntime.fromExtern<String>(arkTs_hello_string)
    println("String: ${hello_string}")
}

func testInt8() {
    println("---- Int8 ----")
    // let arkTs_fourty_two_from_int8: Extern<JSRuntime> = 42
    // ->
    let arkTs_fourty_two_from_int8 : Extern<JSRuntime> = JSRuntime.toExtern(Int8(42))

    // let fourty_two_int8 : Int8 = arkTs_fourty_two_from_int8
    // ->
     let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(arkTs_fourty_two_from_int8)
     println("Int8: ${fourty_two_int8}")

    // let fourty_two_int16 : Int16 = arkTs_fourty_two_from_int8
    // ->
     let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(arkTs_fourty_two_from_int8)
     println("Int16: ${fourty_two_int16}")

    // let fourty_two_int32 : Int32 = arkTs_fourty_two_from_int8
    // ->
     let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(arkTs_fourty_two_from_int8)
     println("Int32: ${fourty_two_int32}")

    // let fourty_two_int64 : Int64 = arkTs_fourty_two_from_int8
    // ->
     let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(arkTs_fourty_two_from_int8)
     println("Int64: ${fourty_two_int64}")

    // let fourty_two_bigInt : BigInt = arkTs_fourty_two_from_int8
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(arkTs_fourty_two_from_int8)
     println("BigInt: ${fourty_two_bigInt}")

    // let fourty_two_float16 : Float16 = arkTs_fourty_two_from_int8
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(arkTs_fourty_two_from_int8)
     println("Float16: ${fourty_two_float16}")

    // let fourty_two_float32 : Float32 = arkTs_fourty_two_from_int8
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(arkTs_fourty_two_from_int8)
     println("Float32: ${fourty_two_float32}")

    // let fourty_two_float64 : Float64 = arkTs_fourty_two_from_int8
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(arkTs_fourty_two_from_int8)
     println("Float64: ${fourty_two_float64}")
}

func testInt32() {
    println("---- Int32 ----")
    // let arkTs_fourty_two_from_int32: Extern<JSRuntime> = Int32.Max
    // ->
    let arkTs_fourty_two_from_int32 : Extern<JSRuntime> = JSRuntime.toExtern(Int32.Max)

    // let fourty_two_int8 : Int8 = arkTs_fourty_two_from_int32
    // ->
    try {
        let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(arkTs_fourty_two_from_int32)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int8: expected overflow")
    }

    // let fourty_two_int16 : Int16 = arkTs_fourty_two_from_int32
    // ->
    try {
        let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(arkTs_fourty_two_from_int32)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int16: expected overflow")
    }

    // let fourty_two_int32 : Int32 = arkTs_fourty_two_from_int32
    // ->
    let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(arkTs_fourty_two_from_int32)
    println("Int32: ${fourty_two_int32}")

    // let fourty_two_int64 : Int64 = arkTs_fourty_two_from_int32
    // ->
     let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(arkTs_fourty_two_from_int32)
     println("Int64: ${fourty_two_int64}")

    // let fourty_two_bigInt : BigInt = arkTs_fourty_two_from_int32
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(arkTs_fourty_two_from_int32)
     println("BigInt: ${fourty_two_bigInt}")

    // let fourty_two_float16 : Float16 = arkTs_fourty_two_from_int32
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(arkTs_fourty_two_from_int32)
     println("Float16: ${fourty_two_float16}")

    // let fourty_two_float32 : Float32 = arkTs_fourty_two_from_int32
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(arkTs_fourty_two_from_int32)
     println("Float32: ${fourty_two_float32}")

    // let fourty_two_float64 : Float64 = arkTs_fourty_two_from_int32
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(arkTs_fourty_two_from_int32)
     println("Float64: ${fourty_two_float64}")

}

func testInt64() {
    println("---- Int64 ----")
    // let arkTs_fourty_two_from_int64: Extern<JSRuntime> = Int64.Max
    // ->
    let arkTs_fourty_two_from_int64 : Extern<JSRuntime> = JSRuntime.toExtern(Int64.Max)

    // let fourty_two_int8 : Int8 = arkTs_fourty_two_from_int64
    // ->
    try {
        let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(arkTs_fourty_two_from_int64)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int8: expected overflow")
    }

    // let fourty_two_int16 : Int16 = arkTs_fourty_two_from_int64
    // ->
    try {
        let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(arkTs_fourty_two_from_int64)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int16: expected overflow")
    }

    // let fourty_two_int32 : Int32 = arkTs_fourty_two_from_int64
    // ->
    try {
        let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(arkTs_fourty_two_from_int64)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int32: expected overflow")
    }

    // let fourty_two_int64 : Int64 = arkTs_fourty_two_from_int64
    // ->
     let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(arkTs_fourty_two_from_int64)
     println("Int64: ${fourty_two_int64}")

    // let fourty_two_bigInt : BigInt = arkTs_fourty_two_from_int64
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(arkTs_fourty_two_from_int64)
     println("BigInt: ${fourty_two_bigInt}")

    // let fourty_two_float16 : Float16 = arkTs_fourty_two_from_int64
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(arkTs_fourty_two_from_int64)
     println("Float16: ${fourty_two_float16}")

    // let fourty_two_float32 : Float32 = arkTs_fourty_two_from_int64
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(arkTs_fourty_two_from_int64)
     println("Float32: ${fourty_two_float32}")

    // let fourty_two_float64 : Float64 = arkTs_fourty_two_from_int64
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(arkTs_fourty_two_from_int64)
     println("Float64: ${fourty_two_float64}")
}

func testBigInt() {
    println("---- Int64 ----")
    let bi = BigInt(Int64.Max) + BigInt(1)
    // let arkTs_fourty_two_from_bigInt: Extern<JSRuntime> = bi
    // ->
    let arkTs_fourty_two_from_bigInt : Extern<JSRuntime> = JSRuntime.toExtern(bi)

    // let fourty_two_int8 : Int8 = arkTs_fourty_two_from_bigInt
    // ->
    try {
        let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(arkTs_fourty_two_from_bigInt)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int8: expected overflow")
    }

    // let fourty_two_int16 : Int16 = arkTs_fourty_two_from_bigInt
    // ->
    try {
        let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(arkTs_fourty_two_from_bigInt)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int16: expected overflow")
    }

    // let fourty_two_int32 : Int32 = arkTs_fourty_two_from_bigInt
    // ->
    try {
        let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(arkTs_fourty_two_from_bigInt)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int32: expected overflow")
    }

    // let fourty_two_int64 : Int64 = arkTs_fourty_two_from_bigInt
    // ->
    try {
        let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(arkTs_fourty_two_from_bigInt)
        throw Exception("Should not happen!")
    } catch (e: OverflowException) {
        println("Int64: expected overflow")
    }

    // let fourty_two_bigInt : BigInt = arkTs_fourty_two_from_bigInt
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(arkTs_fourty_two_from_bigInt)
     println("BigInt: ${fourty_two_bigInt}")

    // let fourty_two_float16 : Float16 = arkTs_fourty_two_from_bigInt
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(arkTs_fourty_two_from_bigInt)
     println("Float16: ${fourty_two_float16}")

    // let fourty_two_float32 : Float32 = arkTs_fourty_two_from_bigInt
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(arkTs_fourty_two_from_bigInt)
     println("Float32: ${fourty_two_float32}")

    // let fourty_two_float64 : Float64 = arkTs_fourty_two_from_bigInt
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(arkTs_fourty_two_from_bigInt)
     println("Float64: ${fourty_two_float64}")
}

func testFloat16() {
    println("---- Float16 ----")
    // let arkTs_fourty_two_from_float16: Extern<JSRuntime> = Float16(42.4242)
    // ->
    let arkTs_fourty_two_from_float16 : Extern<JSRuntime> = JSRuntime.toExtern(Float16(42.4242))

    // let fourty_two_int8 : Int8 = arkTs_fourty_two_from_float16
    // ->
    let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(arkTs_fourty_two_from_float16)
    println("Int8: ${fourty_two_int8}")

    // let fourty_two_int16 : Int16 = arkTs_fourty_two_from_float16
    // ->
    let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(arkTs_fourty_two_from_float16)
    println("Int16: ${fourty_two_int16}")

    // let fourty_two_int32 : Int32 = arkTs_fourty_two_from_float16
    // ->
     let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(arkTs_fourty_two_from_float16)
     println("Int32: ${fourty_two_int32}")

    // let fourty_two_int64 : Int64 = arkTs_fourty_two_from_float16
    // ->
     let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(arkTs_fourty_two_from_float16)
     println("Int64: ${fourty_two_int64}")

    // let fourty_two_bigInt : BigInt = arkTs_fourty_two_from_float16
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(arkTs_fourty_two_from_float16)
     println("BigInt: ${fourty_two_bigInt}")

    // let fourty_two_float16 : Float16 = arkTs_fourty_two_from_float16
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(arkTs_fourty_two_from_float16)
     println("Float16: ${fourty_two_float16}")

    // let fourty_two_float32 : Float32 = arkTs_fourty_two_from_float16
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(arkTs_fourty_two_from_float16)
     println("Float32: ${fourty_two_float32}")

    // let fourty_two_float64 : Float64 = arkTs_fourty_two_from_float16
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(arkTs_fourty_two_from_float16)
     println("Float64: ${fourty_two_float64}")
}

func testFloat32() {
    println("---- Float32 ----")
    // let arkTs_fourty_two_from_float32: Extern<JSRuntime> = Float32(42.4242)
    // ->
    let arkTs_fourty_two_from_float32 : Extern<JSRuntime> = JSRuntime.toExtern(Float32(42.4242))

    // let fourty_two_int8 : Int8 = arkTs_fourty_two_from_float32
    // ->
    let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(arkTs_fourty_two_from_float32)
    println("Int8: ${fourty_two_int8}")

    // let fourty_two_int16 : Int16 = arkTs_fourty_two_from_float32
    // ->
    let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(arkTs_fourty_two_from_float32)
    println("Int16: ${fourty_two_int16}")

    // let fourty_two_int32 : Int32 = arkTs_fourty_two_from_float32
    // ->
     let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(arkTs_fourty_two_from_float32)
     println("Int32: ${fourty_two_int32}")

    // let fourty_two_int64 : Int64 = arkTs_fourty_two_from_float32
    // ->
     let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(arkTs_fourty_two_from_float32)
     println("Int64: ${fourty_two_int64}")

    // let fourty_two_bigInt : BigInt = arkTs_fourty_two_from_float32
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(arkTs_fourty_two_from_float32)
     println("BigInt: ${fourty_two_bigInt}")

    // let fourty_two_float16 : Float16 = arkTs_fourty_two_from_float32
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(arkTs_fourty_two_from_float32)
     println("Float16: ${fourty_two_float16}")

    // let fourty_two_float32 : Float32 = arkTs_fourty_two_from_float32
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(arkTs_fourty_two_from_float32)
     println("Float32: ${fourty_two_float32}")

    // let fourty_two_float64 : Float64 = arkTs_fourty_two_from_float32
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(arkTs_fourty_two_from_float32)
     println("Float64: ${fourty_two_float64}")
}

func testFloat64() {
    println("---- Float64 ----")
    // let arkTs_fourty_two_from_float64: Extern<JSRuntime> = Float64(42.4242)
    // ->
    let arkTs_fourty_two_from_float64 : Extern<JSRuntime> = JSRuntime.toExtern(Float64(42.4242))

    // let fourty_two_int8 : Int8 = arkTs_fourty_two_from_float64
    // ->
    let fourty_two_int8 : Int8 = JSRuntime.fromExtern<Int8>(arkTs_fourty_two_from_float64)
    println("Int8: ${fourty_two_int8}")

    // let fourty_two_int16 : Int16 = arkTs_fourty_two_from_float64
    // ->
    let fourty_two_int16 : Int16 = JSRuntime.fromExtern<Int16>(arkTs_fourty_two_from_float64)
    println("Int16: ${fourty_two_int16}")

    // let fourty_two_int32 : Int32 = arkTs_fourty_two_from_float64
    // ->
     let fourty_two_int32 : Int32 = JSRuntime.fromExtern<Int32>(arkTs_fourty_two_from_float64)
     println("Int32: ${fourty_two_int32}")

    // let fourty_two_int64 : Int64 = arkTs_fourty_two_from_float64
    // ->
     let fourty_two_int64 : Int64 = JSRuntime.fromExtern<Int64>(arkTs_fourty_two_from_float64)
     println("Int64: ${fourty_two_int64}")

    // let fourty_two_bigInt : BigInt = arkTs_fourty_two_from_float64
    // ->
     let fourty_two_bigInt : BigInt = JSRuntime.fromExtern<BigInt>(arkTs_fourty_two_from_float64)
     println("BigInt: ${fourty_two_bigInt}")

    // let fourty_two_float16 : Float16 = arkTs_fourty_two_from_float64
    // ->
     let fourty_two_float16 : Float16 = JSRuntime.fromExtern<Float16>(arkTs_fourty_two_from_float64)
     println("Float16: ${fourty_two_float16}")

    // let fourty_two_float32 : Float32 = arkTs_fourty_two_from_float64
    // ->
     let fourty_two_float32 : Float32 = JSRuntime.fromExtern<Float32>(arkTs_fourty_two_from_float64)
     println("Float32: ${fourty_two_float32}")

    // let fourty_two_float64 : Float64 = arkTs_fourty_two_from_float64
    // ->
     let fourty_two_float64 : Float64 = JSRuntime.fromExtern<Float64>(arkTs_fourty_two_from_float64)
     println("Float64: ${fourty_two_float64}")
}
