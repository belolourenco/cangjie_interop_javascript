package extern_with_modules

import extern.Extern
import interop_javascript.JSRuntime

public func testExternWithModules1() {
    // ---- JavaScript Module ----
    let jsModule: Extern<JSRuntime> = JSRuntime.getModule("js_examples/my_module.js")

    // ---- my_javascript_function ----

    // jsModule.my_javascript_function()
    // ->
    let my_javascript_function: Extern<JSRuntime> = JSRuntime.evalMemberAccess(jsModule, "my_javascript_function")
    JSRuntime.evalFunctionCall(my_javascript_function, [])

    // ---- lookup ----

    // let lookupResult: Extern<JSRuntime> = jsModule.lookup(42.4242, 1.111)
    // ->
    let lookup: Extern<JSRuntime> = JSRuntime.evalMemberAccess(jsModule, "lookup")
    let lookupResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(lookup, [42.4242, 1.111])

    // println("Lookup coordinates: (${(lookupResult.coordinates[0] as Float64).getOrThrow()}, ${(lookupResult.coordinates[1] as Float64).getOrThrow()})")
    // ->
    let lookup_coordinates: Extern<JSRuntime> = JSRuntime.evalMemberAccess(lookupResult, "coordinates")
    let lookup_coordinates_0: Extern<JSRuntime> = JSRuntime.evalIndexAccess(lookup_coordinates, 0)
    let lookup_coordinates_1: Extern<JSRuntime> = JSRuntime.evalIndexAccess(lookup_coordinates, 1)
    println("Lookup coordinates: (${JSRuntime.fromExtern<Float64>(lookup_coordinates_0)}, ${JSRuntime.fromExtern<Float64>(lookup_coordinates_1)})")

    // println("Lookup result: ${lookupResult.name}")
    // ->
    let lookup_name: Extern<JSRuntime> = JSRuntime.evalMemberAccess(lookupResult, "name")
    println("Lookup name: ${JSRuntime.fromExtern<String>(lookup_name)}")

    // println("Lookup result: ${lookupResult.city}")
    // ->
    let lookup_city: Extern<JSRuntime> = JSRuntime.evalMemberAccess(lookupResult, "city")
    println("Lookup city: ${JSRuntime.fromExtern<String>(lookup_city)}")

    // println("Lookup result: ${lookupResult.category}")
    // ->
    let lookup_category: Extern<JSRuntime> = JSRuntime.evalMemberAccess(lookupResult, "category")
    println("Lookup category: ${JSRuntime.fromExtern<String>(lookup_category)}")

    // ---- Rectangle ----

    // let rectangle: Extern<JSRuntime> = jsModule.Rectangle(10, 11)
    // ->
    let rectangleConstructor: Extern<JSRuntime> = JSRuntime.evalMemberAccess(jsModule, "Rectangle")
    let rectangleObject: Extern<JSRuntime> = JSRuntime.evalFunctionCall(rectangleConstructor, [10, 11])

    // let rectangleWidth: Extern<JSRuntime> = rectangleObject.getWidth()
    // ->
    let rectangleWidthMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject, "getWidth")
    let rectangleWidthResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(rectangleWidthMethod, [])
    println("Rectangle width: ${JSRuntime.fromExtern<Float64>(rectangleWidthResult)}")

    // let rectangleHeight: Extern<JSRuntime> = rectangleObject.getHeight()
    // ->
    let rectangleHeightMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject, "getHeight")
    let rectangleHeightResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(rectangleHeightMethod, [])
    println("Rectangle height: ${JSRuntime.fromExtern<Float64>(rectangleHeightResult)}")

    // ---- createRectangle ----

    // let rectangleObject2: Extern<JSRuntime> = jsModule.createRectangle()
    // ->
    let createRectangleMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(jsModule, "createRectangle")
    let rectangleObject2: Extern<JSRuntime> = JSRuntime.evalFunctionCall(createRectangleMethod, [])

    // rectangleObject2.width = 42
    // ->
    JSRuntime.evalAssignment(rectangleObject2, "width", 42.0)

    // let rectangleWidth2: Extern<JSRuntime> = rectangleObject2.width
    // ->
    let rectangleWidthResult2: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject2, "width")
    println("Rectangle width: ${JSRuntime.fromExtern<Float64>(rectangleWidthResult2)}")

    // let rectangleHeight2: Extern<JSRuntime> = rectangleObject2.height
    // ->
    let rectangleHeightResult2: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject2, "height")
    println("Rectangle height: ${JSRuntime.fromExtern<Float64>(rectangleHeightResult2)}")

    // let area = rectangleObject2.area()
    // ->
    let areaMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject2, "area")
    let areaResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(areaMethod, [])
    println("Rectangle area: ${JSRuntime.fromExtern<Float64>(areaResult)}")

    // let perimeter = rectangleObject2.perimeter()
    // ->
    let perimeterMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject2, "perimeter")
    let perimeterResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(perimeterMethod, [])
    println("Rectangle perimeter: ${JSRuntime.fromExtern<Float64>(perimeterResult)}")

}
