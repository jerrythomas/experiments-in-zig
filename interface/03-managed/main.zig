const std = @import("std");
const Circle = @import("circle.zig").Circle;
const Rectangle = @import("rectangle.zig").Rectangle;

pub fn main() !void {
    var shape = try Circle.create(10, std.heap.page_allocator);
    std.debug.print("Circle area: {}\n", .{shape.area()});
    shape.destroy(std.heap.page_allocator);

    shape = try Rectangle.create(10, 20, std.heap.page_allocator);
    std.debug.print("Rectangle area: {}\n", .{shape.area()});
    shape.destroy(std.heap.page_allocator);
}
