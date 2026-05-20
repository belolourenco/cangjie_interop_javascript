package extern_with_modules

import extern.Extern
import interop_javascript.JSRuntime

private func shapeModule(): Extern<JSRuntime> {
    JSRuntime.getModule("js_examples/shape.js")
}

public class Point {
    public let blob: Extern<JSRuntime>

    public init(x: Float64, y: Float64) {
        println("Point constructor called with x: ${x}, y: ${y}")
        let pointConstructor: Extern<JSRuntime> = JSRuntime.evalMemberAccess(shapeModule(), "Point")
        blob = JSRuntime.evalFunctionCall(pointConstructor, [x, y])
    }

    // Shallow copy constructor!
    public init(extern: Extern<JSRuntime>) {
        println("Point extern constructor called")
        blob = extern
    }

    // Deep copy constructor!
    public init(other: Point) {
        println("Point copy constructor called with x: ${other.x}, y: ${other.y}")
        let pointConstructor: Extern<JSRuntime> = JSRuntime.evalMemberAccess(shapeModule(), "Point")
        blob = JSRuntime.evalFunctionCall(pointConstructor, [other.x, other.y])
    }

    public mut prop x: Float64 {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.evalMemberAccess(blob, "x")
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            JSRuntime.evalAssignment(blob, "x", value)
        }
    }

    public mut prop y: Float64 {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.evalMemberAccess(blob, "y")
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            JSRuntime.evalAssignment(blob, "y", value)
        }
    }

    public func distanceTo(other: Point): Float64 {
        let distanceToMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(blob, "distanceTo")
        let result: Extern<JSRuntime> = JSRuntime.evalFunctionCall(distanceToMethod, [other.blob])
        JSRuntime.fromExtern<Float64>(result)
    }
}

public interface Shape {

    func getBlob(): Extern<JSRuntime>

    func name(): String {
        let nameMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(getBlob(), "name")
        let result: Extern<JSRuntime> = JSRuntime.evalFunctionCall(nameMethod, [])
        JSRuntime.fromExtern<String>(result)
    }

    func area(): Float64 {
        let areaMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(getBlob(), "area")
        let result: Extern<JSRuntime> = JSRuntime.evalFunctionCall(areaMethod, [])
        JSRuntime.fromExtern<Float64>(result)
    }

    func perimeter(): Float64 {
        let perimeterMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(getBlob(), "perimeter")
        let result: Extern<JSRuntime> = JSRuntime.evalFunctionCall(perimeterMethod, [])
        JSRuntime.fromExtern<Float64>(result)
    }
}

public class Rectangle <: Shape {
    public let blob: Extern<JSRuntime>

    public init(topLeft: Point, bottomRight: Point) {
        println("Rectangle constructor called with topLeft: ${topLeft.x}, ${topLeft.y} and bottomRight: ${bottomRight.x}, ${bottomRight.y}")
        let rectangleConstructor: Extern<JSRuntime> = JSRuntime.evalMemberAccess(shapeModule(), "Rectangle")
        blob = JSRuntime.evalFunctionCall(rectangleConstructor, [topLeft.blob, bottomRight.blob])
    }

    public init(extern: Extern<JSRuntime>) {
        blob = extern
    }

    public func getBlob(): Extern<JSRuntime> {
        blob
    }

    public mut prop topLeft: Point {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.evalMemberAccess(blob, "topLeft")
            Point(value)
        }
        set(value) {
            JSRuntime.evalAssignment(blob, "topLeft", value.blob)
        }
    }

    public mut prop bottomRight: Point {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.evalMemberAccess(blob, "bottomRight")
            Point(value)
        }
        set(value) {
            JSRuntime.evalAssignment(blob, "bottomRight", value.blob)
        }
    }

    public mut prop width: Float64 {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.evalMemberAccess(blob, "width")
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            JSRuntime.evalAssignment(blob, "width", value)
        }
    }

    public mut prop height: Float64 {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.evalMemberAccess(blob, "height")
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            JSRuntime.evalAssignment(blob, "height", value)
        }
    }
}

public class Circle <: Shape {
    public let blob: Extern<JSRuntime>

    public init(center: Point, radius: Float64) {
        let circleConstructor: Extern<JSRuntime> = JSRuntime.evalMemberAccess(shapeModule(), "Circle")
        blob = JSRuntime.evalFunctionCall(circleConstructor, [center.blob, radius])
    }

    public init(extern: Extern<JSRuntime>) {
        blob = extern
    }

    public func getBlob(): Extern<JSRuntime> {
        blob
    }

    public mut prop center: Point {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.evalMemberAccess(blob, "center")
            Point(value)
        }
        set(value) {
            JSRuntime.evalAssignment(blob, "center", value.blob)
        }
    }

    public mut prop radius: Float64 {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.evalMemberAccess(blob, "radius")
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            JSRuntime.evalAssignment(blob, "radius", value)
        }
    }
}

public class Triangle <: Shape {
    public let blob: Extern<JSRuntime>

    public init(a: Point, b: Point, c: Point) {
        let triangleConstructor: Extern<JSRuntime> = JSRuntime.evalMemberAccess(shapeModule(), "Triangle")
        blob = JSRuntime.evalFunctionCall(triangleConstructor, [a.blob, b.blob, c.blob])
    }

    public init(extern: Extern<JSRuntime>) {
        blob = extern
    }

    public func getBlob(): Extern<JSRuntime> {
        blob
    }

    public mut prop a: Point {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.evalMemberAccess(blob, "a")
            Point(value)
        }
        set(value) {
            JSRuntime.evalAssignment(blob, "a", value.blob)
        }
    }

    public mut prop b: Point {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.evalMemberAccess(blob, "b")
            Point(value)
        }
        set(value) {
            JSRuntime.evalAssignment(blob, "b", value.blob)
        }
    }

    public mut prop c: Point {
        get() {
            let value: Extern<JSRuntime> = JSRuntime.evalMemberAccess(blob, "c")
            Point(value)
        }
        set(value) {
            JSRuntime.evalAssignment(blob, "c", value.blob)
        }
    }
}
