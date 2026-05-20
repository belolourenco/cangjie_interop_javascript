package extern_with_modules

import std.math.*

class AssertionFailedException <: Exception {

    public init(message: String) {
        super(message)
    }
}

func assert(condition: Bool, message: String) {
    if (!condition) {
        throw AssertionFailedException(message)
    }
}

func distance(x1: Float64, y1: Float64, x2: Float64, y2: Float64): Float64 {
    sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
}

func area_rectangle(x1: Float64, y1: Float64, x2: Float64, y2: Float64): Float64 {
    abs(x1 - x2) * abs(y1 - y2)
}

func perimeter_rectangle(x1: Float64, y1: Float64, x2: Float64, y2: Float64): Float64 {
    abs(x1 - x2) * 2.0 + abs(y1 - y2) * 2.0
}

func area_circle(x: Float64, y: Float64, radius: Float64): Float64 {
    Float64.getPI() * radius * radius
}

func perimeter_circle(x: Float64, y: Float64, radius: Float64): Float64 {
    2.0 * Float64.getPI() * radius
}

public func testExternWithModules() {

    // ---- Point ----
    let point1 = Point(10.0, 20.0)
    println("Point 1: ${point1.x}, ${point1.y}")
    assert(point1.x == 10.0, "Point 1 x should be 10.0")
    assert(point1.y == 20.0, "Point 1 y should be 20.0")

    point1.x = 30.0
    println("Point 1 after setting x: ${point1.x}, ${point1.y}")
    assert(point1.x == 30.0, "Point 1 x should be 30.0")
    assert(point1.y == 20.0, "Point 1 y should be 20.0")

    let point2 = Point(point1)
    println("Point 2: ${point2.x}, ${point2.y}")
    assert(point2.x == 30.0, "Point 2 x should be 30.0")
    assert(point2.y == 20.0, "Point 2 y should be 20.0")

    point1.y = 40.0
    println("Point 1 after setting y: ${point1.x}, ${point1.y}")
    println("Point 2 after setting y: ${point2.x}, ${point2.y}")
    assert(point1.x == 30.0, "Point 1 x should be 30.0")
    assert(point1.y == 40.0, "Point 1 y should be 40.0")
    assert(point2.x == 30.0, "Point 2 x should be 30.0")
    assert(point2.y == 20.0, "Point 2 y should be 20.0")

    let point3 = Point(point1.blob)
    println("Point 3: ${point3.x}, ${point3.y}")
    point3.x = 40.0
    println("Point 1 after setting x: ${point1.x}, ${point1.y}")
    println("Point 2 after setting x: ${point2.x}, ${point2.y}")
    println("Point 3 after setting x: ${point3.x}, ${point3.y}")
    assert(point1.x == point3.x && point1.y == point3.y, "Point 1 should be equal to Point 3")
    assert(point2.x == 30.0, "Point 2 x should be 30.0")
    assert(point2.y == 20.0, "Point 2 y should be 20.0")

    println("Distance between point1 and point2: ${point1.distanceTo(point2)}")
    let distance12 = distance(point1.x, point1.y, point2.x, point2.y)
    assert(point1.distanceTo(point2) == distance12, "Distance between point1 and point2 should be ${distance12}")
    
    println("Distance between point1 and point3: ${point1.distanceTo(point3)}")
    let distance13 = distance(point1.x, point1.y, point3.x, point3.y)
    assert(point1.distanceTo(point3) == distance13, "Distance between point1 and point3 should be ${distance13}")
    
    println("Distance between point2 and point3: ${point2.distanceTo(point3)}")
    let distance23 = distance(point2.x, point2.y, point3.x, point3.y)
    assert(point2.distanceTo(point3) == distance23, "Distance between point2 and point3 should be ${distance23}")

    let point4 = Point(0.0, 0.0)
    println("Point 4: ${point4.x}, ${point4.y}")
    assert(point4.x == 0.0 && point4.y == 0.0, "Point 4 should be (0.0, 0.0)")
    
    println("Distance between point1 and point4: ${point1.distanceTo(point4)}")
    let distance14 = distance(point1.x, point1.y, point4.x, point4.y)
    assert(point1.distanceTo(point4) == distance14, "Distance between point1 and point4 should be ${distance14}")

    let rectangle1 = Rectangle(point1, point4)
    println("Rectangle 1: (${rectangle1.topLeft.x}, ${rectangle1.topLeft.y}), (${rectangle1.bottomRight.x}, ${rectangle1.bottomRight.y})")
    assert(rectangle1.topLeft.x == point1.x &&
           rectangle1.topLeft.y == point1.y &&
           rectangle1.bottomRight.x == point4.x &&
           rectangle1.bottomRight.y == point4.y, "Rectangle 1 should be (${point1.x}, ${point1.y}), (${point4.x}, ${point4.y})")

    println("Rectangle 1 area: ${rectangle1.area()}")
    let area1 = area_rectangle(point1.x, point1.y, point4.x, point4.y)
    assert(rectangle1.area() == area1, "Rectangle 1 area should be ${area1}")
    
    println("Rectangle 1 perimeter: ${rectangle1.perimeter()}")
    let perimeter1 = perimeter_rectangle(point1.x, point1.y, point4.x, point4.y)
    assert(rectangle1.perimeter() == perimeter1, "Rectangle 1 perimeter should be ${perimeter1}")

    let point5 = rectangle1.topLeft
    println("Point 5: ${point5.x}, ${point5.y}")
    assert(point5.x == point1.x && point5.y == point1.y, "Point 5 should be (${point1.x}, ${point1.y})")

    let point6 = rectangle1.bottomRight
    println("Point 6: ${point6.x}, ${point6.y}")
    assert(point6.x == point4.x && point6.y == point4.y, "Point 6 should be (${point4.x}, ${point4.y})")


    rectangle1.topLeft.x = 12345.0
    println("Rectangle 1 after setting topLeft x: ${rectangle1.topLeft.x}, ${rectangle1.topLeft.y}")

    println("Point 1 after setting topLeft x: ${point1.x}, ${point1.y}")
    assert(point1.x == 12345.0, "Point 1 x should be 12345.0")
    assert(point1.y == 40.0, "Point 1 y should be 40.0")
    println("Point 5 after setting topLeft x: ${point5.x}, ${point5.y}")
    assert(point5.x == 12345.0, "Point 5 x should be 12345.0")
    assert(point5.y == 40.0, "Point 5 y should be 40.0")

    point1.y = 4321.0
    println("Point 1 after setting y: ${point1.x}, ${point1.y}")
    assert(point1.x == 12345.0, "Point 1 x should be 12345.0")
    assert(point1.y == 4321.0, "Point 1 y should be 4321.0")
    println("Point 5 after setting y: ${point5.x}, ${point5.y}")
    assert(point5.x == 12345.0, "Point 5 x should be 12345.0")
    assert(point5.y == 4321.0, "Point 5 y should be 4321.0")

    let circle1 = Circle(point1, 10.0)
    println("Circle 1: (${circle1.center.x}, ${circle1.center.y}), radius: ${circle1.radius}")
    assert(circle1.center.x == point1.x && circle1.center.y == point1.y, "Circle 1 center should be (${point1.x}, ${point1.y})")
    assert(circle1.radius == 10.0, "Circle 1 radius should be 10.0")

    println("Circle 1 area: ${circle1.area()}")
    let circle_area = area_circle(circle1.center.x, circle1.center.y, circle1.radius)
    assert(circle1.area() == circle_area, "Circle 1 area should be ${circle_area}")

    println("Circle 1 perimeter: ${circle1.perimeter()}")
    let circle_perimeter = perimeter_circle(circle1.center.x, circle1.center.y, circle1.radius)
    assert(circle1.perimeter() == circle_perimeter, "Circle 1 perimeter should be ${circle_perimeter}")


    let p1 = Point(0.0, 0.0)
    let p2 = Point(10.0, 0.0)
    let p3 = Point(5.0, 5.0)
    // let triangle1 = Triangle(p1, p2, p3)
    // println("Triangle 1: (${triangle1.a.x}, ${triangle1.a.y}), (${triangle1.b.x}, ${triangle1.b.y}), (${triangle1.c.x}, ${triangle1.c.y})")
    // assert(triangle1.a.x == point1.x && triangle1.a.y == point1.y, "Triangle 1 a should be (${point1.x}, ${point1.y})")
    // assert(triangle1.b.x == point2.x && triangle1.b.y == point2.y, "Triangle 1 b should be (${point2.x}, ${point2.y})")
    // assert(triangle1.c.x == point3.x && triangle1.c.y == point3.y, "Triangle 1 c should be (${point3.x}, ${point3.y})")

    // println("Triangle 1 area: ${triangle1.area()}")
    // let triangle_area = area_triangle(triangle1.a.x, triangle1.a.y, triangle1.b.x, triangle1.b.y, triangle1.c.x, triangle1.c.y)
    // assert(triangle1.area() == triangle_area, "Triangle 1 area should be ${triangle_area}")

    // // ---- JavaScript Module ----
    // let jsModule: Extern<JSRuntime> = JSRuntime.getModule("js_examples/shape.js")

    // // ---- Rectangle ----

    // // let rectangle: Extern<JSRuntime> = jsModule.Rectangle(10, 11)
    // // ->
    // let rectangleConstructor: Extern<JSRuntime> = JSRuntime.evalMemberAccess(jsModule, "Rectangle")
    // let rectangleObject: Extern<JSRuntime> = JSRuntime.evalFunctionCall(rectangleConstructor, [10, 11])

    // // let rectangleWidth: Extern<JSRuntime> = rectangleObject.getWidth()
    // // ->
    // let rectangleWidthMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject, "getWidth")
    // let rectangleWidthResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(rectangleWidthMethod, [])
    // println("Rectangle width: ${JSRuntime.fromExtern<Float64>(rectangleWidthResult)}")

    // // let rectangleHeight: Extern<JSRuntime> = rectangleObject.getHeight()
    // // ->
    // let rectangleHeightMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject, "getHeight")
    // let rectangleHeightResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(rectangleHeightMethod, [])
    // println("Rectangle height: ${JSRuntime.fromExtern<Float64>(rectangleHeightResult)}")

    // // ---- createRectangle ----

    // // let rectangleObject2: Extern<JSRuntime> = jsModule.createRectangle()
    // // ->
    // let createRectangleMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(jsModule, "createRectangle")
    // let rectangleObject2: Extern<JSRuntime> = JSRuntime.evalFunctionCall(createRectangleMethod, [])

    // // rectangleObject2.width = 42
    // // ->
    // JSRuntime.evalAssignment(rectangleObject2, "width", 42.0)

    // // let rectangleWidth2: Extern<JSRuntime> = rectangleObject2.width
    // // ->
    // let rectangleWidthResult2: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject2, "width")
    // println("Rectangle width: ${JSRuntime.fromExtern<Float64>(rectangleWidthResult2)}")

    // // let rectangleHeight2: Extern<JSRuntime> = rectangleObject2.height
    // // ->
    // let rectangleHeightResult2: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject2, "height")
    // println("Rectangle height: ${JSRuntime.fromExtern<Float64>(rectangleHeightResult2)}")

    // // let area = rectangleObject2.area()
    // // ->
    // let areaMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject2, "area")
    // let areaResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(areaMethod, [])
    // println("Rectangle area: ${JSRuntime.fromExtern<Float64>(areaResult)}")

    // // let perimeter = rectangleObject2.perimeter()
    // // ->
    // let perimeterMethod: Extern<JSRuntime> = JSRuntime.evalMemberAccess(rectangleObject2, "perimeter")
    // let perimeterResult: Extern<JSRuntime> = JSRuntime.evalFunctionCall(perimeterMethod, [])
    // println("Rectangle perimeter: ${JSRuntime.fromExtern<Float64>(perimeterResult)}")

}
