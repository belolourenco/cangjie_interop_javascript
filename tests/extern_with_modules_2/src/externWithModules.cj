package extern_with_modules

import extern.Extern
import interop_javascript.JSRuntime

public func testExternWithModules() {
    // // ---- JavaScript Module ----
    // let jsModule: Extern<JSRuntime> = JSRuntime.getModule("js_examples/shape.js")

    // // ---- Rectangle ----

    // // let rectangle: Extern<JSRuntime> = jsModule.Rectangle(10, 11)
    // // ->
    // let rectangleConstructor: Extern<JSRuntime> = JSRuntime.evalMemberAccess(jsModule, "Rectangle")
    // let rectangleObject: Extern<JSRuntime> = JSRuntime.evalFunctionCall(rectangleConstructor, [10, 11])

    // // let rectangleWidth: Extern<JSRuntime> = rectangleObject.getWidth()
    // // ->
    // let rectangleWidthMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject, "getWidth")
    // let rectangleWidthResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(rectangleWidthMethod, [])
    // println("Rectangle width: ${JSRuntime.fromExtern<Float64>(rectangleWidthResult)}")

    // // let rectangleHeight: Extern<JSRuntime> = rectangleObject.getHeight()
    // // ->
    // let rectangleHeightMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject, "getHeight")
    // let rectangleHeightResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(rectangleHeightMethod, [])
    // println("Rectangle height: ${JSRuntime.fromExtern<Float64>(rectangleHeightResult)}")

    // // ---- createRectangle ----

    // // let rectangleObject2: Extern<JSRuntime> = jsModule.createRectangle()
    // // ->
    // let createRectangleMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(jsModule, "createRectangle")
    // let rectangleObject2: Extern<JSRuntime> = JSRuntime.evalFunctionCall(createRectangleMethod, [])

    // // rectangleObject2.width = 42
    // // ->
    // JSRuntime.evalAssignment(rectangleObject2, "width", 42.0)

    // // let rectangleWidth2: Extern<JSRuntime> = rectangleObject2.width
    // // ->
    // let rectangleWidthResult2: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject2, "width")
    // println("Rectangle width: ${JSRuntime.fromExtern<Float64>(rectangleWidthResult2)}")

    // // let rectangleHeight2: Extern<JSRuntime> = rectangleObject2.height
    // // ->
    // let rectangleHeightResult2: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject2, "height")
    // println("Rectangle height: ${JSRuntime.fromExtern<Float64>(rectangleHeightResult2)}")

    // // let area = rectangleObject2.area()
    // // ->
    // let areaMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject2, "area")
    // let areaResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(areaMethod, [])
    // println("Rectangle area: ${JSRuntime.fromExtern<Float64>(areaResult)}")

    // // let perimeter = rectangleObject2.perimeter()
    // // ->
    // let perimeterMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject2, "perimeter")
    // let perimeterResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(perimeterMethod, [])
    // println("Rectangle perimeter: ${JSRuntime.fromExtern<Float64>(perimeterResult)}")

}
