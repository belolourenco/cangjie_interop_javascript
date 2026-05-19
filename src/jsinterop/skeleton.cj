package interop_javascript.jsinterop

foreign func quickjs_bridge_smoke(): Int64

public func jsInteropVersion(): String {
    "0.1.0-phase1"
}

public func jsInteropSmokeTest(): String {
    "jsinterop skeleton ok"
}

public func nativeSmokeValue(): Int64 {
    unsafe {
        quickjs_bridge_smoke()
    }
}

