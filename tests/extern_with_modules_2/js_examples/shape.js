export class Point {
  constructor(x, y) {
    this.x = x;
    this.y = y;
  }

  distanceTo(other) {
    return Math.sqrt((this.x - other.x) ** 2 + (this.y - other.y) ** 2);
  }
}

export class Shape {
  name() {
    return "Shape";
  }
  area() {
    throw new Error("Shape.area must be implemented by subclasses");
  }

  perimeter() {
    throw new Error("Shape.perimeter must be implemented by subclasses");
  }
}

export class Rectangle extends Shape {
  constructor(topLeft, bottomRight) {
    super();

    if (isCoordinate(topLeft) && isCoordinate(bottomRight)) {
      this.topLeft = new Point(0, 0);
      this.bottomRight = new Point(Number(topLeft), Number(bottomRight));
    } else {
      this.topLeft = topLeft;
      this.bottomRight = bottomRight;
    }
  }

  name() {
    return "Rectangle";
  }

  get width() {
    return this.bottomRight.x - this.topLeft.x;
  }

  set width(value) {
    this.bottomRight.x = this.topLeft.x + value;
  }

  get height() {
    return this.bottomRight.y - this.topLeft.y;
  }

  set height(value) {
    this.bottomRight.y = this.topLeft.y + value;
  }

  getWidth() {
    return this.width;
  }

  getHeight() {
    return this.height;
  }

  area() {
    return Math.abs(this.width) * Math.abs(this.height);
  }

  perimeter() {
    return Math.abs(this.width) * 2.0 + Math.abs(this.height) * 2.0;
  }
}

function isCoordinate(value) {
  return typeof value === "number" || typeof value === "bigint";
}

export class Circle extends Shape {
  constructor(center, radius) {
    super();
    this.center = center;
    this.radius = radius;
  }

  name() {
    return "Circle";
  }

  area() {
    const radius = Math.abs(this.radius);
    return Math.PI * radius * radius;
  }

  perimeter() {
    return Math.PI * Math.abs(this.radius) * 2.0;
  }
}

export class Triangle extends Shape {
  constructor(a, b, c) {
    super();
    this.a = a;
    this.b = b;
    this.c = c;
  }

  name() {
    return "Triangle";
  }

  area() {
    const ab = this.a.distanceTo(this.b);
    const bc = this.b.distanceTo(this.c);
    const ca = this.c.distanceTo(this.a);
    const s = (ab + bc + ca) / 2.0;
    return Math.sqrt(Math.max(0.0, s * (s - ab) * (s - bc) * (s - ca)));
  }

  perimeter() {
    return this.a.distanceTo(this.b) + this.b.distanceTo(this.c) + this.c.distanceTo(this.a);
  }
}
