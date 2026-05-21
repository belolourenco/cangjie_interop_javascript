package smoke

import extern.Extern
import interop_javascript.JSRuntime

func runLoadModulesSmoke(): Int64 {
    JSRuntime.enableStdModule()
    JSRuntime.enableStdModule()

    let module: Extern<JSRuntime> = JSRuntime.getModule("js_examples/ok/shape_module.js")

    let lookup: Extern<JSRuntime> = JSRuntime.evalMemberAccess(module, "lookup")
    let siteValue: Extern<JSRuntime> = JSRuntime.evalFunctionCall(lookup, [47.6205, -122.3493])
    let siteName: Extern<JSRuntime> = JSRuntime.evalMemberAccess(siteValue, "name")
    if (JSRuntime.fromExtern<String>(siteName) != "Space Needle") {
        println("module function returned unexpected object")
        return 1
    }
    JSRuntime.close(siteName)

    let coordinatesValue: Extern<JSRuntime> = JSRuntime.evalMemberAccess(siteValue, "coordinates")
    let longitude: Extern<JSRuntime> = JSRuntime.evalIndexAccess(coordinatesValue, 0)
    if (JSRuntime.fromExtern<Float64>(longitude) != -122.3493) {
        println("module function returned unexpected longitude")
        return 2
    }
    JSRuntime.close(longitude)
    JSRuntime.close(coordinatesValue)
    JSRuntime.close(siteValue)
    JSRuntime.close(lookup)

    let rectangleClass: Extern<JSRuntime> = JSRuntime.evalMemberAccess(module, "Rectangle")
    let instance: Extern<JSRuntime> = JSRuntime.evalFunctionCall(rectangleClass, [Int32(6), Int32(7)])
    let areaMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(instance, "area")
    let area: Extern<JSRuntime> = JSRuntime.evalFunctionCall(areaMethod, [])
    if (JSRuntime.fromExtern<Float64>(area) != 42.0) {
        println("module class export did not work")
        return 3
    }
    JSRuntime.close(area)
    JSRuntime.close(areaMethod)
    JSRuntime.close(instance)
    JSRuntime.close(rectangleClass)

    let marker: Extern<JSRuntime> = JSRuntime.evalMemberAccess(module, "moduleMarker")
    let cachedModule: Extern<JSRuntime> = JSRuntime.getModule("js_examples/ok/shape_module.js")
    let cachedMarker: Extern<JSRuntime> = JSRuntime.evalMemberAccess(cachedModule, "moduleMarker")
    if (JSRuntime.fromExtern<Float64>(marker) != JSRuntime.fromExtern<Float64>(cachedMarker)) {
        println("module cache did not preserve evaluated namespace")
        return 4
    }
    JSRuntime.close(cachedMarker)
    JSRuntime.close(cachedModule)
    JSRuntime.close(marker)

    try {
        let nonFunction: Extern<JSRuntime> = JSRuntime.evalMemberAccess(module, "moduleMarker")
        let unexpected: Extern<JSRuntime> = JSRuntime.evalFunctionCall(nonFunction, [])
        JSRuntime.close(unexpected)
        JSRuntime.close(nonFunction)
        println("module call unexpectedly accepted a non-function")
        return 5
    } catch (_) {
        ()
    }

    JSRuntime.close(module)

    println("load_modules ok")
    return 0
}
