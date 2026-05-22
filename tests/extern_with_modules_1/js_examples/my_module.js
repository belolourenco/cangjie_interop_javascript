export function my_javascript_function() {
  return "my_javascript_function called";
}

export let globalBoolean = true;
export let globalNumber = 42.4242;
export let globalString = "hello from JavaScript";
export let globalArray = [1, 2, 3];
export let globalObject = {
  name: "global object",
  enabled: true,
  values: [10, 20, 30]
};
export let globalStringNumberMap = {
  one: 1,
  two: 2,
  answer: 42
};

export function lookup(lat, long) {
  return {
    coordinates: [long, lat],
    name: "Space Needle",
    city: "Seattle",
    category: "Landmark"
  };
}

export class Shape {
  area() {
    throw new Error("Shape.area must be implemented by subclasses");
  }

  perimeter() {
    throw new Error("Shape.perimeter must be implemented by subclasses");
  }
}

export class Circle extends Shape {
  constructor(radius) {
    super();
    this.radius = radius;
  }

  getRadius() {
    return this.radius;
  }

  area() {
    return Math.PI * this.radius ** 2;
  }

  perimeter() {
    return 2 * Math.PI * this.radius;
  }
}

export class Rectangle extends Shape {
  constructor(width, height) {
    super();
    this.width = width;
    this.height = height;
  }

  getWidth() {
    return this.width;
  }

  getHeight() {
    return this.height;
  }

  area() {
    return this.width * this.height;
  }

  perimeter() {
    return 2 * (this.width + this.height);
  }
}

export class Triangle extends Shape {
  constructor(base, height) {
    super();
    this.base = base;
    this.height = height;
  }

  getBase() {
    return this.base;
  }

  getHeight() {
    return this.height;
  }

  area() {
    return 0.5 * this.base * this.height;
  }

  perimeter() {
    return 3 * this.base;
  }
}

export const circle = new Circle(5);
export const rectangle = new Rectangle(4, 6);
export const triangle = new Triangle(3, 4);

export function createRectangle() {
  const width = 12;
  const height = 13;
  return new Rectangle(width, height);
}
