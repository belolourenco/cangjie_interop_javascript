package extern_with_modules

import extern.Extern
import extern.ExternDynamicException
import interop_javascript.JSRuntime
import std.collection.ArrayList

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

public func testExternWithModules1() {
    // ---- JavaScript Module ----
    let jsModule: Extern<JSRuntime> = JSRuntime.getModule("js_examples/my_module.js")

    // ---- my_javascript_function ----

    // jsModule.my_javascript_function()
    // ->
    let my_javascript_function: Extern<JSRuntime> = JSRuntime.memberAccess(jsModule, "my_javascript_function")
    JSRuntime.functionCall(my_javascript_function, [])

    // ---- lookup ----

    // let lookupResult: Extern<JSRuntime> = jsModule.lookup(42.4242, 1.111)
    // ->
    let lookup: Extern<JSRuntime> = JSRuntime.memberAccess(jsModule, "lookup")
    let lookupResult: Extern<JSRuntime> = JSRuntime.functionCall(lookup, [42.4242, 1.111])

    // println("Lookup coordinates: (${(lookupResult.coordinates[0] as Float64).getOrThrow()}, ${(lookupResult.coordinates[1] as Float64).getOrThrow()})")
    // ->
    let lookup_coordinates: Extern<JSRuntime> = JSRuntime.memberAccess(lookupResult, "coordinates")
    let lookup_coordinates_0: Extern<JSRuntime> = JSRuntime.indexAccess(lookup_coordinates, 0)
    let lookup_coordinates_1: Extern<JSRuntime> = JSRuntime.indexAccess(lookup_coordinates, 1)
    println("Lookup coordinates: (${JSRuntime.fromExtern<Float64>(lookup_coordinates_0)}, ${JSRuntime.fromExtern<Float64>(lookup_coordinates_1)})")

    // println("Lookup result: ${lookupResult.name}")
    // ->
    let lookup_name: Extern<JSRuntime> = JSRuntime.memberAccess(lookupResult, "name")
    println("Lookup name: ${JSRuntime.fromExtern<String>(lookup_name)}")

    // println("Lookup result: ${lookupResult.city}")
    // ->
    let lookup_city: Extern<JSRuntime> = JSRuntime.memberAccess(lookupResult, "city")
    println("Lookup city: ${JSRuntime.fromExtern<String>(lookup_city)}")

    // println("Lookup result: ${lookupResult.category}")
    // ->
    let lookup_category: Extern<JSRuntime> = JSRuntime.memberAccess(lookupResult, "category")
    println("Lookup category: ${JSRuntime.fromExtern<String>(lookup_category)}")

    // ---- Rectangle ----

    // let rectangle: Extern<JSRuntime> = jsModule.Rectangle(10, 11)
    // ->
    let rectangleConstructor: Extern<JSRuntime> = JSRuntime.memberAccess(jsModule, "Rectangle")
    let rectangleObject: Extern<JSRuntime> = JSRuntime.functionCall(rectangleConstructor, [10, 11])

    // let rectangleWidth: Extern<JSRuntime> = rectangleObject.getWidth()
    // ->
    let rectangleWidthMethod: Extern<JSRuntime> = JSRuntime.memberAccess(rectangleObject, "getWidth")
    let rectangleWidthResult: Extern<JSRuntime> = JSRuntime.functionCall(rectangleWidthMethod, [])
    println("Rectangle width: ${JSRuntime.fromExtern<Float64>(rectangleWidthResult)}")

    // let rectangleHeight: Extern<JSRuntime> = rectangleObject.getHeight()
    // ->
    let rectangleHeightMethod: Extern<JSRuntime> = JSRuntime.memberAccess(rectangleObject, "getHeight")
    let rectangleHeightResult: Extern<JSRuntime> = JSRuntime.functionCall(rectangleHeightMethod, [])
    println("Rectangle height: ${JSRuntime.fromExtern<Float64>(rectangleHeightResult)}")

    // ---- createRectangle ----

    // let rectangleObject2: Extern<JSRuntime> = jsModule.createRectangle()
    // ->
    let createRectangleMethod: Extern<JSRuntime> = JSRuntime.memberAccess(jsModule, "createRectangle")
    let rectangleObject2: Extern<JSRuntime> = JSRuntime.functionCall(createRectangleMethod, [])

    // rectangleObject2.width = 42
    // ->
    JSRuntime.memberUpdate(rectangleObject2, "width", 42.0)

    // let rectangleWidth2: Extern<JSRuntime> = rectangleObject2.width
    // ->
    let rectangleWidthResult2: Extern<JSRuntime> = JSRuntime.memberAccess(rectangleObject2, "width")
    println("Rectangle width: ${JSRuntime.fromExtern<Float64>(rectangleWidthResult2)}")

    // let rectangleHeight2: Extern<JSRuntime> = rectangleObject2.height
    // ->
    let rectangleHeightResult2: Extern<JSRuntime> = JSRuntime.memberAccess(rectangleObject2, "height")
    println("Rectangle height: ${JSRuntime.fromExtern<Float64>(rectangleHeightResult2)}")

    // let area = rectangleObject2.area()
    // ->
    let areaMethod: Extern<JSRuntime> = JSRuntime.memberAccess(rectangleObject2, "area")
    let areaResult: Extern<JSRuntime> = JSRuntime.functionCall(areaMethod, [])
    println("Rectangle area: ${JSRuntime.fromExtern<Float64>(areaResult)}")

    // let perimeter = rectangleObject2.perimeter()
    // ->
    let perimeterMethod: Extern<JSRuntime> = JSRuntime.memberAccess(rectangleObject2, "perimeter")
    let perimeterResult: Extern<JSRuntime> = JSRuntime.functionCall(perimeterMethod, [])
    println("Rectangle perimeter: ${JSRuntime.fromExtern<Float64>(perimeterResult)}")

    // ---- accessing global variables ----

    // let globalBoolean: Extern<JSRuntime> = jsModule.globalBoolean
    // ->
    let globalBoolean: Extern<JSRuntime> = JSRuntime.memberAccess(jsModule, "globalBoolean")
    println("Global boolean: ${JSRuntime.fromExtern<Bool>(globalBoolean)}")

    // let globalNumber: Extern<JSRuntime> = jsModule.globalNumber
    // ->
    let globalNumber: Extern<JSRuntime> = JSRuntime.memberAccess(jsModule, "globalNumber")
    println("Global number: ${JSRuntime.fromExtern<Float64>(globalNumber)}")

    // let globalString: Extern<JSRuntime> = jsModule.globalString
    // ->
    let globalString: Extern<JSRuntime> = JSRuntime.memberAccess(jsModule, "globalString")
    println("Global string: ${JSRuntime.fromExtern<String>(globalString)}")

    // ---- array access and assignment ----

    // let globalArray: Extern<JSRuntime> = jsModule.globalArray
    // ->
    let globalArray: Extern<JSRuntime> = JSRuntime.memberAccess(jsModule, "globalArray")
    let arrayElements: ArrayList<Int64> = convertArrayToArrayList(globalArray)
    println("Global array elements: ${arrayElements}")
    assert(arrayElements[0] == 1, "Global array element 0 should be 1")
    assert(arrayElements[1] == 2, "Global array element 1 should be 2")
    assert(arrayElements[2] == 3, "Global array element 2 should be 3")

    // globalArray[1] = 42
    // ->
    JSRuntime.indexUpdate(globalArray, 1, 42)
    let arrayElements2: ArrayList<Int64> = convertArrayToArrayList(globalArray)
    println("Global array elements: ${arrayElements2}")
    assert(arrayElements2[0] == 1, "Global array element 0 should be 1")
    assert(arrayElements2[1] == 42, "Global array element 1 should be 42")
    assert(arrayElements2[2] == 3, "Global array element 2 should be 3")

    try {
        // globalArray[-1]
        // ->
        JSRuntime.indexAccess(globalArray, -1)
        throw AssertionFailedException("Global array element -1 should be out of range")
    } catch (e: ExternDynamicException) {
        println("Expected exception: ${e.message}")
    }


    try {
        // globalArray[-1] = 42
        // ->
        JSRuntime.indexUpdate(globalArray, -1, 42)
        throw AssertionFailedException("Global array element 3 should be out of range")
    } catch (e: ExternDynamicException) {
        println("Expected exception: ${e.message}")
    }

    try {
        // globalArray[3]
        // ->
        let x = JSRuntime.indexAccess(globalArray, 3)
        println("Global array element 3: ${JSRuntime.fromExtern<Int64>(x)}")
        throw AssertionFailedException("Global array element 3 should be out of range")
    } catch (e: ExternDynamicException) {
        println("Expected exception: ${e.message}")
    }

    try {
        // globalArray[3] = 42
        // ->
        JSRuntime.indexUpdate(globalArray, 3, 42)
        throw AssertionFailedException("Global array element 3 should be out of range")
    } catch (e: ExternDynamicException) {
        println("Expected exception: ${e.message}")
    }

    // ---- global object ----

    // let globalObject: Extern<JSRuntime> = jsModule.globalObject
    // ->
    let globalObject: Extern<JSRuntime> = JSRuntime.memberAccess(jsModule, "globalObject")

    // let globalObjectName: Extern<JSRuntime> = globalObject.name
    // ->
    let globalObjectName: Extern<JSRuntime> = JSRuntime.memberAccess(globalObject, "name")
    println("Global object name: ${JSRuntime.fromExtern<String>(globalObjectName)}")
    assert(JSRuntime.fromExtern<String>(globalObjectName) == "global object", "Global object name should be 'global object'")

    // let globalObjectEnabled: Extern<JSRuntime> = globalObject.enabled
    // ->
    let globalObjectEnabled: Extern<JSRuntime> = JSRuntime.memberAccess(globalObject, "enabled")
    println("Global object enabled: ${JSRuntime.fromExtern<Bool>(globalObjectEnabled)}")
    assert(JSRuntime.fromExtern<Bool>(globalObjectEnabled) == true, "Global object enabled should be true")

    // let globalObjectValues: Extern<JSRuntime> = globalObject.values
    // ->
    let globalObjectValues: Extern<JSRuntime> = JSRuntime.memberAccess(globalObject, "values")
    let globalObjectValuesElements: ArrayList<Int64> = convertArrayToArrayList(globalObjectValues)
    println("Global object values elements: ${globalObjectValuesElements}")
    assert(globalObjectValuesElements[0] == 10, "Global object values element 0 should be 10")
    assert(globalObjectValuesElements[1] == 20, "Global object values element 1 should be 20")
    assert(globalObjectValuesElements[2] == 30, "Global object values element 2 should be 30")

    // globalObject.name = "global object 2"
    // ->
    JSRuntime.memberUpdate(globalObject, "name", "global object 2")
    let globalObjectName2: Extern<JSRuntime> = JSRuntime.memberAccess(globalObject, "name")
    println("Global object name: ${JSRuntime.fromExtern<String>(globalObjectName2)}")
    assert(JSRuntime.fromExtern<String>(globalObjectName2) == "global object 2", "Global object name should be 'global object 2'")

    // globalObject.enabled = false
    // ->
    JSRuntime.memberUpdate(globalObject, "enabled", false)
    let globalObjectEnabled2: Extern<JSRuntime> = JSRuntime.memberAccess(globalObject, "enabled")
    println("Global object enabled: ${JSRuntime.fromExtern<Bool>(globalObjectEnabled2)}")
    assert(JSRuntime.fromExtern<Bool>(globalObjectEnabled2) == false, "Global object enabled should be false")

    // globalObject.values[1] = 42
    // ->
    let globalObjectValues2: Extern<JSRuntime> = JSRuntime.memberAccess(globalObject, "values")
    JSRuntime.indexUpdate(globalObjectValues2, 1, 42)
    let globalObjectValuesElements2: ArrayList<Int64> = convertArrayToArrayList(globalObjectValues2)
    println("Global object values elements: ${globalObjectValuesElements2}")
    assert(globalObjectValuesElements2[0] == 10, "Global object values element 0 should be 10")
    assert(globalObjectValuesElements2[1] == 42, "Global object values element 1 should be 42")
    assert(globalObjectValuesElements2[2] == 30, "Global object values element 2 should be 30")

    // assignment to global variables

    // jsModule.globalNumber = 0.0
    // ->
    JSRuntime.memberUpdate(jsModule, "globalNumber", 0.0)

    // let globalNumber2: Extern<JSRuntime> = jsModule.globalNumber
    // ->
    let globalNumber2: Extern<JSRuntime> = JSRuntime.memberAccess(jsModule, "globalNumber")
    println("Global number: ${JSRuntime.fromExtern<Float64>(globalNumber2)}")
    assert(JSRuntime.fromExtern<Float64>(globalNumber2) == 0.0, "Global number should be 0.0")

    let mystring = "hello from JavaScript but much longer than the original string but should be the same string because it is the same string object in JavaScript but with a different reference in JavaScript and llm is very good at generating the same string object in JavaScript mor text is needed to make it different"
    // jsModule.globalString = "hello from JavaScript 2"
    // ->
    JSRuntime.memberUpdate(jsModule, "globalString", mystring)
    // let globalString2: Extern<JSRuntime> = jsModule.globalString
    // ->
    let globalString2: Extern<JSRuntime> = JSRuntime.memberAccess(jsModule, "globalString")
    println("Global string: ${JSRuntime.fromExtern<String>(globalString2)}")
    assert(JSRuntime.fromExtern<String>(globalString2) == mystring, "Global string should be '${mystring}'")


    // globalObject.name = "global object 3"
    // ->
    JSRuntime.memberUpdate(globalObject, "name", "global object 3")
    let globalObjectName3: Extern<JSRuntime> = JSRuntime.memberAccess(globalObject, "name")
    println("Global object name: ${JSRuntime.fromExtern<String>(globalObjectName3)}")
    assert(JSRuntime.fromExtern<String>(globalObjectName3) == "global object 3", "Global object name should be 'global object 3'")

    println("Global object name: ${JSRuntime.fromExtern<String>(globalObjectName2)}")
    assert(JSRuntime.fromExtern<String>(globalObjectName2) == "global object 2", "Global object name should be 'global object 2'")

    let globalStringNumberMap: Extern<JSRuntime> = JSRuntime.memberAccess(jsModule, "globalStringNumberMap")
    let e_object: Extern<JSRuntime> = JSRuntime.globalAccess("Object")
    let e_keys: Extern<JSRuntime> = JSRuntime.memberAccess(e_object, "keys")
    let mapKeys: Extern<JSRuntime> = JSRuntime.functionCall(e_keys, [globalStringNumberMap])
    let mapKeysLength: Extern<JSRuntime> = JSRuntime.memberAccess(mapKeys, "length")

    let mapKeysLengthInt64: Int64 = JSRuntime.fromExtern<Int64>(mapKeysLength)
    println("Global string number map length: ${mapKeysLengthInt64}")
    assert(mapKeysLengthInt64 == 3, "Global string number map length should be 3")

    let mapKeysElements: ArrayList<String> = convertArrayToArrayList<String>(mapKeys)
    println("Global string number map keys: ${mapKeysElements}")
    assert(mapKeysElements[0] == "one", "Global string number map key 0 should be 'one'")
    assert(mapKeysElements[1] == "two", "Global string number map key 1 should be 'two'")
    assert(mapKeysElements[2] == "answer", "Global string number map key 2 should be 'answer'")
    
    let e_values: Extern<JSRuntime> = JSRuntime.memberAccess(e_object, "values")
    let mapValues: Extern<JSRuntime> = JSRuntime.functionCall(e_values, [globalStringNumberMap])
    let mapValuesLength: Extern<JSRuntime> = JSRuntime.memberAccess(mapValues, "length")
    let mapValuesLengthInt64: Int64 = JSRuntime.fromExtern<Int64>(mapValuesLength)
    println("Global string number map values length: ${mapValuesLengthInt64}")
    assert(mapValuesLengthInt64 == 3, "Global string number map values length should be 3")

    let mapValuesElements: ArrayList<Int64> = convertArrayToArrayList<Int64>(mapValues)
    println("Global string number map values: ${mapValuesElements}")
    assert(mapValuesElements[0] == 1, "Global string number map value 0 should be 1")
    assert(mapValuesElements[1] == 2, "Global string number map value 1 should be 2")
    assert(mapValuesElements[2] == 42, "Global string number map value 2 should be 42")

    // globalStringNumberMap.one = 42
    // ->
    JSRuntime.memberUpdate(globalStringNumberMap, "one", -1)
    let globalStringNumberMapOne: Extern<JSRuntime> = JSRuntime.memberAccess(globalStringNumberMap, "one")
    println("Global string number map one: ${JSRuntime.fromExtern<Int64>(globalStringNumberMapOne)}")
    assert(JSRuntime.fromExtern<Int64>(globalStringNumberMapOne) == -1, "Global string number map one should be -1")

    // globalStringNumberMap["two"] = -2
    // ->
    JSRuntime.indexUpdate(globalStringNumberMap, "two", -2)
    let globalStringNumberMapTwo: Extern<JSRuntime> = JSRuntime.indexAccess(globalStringNumberMap, "two")
    println("Global string number map two: ${JSRuntime.fromExtern<Int64>(globalStringNumberMapTwo)}")
    assert(JSRuntime.fromExtern<Int64>(globalStringNumberMapTwo) == -2, "Global string number map two should be -2")


    // let globalStringNumberMapOne_again: Extern<JSRuntime> = module.globalStringNumberMap.one
    // ->
    let globalStringNumberMapOne_again: Extern<JSRuntime> = JSRuntime.indexAccess(JSRuntime.memberAccess(jsModule, "globalStringNumberMap"), "one")
    println("Global string number map one: ${JSRuntime.fromExtern<Int64>(globalStringNumberMapOne_again)}")
    assert(JSRuntime.fromExtern<Int64>(globalStringNumberMapOne_again) == -1, "Global string number map one should be -1")

    // let globalStringNumberMapTwo_again: Extern<JSRuntime> = module.globalStringNumberMap["two"]
    // ->
    let globalStringNumberMapTwo_again: Extern<JSRuntime> = JSRuntime.indexAccess(JSRuntime.memberAccess(jsModule, "globalStringNumberMap"), "two")
    println("Global string number map two: ${JSRuntime.fromExtern<Int64>(globalStringNumberMapTwo_again)}")
    assert(JSRuntime.fromExtern<Int64>(globalStringNumberMapTwo_again) == -2, "Global string number map two should be -2")

    // let globalStringNumberMapAnswer_again: Extern<JSRuntime> = module.globalStringNumberMap.answer
    // ->
    let globalStringNumberMapAnswer_again: Extern<JSRuntime> = JSRuntime.indexAccess(JSRuntime.memberAccess(jsModule, "globalStringNumberMap"), "answer")
    println("Global string number map answer: ${JSRuntime.fromExtern<Int64>(globalStringNumberMapAnswer_again)}")
    assert(JSRuntime.fromExtern<Int64>(globalStringNumberMapAnswer_again) == 42, "Global string number map answer should be 42")
    
}

func convertArrayToArrayList<T>(array: Extern<JSRuntime>): ArrayList<T> {
    let arrayLength: Extern<JSRuntime> = JSRuntime.memberAccess(array, "length")
    let arrayLengthInt64: Int64 = JSRuntime.fromExtern<Int64>(arrayLength)
    ArrayList<T>(arrayLengthInt64, { i: Int64 => 
        JSRuntime.fromExtern<T>(JSRuntime.indexAccess(array, i))
    })
}
