package smoke

import extern.Extern
import interop_javascript.JSRuntime

func runClassesAndObjectsSmoke(): Int64 {
    let objectResult: Extern<JSRuntime> = JSRuntime.evalScript("({ name: 'Space Needle', active: true, coordinates: [-122.3493, 47.6205], nested: [[1, 2]] })")

    let name: Extern<JSRuntime> = JSRuntime.memberAccess(objectResult, "name")
    if (JSRuntime.fromExtern<String>(name) != "Space Needle") {
        println("unexpected object property value")
        return 1
    }

    JSRuntime.memberUpdate(objectResult, "name", "Seattle Center")
    let updatedName: Extern<JSRuntime> = JSRuntime.memberAccess(objectResult, "name")
    if (JSRuntime.fromExtern<String>(updatedName) != "Seattle Center") {
        println("object property write failed")
        return 2
    }

    let coordinatesValue: Extern<JSRuntime> = JSRuntime.memberAccess(objectResult, "coordinates")
    let longitude: Extern<JSRuntime> = JSRuntime.indexAccess(coordinatesValue, 0)
    if (JSRuntime.fromExtern<Float64>(longitude) != -122.3493) {
        println("unexpected array element")
        return 3
    }

    JSRuntime.indexUpdate(coordinatesValue, 0, -123.0)
    let updatedLongitude: Extern<JSRuntime> = JSRuntime.indexAccess(coordinatesValue, 0)
    if (JSRuntime.fromExtern<Float64>(updatedLongitude) != -123.0) {
        println("array index write failed")
        return 4
    }

    try {
        let unexpected: Extern<JSRuntime> = JSRuntime.indexAccess(coordinatesValue, 2)
        println("out-of-range array index unexpectedly succeeded")
        return 5
    } catch (_) {
        ()
    }

    let classValue: Extern<JSRuntime> = JSRuntime.evalScript("class Rectangle { constructor(width, height) { this.width = width; this.height = height; } area() { return this.width * this.height; } }; Rectangle")
    let instance: Extern<JSRuntime> = JSRuntime.functionCall(classValue, [Int32(4), Int32(5)])

    let widthValue: Extern<JSRuntime> = JSRuntime.memberAccess(instance, "width")
    if (JSRuntime.fromExtern<Float64>(widthValue) != 4.0) {
        println("constructor did not assign width")
        return 6
    }

    let areaMethod: Extern<JSRuntime> = JSRuntime.memberAccess(instance, "area")
    let area: Extern<JSRuntime> = JSRuntime.functionCall(areaMethod, [])
    if (JSRuntime.fromExtern<Float64>(area) != 20.0) {
        println("constructed class method call failed")
        return 7
    }

    println("classes_and_objects ok")
    return 0
}
