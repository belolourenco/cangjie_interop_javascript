package extern_with_modules

import extern.Extern
import interop_javascript.JSRuntime

public class Point {
    public let blob: Extern<JSRuntime>

    public init(module: Extern<JSRuntime>, x: Float64, y: Float64) {
        println("Point constructor called with x: ${x}, y: ${y}")
        let pointConstructor: Extern<JSRuntime> = JSRuntime.memberAccess(module, "Point")
        blob = JSRuntime.functionCall(pointConstructor, [x, y])
    }

    // Shallow copy constructor!
    public init(extern: Extern<JSRuntime>) {
        println("Point extern constructor called")
        blob = extern
    }

    // Deep copy constructor!
    public init(module: Extern<JSRuntime>, other: Point) {
        println("Point copy constructor called with x: ${other.x}, y: ${other.y}")
        let pointConstructor: Extern<JSRuntime> = JSRuntime.memberAccess(module, "Point")
        blob = JSRuntime.functionCall(pointConstructor, [other.x, other.y])
    }

    public mut prop x: Float64 {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.memberAccess(blob, "x")
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            JSRuntime.memberUpdate(blob, "x", value)
        }
    }

    public mut prop y: Float64 {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.memberAccess(blob, "y")
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            JSRuntime.memberUpdate(blob, "y", value)
        }
    }

    public func distanceTo(other: Point): Float64 {
        let distanceToMethod: Extern<JSRuntime> = JSRuntime.memberAccess(blob, "distanceTo")
        let result: Extern<JSRuntime> = JSRuntime.functionCall(distanceToMethod, [other.blob])
        JSRuntime.fromExtern<Float64>(result)
    }
}

public interface Shape {

    func getBlob(): Extern<JSRuntime>

    func name(): String {
        let nameMethod: Extern<JSRuntime> = JSRuntime.memberAccess(getBlob(), "name")
        let result: Extern<JSRuntime> = JSRuntime.functionCall(nameMethod, [])
        JSRuntime.fromExtern<String>(result)
    }

    func area(): Float64 {
        let areaMethod: Extern<JSRuntime> = JSRuntime.memberAccess(getBlob(), "area")
        let result: Extern<JSRuntime> = JSRuntime.functionCall(areaMethod, [])
        JSRuntime.fromExtern<Float64>(result)
    }

    func perimeter(): Float64 {
        let perimeterMethod: Extern<JSRuntime> = JSRuntime.memberAccess(getBlob(), "perimeter")
        let result: Extern<JSRuntime> = JSRuntime.functionCall(perimeterMethod, [])
        JSRuntime.fromExtern<Float64>(result)
    }
}

public class Rectangle <: Shape {
    public let blob: Extern<JSRuntime>

    public init(module: Extern<JSRuntime>, topLeft: Point, bottomRight: Point) {
        println("Rectangle constructor called with topLeft: ${topLeft.x}, ${topLeft.y} and bottomRight: ${bottomRight.x}, ${bottomRight.y}")
        let rectangleConstructor: Extern<JSRuntime> = JSRuntime.memberAccess(module, "Rectangle")
        blob = JSRuntime.functionCall(rectangleConstructor, [topLeft.blob, bottomRight.blob])
    }

    public init(extern: Extern<JSRuntime>) {
        blob = extern
    }

    public func getBlob(): Extern<JSRuntime> {
        blob
    }

    public mut prop topLeft: Point {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.memberAccess(blob, "topLeft")
            Point(value)
        }
        set(value) {
            JSRuntime.memberUpdate(blob, "topLeft", value.blob)
        }
    }

    public mut prop bottomRight: Point {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.memberAccess(blob, "bottomRight")
            Point(value)
        }
        set(value) {
            JSRuntime.memberUpdate(blob, "bottomRight", value.blob)
        }
    }

    public mut prop width: Float64 {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.memberAccess(blob, "width")
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            JSRuntime.memberUpdate(blob, "width", value)
        }
    }

    public mut prop height: Float64 {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.memberAccess(blob, "height")
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            JSRuntime.memberUpdate(blob, "height", value)
        }
    }
}

public class Circle <: Shape {
    public let blob: Extern<JSRuntime>

    public init(module: Extern<JSRuntime>, center: Point, radius: Float64) {
        let circleConstructor: Extern<JSRuntime> = JSRuntime.memberAccess(module, "Circle")
        blob = JSRuntime.functionCall(circleConstructor, [center.blob, radius])
    }

    public init(extern: Extern<JSRuntime>) {
        blob = extern
    }

    public func getBlob(): Extern<JSRuntime> {
        blob
    }

    public mut prop center: Point {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.memberAccess(blob, "center")
            Point(value)
        }
        set(value) {
            JSRuntime.memberUpdate(blob, "center", value.blob)
        }
    }

    public mut prop radius: Float64 {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.memberAccess(blob, "radius")
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            JSRuntime.memberUpdate(blob, "radius", value)
        }
    }
}

public class Triangle <: Shape {
    public let blob: Extern<JSRuntime>

    public init(module: Extern<JSRuntime>, a: Point, b: Point, c: Point) {
        let triangleConstructor: Extern<JSRuntime> = JSRuntime.memberAccess(module, "Triangle")
        blob = JSRuntime.functionCall(triangleConstructor, [a.blob, b.blob, c.blob])
    }

    public init(extern: Extern<JSRuntime>) {
        blob = extern
    }

    public func getBlob(): Extern<JSRuntime> {
        blob
    }

    public mut prop a: Point {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.memberAccess(blob, "a")
            Point(value)
        }
        set(value) {
            JSRuntime.memberUpdate(blob, "a", value.blob)
        }
    }

    public mut prop b: Point {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.memberAccess(blob, "b")
            Point(value)
        }
        set(value) {
            JSRuntime.memberUpdate(blob, "b", value.blob)
        }
    }

    public mut prop c: Point {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.memberAccess(blob, "c")
            Point(value)
        }
        set(value) {
            JSRuntime.memberUpdate(blob, "c", value.blob)
        }
    }
}
