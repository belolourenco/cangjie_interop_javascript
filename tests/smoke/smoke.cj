package interop_javascript_smoke

import interop_javascript.jsinterop.*

main(): Int64 {
    if (jsInteropVersion() != "0.1.0-phase1") {
        println("unexpected jsinterop version")
        return 1
    }

    if (jsInteropSmokeTest() != "jsinterop skeleton ok") {
        println("unexpected jsinterop smoke message")
        return 2
    }

    if (nativeSmokeValue() != 1) {
        println("unexpected native smoke value")
        return 3
    }

    println(jsInteropSmokeTest())
    return 0
}
