package interop_javascript_smoke

import extern.Extern
import interop_javascript.JSRuntime

func runClassesAndObjectsSmoke(): Int64 {
    let objectResult: Extern<JSRuntime> = JSRuntime.evalScript("({ name: 'Space Needle', active: true, coordinates: [-122.3493, 47.6205], nested: [[1, 2]] })")

    let name: Extern<JSRuntime> = JSRuntime.evalMemberAccess(objectResult, "name")
    if (JSRuntime.fromExtern<String>(name) != "Space Needle") {
        println("unexpected object property value")
        return 1
    }
    JSRuntime.close(name)

    JSRuntime.evalAssignment(objectResult, "name", "Seattle Center")
    let updatedName: Extern<JSRuntime> = JSRuntime.evalMemberAccess(objectResult, "name")
    if (JSRuntime.fromExtern<String>(updatedName) != "Seattle Center") {
        println("object property write failed")
        return 2
    }
    JSRuntime.close(updatedName)

    let coordinatesValue: Extern<JSRuntime> = JSRuntime.evalMemberAccess(objectResult, "coordinates")
    let longitude: Extern<JSRuntime> = JSRuntime.evalIndexAccess(coordinatesValue, 0)
    if (JSRuntime.fromExtern<Float64>(longitude) != -122.3493) {
        println("unexpected array element")
        return 3
    }
    JSRuntime.close(longitude)

    try {
        let unexpected: Extern<JSRuntime> = JSRuntime.evalIndexAccess(coordinatesValue, 2)
        JSRuntime.close(unexpected)
        println("out-of-range array index unexpectedly succeeded")
        return 4
    } catch (_) {
        ()
    }
    JSRuntime.close(coordinatesValue)
    JSRuntime.close(objectResult)

    let classValue: Extern<JSRuntime> = JSRuntime.evalScript("class Rectangle { constructor(width, height) { this.width = width; this.height = height; } area() { return this.width * this.height; } }; Rectangle")
    let instance: Extern<JSRuntime> = JSRuntime.evalFunctionCall(classValue, [Int32(4), Int32(5)])

    let widthValue: Extern<JSRuntime> = JSRuntime.evalMemberAccess(instance, "width")
    if (JSRuntime.fromExtern<Float64>(widthValue) != 4.0) {
        println("constructor did not assign width")
        return 5
    }
    JSRuntime.close(widthValue)

    let areaMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(instance, "area")
    let area: Extern<JSRuntime> = JSRuntime.evalFunctionCall(areaMethod, [])
    if (JSRuntime.fromExtern<Float64>(area) != 20.0) {
        println("constructed class method call failed")
        return 6
    }
    JSRuntime.close(area)
    JSRuntime.close(areaMethod)
    JSRuntime.close(instance)
    JSRuntime.close(classValue)

    println("classes_and_objects ok")
    return 0
}
