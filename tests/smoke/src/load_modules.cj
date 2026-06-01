package smoke

import std.interop.Extern
import interop_javascript.JSRuntime

func runLoadModulesSmoke(): Int64 {
    JSRuntime.enableStdModule()
    JSRuntime.enableStdModule()

    let module: Extern<JSRuntime> = JSRuntime.getModule("js_examples/ok/shape_module.js")

    let lookup: Extern<JSRuntime> = JSRuntime.memberAccess(module, "lookup")
    let siteValue: Extern<JSRuntime> = JSRuntime.functionCall(lookup, [47.6205, -122.3493])
    let siteName: Extern<JSRuntime> = JSRuntime.memberAccess(siteValue, "name")
    if (JSRuntime.fromExtern<String>(siteName) != "Space Needle") {
        println("module function returned unexpected object")
        return 1
    }

    let coordinatesValue: Extern<JSRuntime> = JSRuntime.memberAccess(siteValue, "coordinates")
    let longitude: Extern<JSRuntime> = JSRuntime.indexAccess(coordinatesValue, 0)
    if (JSRuntime.fromExtern<Float64>(longitude) != -122.3493) {
        println("module function returned unexpected longitude")
        return 2
    }

    let rectangleClass: Extern<JSRuntime> = JSRuntime.memberAccess(module, "Rectangle")
    let instance: Extern<JSRuntime> = JSRuntime.functionCall(rectangleClass, [Int32(6), Int32(7)])
    let areaMethod: Extern<JSRuntime> = JSRuntime.memberAccess(instance, "area")
    let area: Extern<JSRuntime> = JSRuntime.functionCall(areaMethod, [])
    if (JSRuntime.fromExtern<Float64>(area) != 42.0) {
        println("module class export did not work")
        return 3
    }

    let marker: Extern<JSRuntime> = JSRuntime.memberAccess(module, "moduleMarker")
    let cachedModule: Extern<JSRuntime> = JSRuntime.getModule("js_examples/ok/shape_module.js")
    let cachedMarker: Extern<JSRuntime> = JSRuntime.memberAccess(cachedModule, "moduleMarker")
    if (JSRuntime.fromExtern<Float64>(marker) != JSRuntime.fromExtern<Float64>(cachedMarker)) {
        println("module cache did not preserve evaluated namespace")
        return 4
    }

    try {
        let nonFunction: Extern<JSRuntime> = JSRuntime.memberAccess(module, "moduleMarker")
        let unexpected: Extern<JSRuntime> = JSRuntime.functionCall(nonFunction, [])
        println("module call unexpectedly accepted a non-function")
        return 5
    } catch (_) {
        ()
    }

    println("load_modules ok")
    return 0
}
