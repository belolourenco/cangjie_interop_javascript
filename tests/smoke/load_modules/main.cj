package interop_javascript_smoke_load_modules

import interop_javascript.jsinterop.*

main(): Int64 {
    let runtime = JSRuntime(".")
    runtime.enableStdModule()
    runtime.enableStdModule()

    let module = runtime.importModule("examples/shape_module.js")
    let keys = module.keys()
    var sawLookup = false
    var sawRectangle = false
    var sawMarker = false
    for (key in keys) {
        if (key == "lookup") {
            sawLookup = true
        }
        if (key == "Rectangle") {
            sawRectangle = true
        }
        if (key == "moduleMarker") {
            sawMarker = true
        }
    }
    if (!sawLookup || !sawRectangle || !sawMarker) {
        println("module namespace missing expected exports")
        return 1
    }

    let lookupValue = module.get("lookup")
    let lookup = lookupValue.asFunction()
    let lookupLat = JSValue.float64(runtime, 47.6205)
    let lookupLong = JSValue.float64(runtime, -122.3493)
    let siteValue = lookup.call([lookupLat, lookupLong])
    let site = siteValue.asObject()
    let siteName = site.get("name")
    if (siteName.asString() != "Space Needle") {
        println("module function returned unexpected object")
        return 2
    }
    siteName.close()

    let coordinatesValue = site.get("coordinates")
    let coordinates = coordinatesValue.asArray()
    if (coordinates.length() != 2) {
        println("module function returned unexpected array")
        return 3
    }

    let longitude = coordinates.get(0)
    if (longitude.asFloat64() != -122.3493) {
        println("module function returned unexpected longitude")
        return 4
    }
    longitude.close()
    coordinatesValue.close()
    siteValue.close()
    lookupLong.close()
    lookupLat.close()
    lookupValue.close()

    let rectangleValue = module.get("Rectangle")
    let rectangleClass = rectangleValue.asFunction()
    let width = JSValue.int64(runtime, 6)
    let height = JSValue.int64(runtime, 7)
    let instance = rectangleClass.construct([width, height])
    let rectangle = instance.asObject()
    let areaValue = rectangle.get("area")
    let areaMethod = areaValue.asFunction()
    let area = areaMethod.callWithThis(instance, [])
    if (area.asFloat64() != 42.0) {
        println("module class export did not work")
        return 5
    }
    area.close()
    areaValue.close()
    instance.close()
    height.close()
    width.close()
    rectangleValue.close()

    let marker = module.get("moduleMarker")
    let cachedModule = runtime.importModule("examples/shape_module.js")
    let cachedMarker = cachedModule.get("moduleMarker")
    if (marker.asFloat64() != cachedMarker.asFloat64()) {
        println("module cache did not preserve evaluated namespace")
        return 6
    }
    cachedMarker.close()
    cachedModule.close()
    marker.close()

    if (module.getFloat64("moduleMarker") <= 0.0) {
        println("module getFloat64 helper returned unexpected marker")
        return 7
    }

    let helperLat = JSValue.float64(runtime, 47.6205)
    let helperLong = JSValue.float64(runtime, -122.3493)
    let helperSiteValue = module.call("lookup", [helperLat, helperLong])
    let helperSite = helperSiteValue.asObject()
    if (helperSite.getString("name") != "Space Needle") {
        println("module call helper returned unexpected object")
        return 8
    }
    let helperCoordinatesValue = helperSite.getArray("coordinates")
    let helperCoordinates = helperCoordinatesValue.asArray()
    if (helperCoordinates.getFloat64(0) != -122.3493) {
        println("module call helper returned unexpected array")
        return 9
    }
    helperCoordinatesValue.close()
    helperSiteValue.close()
    helperLong.close()
    helperLat.close()

    let constructWidth = JSValue.int64(runtime, 6)
    let constructHeight = JSValue.int64(runtime, 7)
    let constructedInstance = module.construct("Rectangle", [constructWidth, constructHeight])
    let constructedRectangle = constructedInstance.asObject()
    let constructedArea = constructedRectangle.call("area", [])
    if (constructedArea.asFloat64() != 42.0) {
        println("module construct or object call helper failed")
        return 10
    }
    constructedArea.close()
    constructedInstance.close()
    constructHeight.close()
    constructWidth.close()

    try {
        let unexpected = module.call("moduleMarker", [])
        unexpected.close()
        println("module call helper unexpectedly accepted a non-function")
        return 11
    } catch (_) {
        ()
    }

    module.close()
    runtime.close()

    println("load_modules ok")
    return 0
}

