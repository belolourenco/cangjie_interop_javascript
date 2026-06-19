package extern_with_modules

import interop_javascript.JSRuntime

public class Point {
    public let blob: Extern<JSRuntime>

    public init(module: Extern<JSRuntime>, x: Float64, y: Float64) {
        println("Point constructor called with x: ${x}, y: ${y}")
        blob = module.Point(x, y)
    }

    // Shallow copy constructor!
    public init(extern: Extern<JSRuntime>) {
        println("Point extern constructor called")
        blob = extern
    }

    // Deep copy constructor!
    public init(module: Extern<JSRuntime>, other: Point) {
        println("Point copy constructor called with x: ${other.x}, y: ${other.y}")
        blob = module.Point(other.x, other.y)
    }

    public mut prop x: Float64 {
        get() {
            // (Float64)blob.x
            let value: Extern<JSRuntime> = blob.x
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            blob.x = value
        }
    }

    public mut prop y: Float64 {
        get() {
            // (Float64)blob.y
            // ->
            let value: Extern<JSRuntime> = blob.y
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            blob.y = value
        }
    }

    public func distanceTo(other: Point): Float64 {
        let result: Extern<JSRuntime> = blob.distanceTo(other.blob)
        JSRuntime.fromExtern<Float64>(result)
    }
}

public interface Shape {

    func getBlob(): Extern<JSRuntime>

    func name(): String {
        let result: Extern<JSRuntime> = getBlob().name()
        JSRuntime.fromExtern<String>(result)
    }

    func area(): Float64 {
        let result: Extern<JSRuntime> = getBlob().area()
        JSRuntime.fromExtern<Float64>(result)
    }

    func perimeter(): Float64 {
        let result: Extern<JSRuntime> = getBlob().perimeter()
        JSRuntime.fromExtern<Float64>(result)
    }
}

public class Rectangle <: Shape {
    public let blob: Extern<JSRuntime>

    public init(module: Extern<JSRuntime>, topLeft: Point, bottomRight: Point) {
        println("Rectangle constructor called with topLeft: ${topLeft.x}, ${topLeft.y} and bottomRight: ${bottomRight.x}, ${bottomRight.y}")
        blob = module.Rectangle(topLeft.blob, bottomRight.blob)
    }

    public init(extern: Extern<JSRuntime>) {
        blob = extern
    }

    public func getBlob(): Extern<JSRuntime> {
        blob
    }

    public mut prop topLeft: Point {
        get() {
            // Point(blob.topLeft)
            // ->
            let value: Extern<JSRuntime> = blob.topLeft
            Point(value)
        }
        set(value) {
            blob.topLeft = value.blob
        }
    }

    public mut prop bottomRight: Point {
        get() {
            Point(blob.bottomRight)
        }
        set(value) {
            blob.bottomRight = value.blob
        }
    }

    public mut prop width: Float64 {
        get() {
            // (Float64)blob.width
            // ->
            let value: Extern<JSRuntime> = blob.width
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            blob.width = value
        }
    }

    public mut prop height: Float64 {
        get() {
            // (Float64)blob.height
            // ->
            let value: Extern<JSRuntime> = blob.height
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            blob.height = value
        }
    }
}

public class Circle <: Shape {
    public let blob: Extern<JSRuntime>

    public init(module: Extern<JSRuntime>, center: Point, radius: Float64) {
        blob = module.Circle(center.blob, radius)
    }

    public init(extern: Extern<JSRuntime>) {
        blob = extern
    }

    public func getBlob(): Extern<JSRuntime> {
        blob
    }

    public mut prop center: Point {
        get() {
            Point(blob.center)
        }
        set(value) {
            blob.center = value.blob
        }
    }

    public mut prop radius: Float64 {
        get() {
            // (Float64)blob.radius
            // ->
            let value: Extern<JSRuntime> = blob.radius
            JSRuntime.fromExtern<Float64>(value)
        }
        set(value) {
            blob.radius = value
        }
    }
}

public class Triangle <: Shape {
    public let blob: Extern<JSRuntime>

    public init(module: Extern<JSRuntime>, a: Point, b: Point, c: Point) {
        blob = module.Triangle(a.blob, b.blob, c.blob)
    }

    public init(extern: Extern<JSRuntime>) {
        blob = extern
    }

    public func getBlob(): Extern<JSRuntime> {
        blob
    }

    public mut prop a: Point {
        get() {
            Point(blob.a)
        }
        set(value) {
            blob.a = value.blob
        }
    }

    public mut prop b: Point {
        get() {
            Point(blob.b)
        }
        set(value) {
            blob.b = value.blob
        }
    }

    public mut prop c: Point {
        get() {
            Point(blob.c)
        }
        set(value) {
            blob.c = value.blob
        }
    }
}
