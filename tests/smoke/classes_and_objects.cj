package interop_javascript_smoke

import interop_javascript.jsinterop.*

func runClassesAndObjectsSmoke(): Int64 {
    let runtime = JSRuntime(".")

    let objectResult = runtime.evalScript("({ name: 'Space Needle', active: true, coordinates: [-122.3493, 47.6205], nested: [[1, 2]] })")
    if (!objectResult.isOk() || !objectResult.isObject() || objectResult.typeOf() != "object") {
        println("object eval did not return a native value handle")
        return 1
    }

    let object = objectResult.asObject()
    let name = object.get("name")
    if (!name.isString() || name.asString() != "Space Needle") {
        println("unexpected object property value")
        return 2
    }
    name.close()

    let newName = JSValue.string(runtime, "Seattle Center")
    object.set("name", newName)
    newName.close()

    let updatedName = object.get("name")
    if (updatedName.asString() != "Seattle Center") {
        println("object property write failed")
        return 3
    }
    updatedName.close()

    if (object.getString("name") != "Seattle Center") {
        println("object getString helper did not match low-level get")
        return 4
    }
    if (!object.getBool("active")) {
        println("object getBool helper did not match low-level get")
        return 5
    }

    let keys = object.keys()
    var sawName = false
    var sawCoordinates = false
    for (key in keys) {
        if (key == "name") {
            sawName = true
        }
        if (key == "coordinates") {
            sawCoordinates = true
        }
    }
    if (!sawName || !sawCoordinates) {
        println("object keys missing expected properties")
        return 6
    }

    let missing = object.get("missing")
    if (!missing.isUndefined()) {
        println("missing object property was not undefined")
        return 7
    }
    missing.close()

    let coordinatesValue = object.get("coordinates")
    if (!coordinatesValue.isArray() || coordinatesValue.typeOf() != "array") {
        println("coordinates property was not an array")
        return 8
    }
    let coordinates = coordinatesValue.asArray()
    if (coordinates.length() != 2) {
        println("unexpected array length")
        return 9
    }

    let longitude = coordinates.get(0)
    if (longitude.asFloat64() != -122.3493) {
        println("unexpected array element")
        return 10
    }
    longitude.close()

    let updatedLongitude = JSValue.float64(runtime, -123.0)
    coordinates.set(0, updatedLongitude)
    updatedLongitude.close()

    let changedLongitude = coordinates.get(0)
    if (changedLongitude.asFloat64() != -123.0) {
        println("array index write failed")
        return 11
    }
    changedLongitude.close()

    try {
        coordinates.get(2)
        println("out-of-range array index unexpectedly succeeded")
        return 12
    } catch (_) {
        ()
    }
    coordinatesValue.close()

    let coordinatesValueFromHelper = object.getArray("coordinates")
    let coordinatesFromHelper = coordinatesValueFromHelper.asArray()
    if (coordinatesFromHelper.getFloat64(0) != -123.0) {
        println("object getArray or array getFloat64 helper failed")
        return 13
    }
    coordinatesValueFromHelper.close()

    let nestedValue = object.getArray("nested")
    let nested = nestedValue.asArray()
    let innerValue = nested.getArray(0)
    let inner = innerValue.asArray()
    if (inner.getFloat64(1) != 2.0) {
        println("array getArray helper failed")
        return 14
    }
    innerValue.close()
    nestedValue.close()

    try {
        object.getFloat64("name")
        println("object getFloat64 helper unexpectedly accepted a string")
        return 15
    } catch (_) {
        ()
    }
    objectResult.close()

    let classValue = runtime.evalScript("class Rectangle { constructor(width, height) { this.width = width; this.height = height; } area() { return this.width * this.height; } }; Rectangle")
    let rectangleClass = classValue.asFunction()
    let width = JSValue.int64(runtime, 4)
    let height = JSValue.int64(runtime, 5)
    let instance = rectangleClass.construct([width, height])
    let rectangle = instance.asObject()

    let widthValue = rectangle.get("width")
    if (widthValue.asFloat64() != 4.0) {
        println("constructor did not assign width")
        return 16
    }
    widthValue.close()

    let areaMethodValue = rectangle.get("area")
    let areaMethod = areaMethodValue.asFunction()
    let area = areaMethod.callWithThis(instance, [])
    if (area.asFloat64() != 20.0) {
        println("constructed class method call failed")
        return 17
    }
    area.close()
    areaMethodValue.close()
    instance.close()
    height.close()
    width.close()
    classValue.close()
    runtime.close()

    println("classes_and_objects ok")
    return 0
}
