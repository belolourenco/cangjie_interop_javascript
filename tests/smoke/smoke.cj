package interop_javascript_smoke

import interop_javascript.jsinterop.*

main(): Int64 {
    if (jsInteropVersion() != "0.1.0-phase6") {
        println("unexpected jsinterop version")
        return 1
    }

    if (jsInteropSmokeTest() != "jsinterop phase6 ok") {
        println("unexpected jsinterop smoke message")
        return 2
    }

    try (runtime = JSRuntime(".")) {
        try (value = JSValue.bool(runtime, true)) {
            if (!value.isBool() || !value.asBool()) {
                println("unexpected Cangjie bool JSValue conversion")
                return 3
            }
        }

        try (value = JSValue.int64(runtime, 42)) {
            if (!value.isNumber() || value.asFloat64() != 42.0) {
                println("unexpected Cangjie Int64 JSValue conversion")
                return 4
            }
        }

        try (value = JSValue.string(runtime, "hello")) {
            if (!value.isString() || value.asString() != "hello") {
                println("unexpected Cangjie string JSValue conversion")
                return 5
            }
        }

        try (nullValue = JSValue.null(runtime)) {
            try (undefinedValue = JSValue.undefined(runtime)) {
                if (!nullValue.isNull() || !undefinedValue.isUndefined()) {
                    println("unexpected Cangjie null/undefined JSValue conversion")
                    return 6
                }
            }
        }

        println("runtime created")
        println("runtime eval: 1 + 2")
        try (result = runtime.evalScript("1 + 2")) {
            println("result: ${result.isOk()} - ${result.asFloat64()}")
            if (!result.isOk() || !result.isNumber()) {
                println("unexpected eval error: ${result.errorMessage()}")
                return 7
            }
            if (result.asFloat64() != 3.0) {
                println("unexpected eval result")
                return 8
            }
        }

        try (boolResult = runtime.evalScript("true")) {
            if (!boolResult.isOk() || !boolResult.isBool() || !boolResult.asBool()) {
                println("unexpected boolean eval result")
                return 9
            }

            try {
                boolResult.asFloat64()
                println("boolean converted to number unexpectedly")
                return 10
            } catch (_) {
                ()
            }
        }

        try (first = runtime.evalScript("'hello'")) {
            try (second = runtime.evalScript("'world'")) {
                if (first.asString() != "hello" || second.asString() != "world") {
                    println("native value handles were overwritten by later eval")
                    return 11
                }
            }
        }

        try (stringResult = runtime.evalScript("'hello from js'")) {
            if (!stringResult.isOk() || !stringResult.isString() || stringResult.asString() != "hello from js") {
                println("unexpected string eval result")
                return 12
            }
        }

        try (nullResult = runtime.evalScript("null")) {
            if (!nullResult.isOk() || !nullResult.isNull()) {
                println("unexpected null eval result")
                return 13
            }
        }

        try (undefinedResult = runtime.evalScript("undefined")) {
            if (!undefinedResult.isOk() || !undefinedResult.isUndefined()) {
                println("unexpected undefined eval result")
                return 14
            }
        }

        try (bigIntResult = runtime.evalScript("9007199254740993n")) {
            if (!bigIntResult.isOk() || !bigIntResult.isBigInt() || bigIntResult.asString() != "9007199254740993") {
                println("unexpected bigint eval result")
                return 15
            }
        }

        try (objectResult = runtime.evalScript("({ name: 'Space Needle', coordinates: [-122.3493, 47.6205] })")) {
            if (!objectResult.isOk() || !objectResult.isObject() || objectResult.typeOf() != "object") {
                println("object eval did not return a native value handle")
                return 16
            }

            let object = objectResult.asObject()
            try (name = object.get("name")) {
                if (!name.isString() || name.asString() != "Space Needle") {
                    println("unexpected object property value")
                    return 17
                }
            }

            try (newName = JSValue.string(runtime, "Seattle Center")) {
                object.set("name", newName)
            }
            try (name = object.get("name")) {
                if (name.asString() != "Seattle Center") {
                    println("object property write failed")
                    return 18
                }
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
                return 19
            }

            try (missing = object.get("missing")) {
                if (!missing.isUndefined()) {
                    println("missing object property was not undefined")
                    return 20
                }
            }

            try (coordinatesValue = object.get("coordinates")) {
                if (!coordinatesValue.isArray() || coordinatesValue.typeOf() != "array") {
                    println("coordinates property was not an array")
                    return 21
                }
                let coordinates = coordinatesValue.asArray()
                if (coordinates.length() != 2) {
                    println("unexpected array length")
                    return 22
                }
                try (longitude = coordinates.get(0)) {
                    if (longitude.asFloat64() != -122.3493) {
                        println("unexpected array element")
                        return 23
                    }
                }
                try (updatedLongitude = JSValue.float64(runtime, -123.0)) {
                    coordinates.set(0, updatedLongitude)
                }
                try (longitude = coordinates.get(0)) {
                    if (longitude.asFloat64() != -123.0) {
                        println("array index write failed")
                        return 24
                    }
                }
                try {
                    coordinates.get(2)
                    println("out-of-range array index unexpectedly succeeded")
                    return 25
                } catch (_) {
                    ()
                }
            }
        }

        try (value = JSValue.bool(runtime, true)) {
            runtime.setGlobal("fromCangjieBool", value)
        }
        try (result = runtime.evalScript("fromCangjieBool")) {
            if (!result.asBool()) {
                println("Cangjie bool global did not round trip")
                return 26
            }
        }

        try (value = JSValue.int64(runtime, 42)) {
            runtime.setGlobal("fromCangjieInt", value)
        }
        try (result = runtime.evalScript("fromCangjieInt + 1")) {
            if (result.asFloat64() != 43.0) {
                println("Cangjie Int64 global did not round trip")
                return 27
            }
        }

        try (value = JSValue.float64(runtime, 1.5)) {
            runtime.setGlobal("fromCangjieFloat", value)
        }
        try (result = runtime.evalScript("fromCangjieFloat + 0.5")) {
            if (result.asFloat64() != 2.0) {
                println("Cangjie Float64 global did not round trip")
                return 28
            }
        }

        try (value = JSValue.string(runtime, "hello")) {
            runtime.setGlobal("fromCangjieString", value)
        }
        try (result = runtime.evalScript("fromCangjieString + ' js'")) {
            if (result.asString() != "hello js") {
                println("Cangjie string global did not round trip")
                return 29
            }
        }

        try (value = JSValue.null(runtime)) {
            runtime.setGlobal("fromCangjieNull", value)
        }
        try (result = runtime.evalScript("fromCangjieNull")) {
            if (!result.isNull()) {
                println("Cangjie null global did not round trip")
                return 30
            }
        }

        try (value = JSValue.undefined(runtime)) {
            runtime.setGlobal("fromCangjieUndefined", value)
        }
        try (result = runtime.evalScript("fromCangjieUndefined")) {
            if (!result.isUndefined()) {
                println("Cangjie undefined global did not round trip")
                return 31
            }
        }

        try (functionValue = runtime.evalScript("function add(a, b) { return a + b }; add")) {
            if (!functionValue.isFunction() || functionValue.typeOf() != "function") {
                println("function eval did not return a function")
                return 32
            }
            let add = functionValue.asFunction()
            try (left = JSValue.int64(runtime, 2)) {
                try (right = JSValue.int64(runtime, 3)) {
                    try (sum = add.call([left, right])) {
                        if (!sum.isNumber() || sum.asFloat64() != 5.0) {
                            println("two-argument function call failed")
                            return 33
                        }
                    }
                }
            }
        }

        try (functionValue = runtime.evalScript("function fortyTwo() { return 42 }; fortyTwo")) {
            let fortyTwo = functionValue.asFunction()
            try (result = fortyTwo.call([])) {
                if (result.asFloat64() != 42.0) {
                    println("zero-argument function call failed")
                    return 34
                }
            }
        }

        try (functionValue = runtime.evalScript("function double(x) { return x * 2 }; double")) {
            let double = functionValue.asFunction()
            try (value = JSValue.int64(runtime, 21)) {
                try (result = double.call([value])) {
                    if (result.asFloat64() != 42.0) {
                        println("one-argument function call failed")
                        return 35
                    }
                }
            }
        }

        try (objectValue = runtime.evalScript("({ base: 10, add(n) { return this.base + n } })")) {
            let object = objectValue.asObject()
            try (methodValue = object.get("add")) {
                let method = methodValue.asFunction()
                try (arg = JSValue.int64(runtime, 5)) {
                    try (result = method.callWithThis(objectValue.asValue(), [arg])) {
                        if (result.asFloat64() != 15.0) {
                            println("method call did not preserve this value")
                            return 36
                        }
                    }
                }
            }
        }

        try (classValue = runtime.evalScript("class Rectangle { constructor(width, height) { this.width = width; this.height = height; } area() { return this.width * this.height; } }; Rectangle")) {
            let rectangleClass = classValue.asFunction()
            try (width = JSValue.int64(runtime, 4)) {
                try (height = JSValue.int64(runtime, 5)) {
                    try (instance = rectangleClass.construct([width, height])) {
                        let rectangle = instance.asObject()
                        try (widthValue = rectangle.get("width")) {
                            if (widthValue.asFloat64() != 4.0) {
                                println("constructor did not assign width")
                                return 37
                            }
                        }
                        try (areaMethodValue = rectangle.get("area")) {
                            let areaMethod = areaMethodValue.asFunction()
                            try (area = areaMethod.callWithThis(instance, [])) {
                                if (area.asFloat64() != 20.0) {
                                    println("constructed class method call failed")
                                    return 38
                                }
                            }
                        }
                    }
                }
            }
        }

        try (throwingFunctionValue = runtime.evalScript("function fail() { throw new Error('function failed') }; fail")) {
            let fail = throwingFunctionValue.asFunction()
            try {
                fail.call([])
                println("throwing function unexpectedly succeeded")
                return 39
            } catch (e: Exception) {
                if (!e.toString().contains("function failed")) {
                    println("throwing function error message was not preserved")
                    return 40
                }
            }
        }

        try (throwingConstructorValue = runtime.evalScript("class Broken { constructor() { throw new Error('constructor failed') } }; Broken")) {
            let broken = throwingConstructorValue.asFunction()
            try {
                broken.construct([])
                println("throwing constructor unexpectedly succeeded")
                return 41
            } catch (e: Exception) {
                if (!e.toString().contains("constructor failed")) {
                    println("throwing constructor error message was not preserved")
                    return 42
                }
            }
        }

        runtime.enableStdModule()
        runtime.enableStdModule()

        try (module = runtime.importModule("examples/shape_module.js")) {
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
                return 43
            }

            try (lookupValue = module.get("lookup")) {
                let lookup = lookupValue.asFunction()
                try (lat = JSValue.float64(runtime, 47.6205)) {
                    try (long = JSValue.float64(runtime, -122.3493)) {
                        try (siteValue = lookup.call([lat, long])) {
                            let site = siteValue.asObject()
                            try (name = site.get("name")) {
                                if (name.asString() != "Space Needle") {
                                    println("module function returned unexpected object")
                                    return 44
                                }
                            }
                            try (coordinatesValue = site.get("coordinates")) {
                                let coordinates = coordinatesValue.asArray()
                                if (coordinates.length() != 2) {
                                    println("module function returned unexpected array")
                                    return 45
                                }
                                try (longitude = coordinates.get(0)) {
                                    if (longitude.asFloat64() != -122.3493) {
                                        println("module function returned unexpected longitude")
                                        return 46
                                    }
                                }
                            }
                        }
                    }
                }
            }

            try (rectangleValue = module.get("Rectangle")) {
                let rectangleClass = rectangleValue.asFunction()
                try (width = JSValue.int64(runtime, 6)) {
                    try (height = JSValue.int64(runtime, 7)) {
                        try (instance = rectangleClass.construct([width, height])) {
                            let rectangle = instance.asObject()
                            try (areaValue = rectangle.get("area")) {
                                let areaMethod = areaValue.asFunction()
                                try (area = areaMethod.callWithThis(instance, [])) {
                                    if (area.asFloat64() != 42.0) {
                                        println("module class export did not work")
                                        return 47
                                    }
                                }
                            }
                        }
                    }
                }
            }

            try (marker = module.get("moduleMarker")) {
                try (cachedModule = runtime.importModule("examples/shape_module.js")) {
                    try (cachedMarker = cachedModule.get("moduleMarker")) {
                        if (marker.asFloat64() != cachedMarker.asFloat64()) {
                            println("module cache did not preserve evaluated namespace")
                            return 48
                        }
                    }
                }
            }
        } catch (e: Exception) {
            println("module import failed: ${e.toString()}")
            return 49
        }

        try {
            runtime.importModule("examples/missing_module.js")
            println("missing module unexpectedly loaded")
            return 50
        } catch (e: Exception) {
            if (!e.toString().contains("failed to read JavaScript module file")) {
                println("missing module error message was not preserved")
                return 51
            }
        }

        try {
            runtime.importModule("examples/broken_module.js")
            println("broken module unexpectedly loaded")
            return 52
        } catch (e: Exception) {
            if (e.toString().isEmpty()) {
                println("broken module error message was not preserved")
                return 53
            }
        }

        println("runtime eval: function {")
        try (syntaxError = runtime.evalScript("function {")) {
            println("syntaxError: ${syntaxError.isOk()} - ${syntaxError.errorMessage()}")
            if (syntaxError.isOk()) {
                println("invalid JavaScript unexpectedly succeeded")
                return 54
            }
            if (syntaxError.errorMessage().isEmpty()) {
                println("missing JavaScript syntax error message")
                return 55
            }
        }
    } catch (e: Exception) {
        println("runtime test failed: ${e.toString()}")
        return 56
    }

    println("runtime eval: repeated runtime creation and eval 100 times")
    for (_ in 0..100) {
        try (runtime = JSRuntime()) {
            try (result = runtime.evalScript("1 + 2")) {
                if (!result.isOk() || result.asFloat64() != 3.0) {
                    println("repeated eval failed")
                    return 57
                }
            }
        }
    }
    println("runtime eval: repeated runtime creation and eval 100 times completed")

    println(jsInteropSmokeTest())
    return 0
}