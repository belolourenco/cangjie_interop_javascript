import * as std from 'std'

export const moduleMarker = Math.random()
export const moduleSentinel = 42.4242

export function lookup(lat, long) {
  return {
    name: 'Space Needle',
    coordinates: [long, lat],
  }
}

export class Rectangle {
  constructor(width, height) {
    std.puts('js constructor got called!\n')
    this.width = width
    this.height = height
  }

  area() {
    std.puts('js area method got called!\n')
    return this.width * this.height
  }
}
