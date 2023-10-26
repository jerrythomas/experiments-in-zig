const std = @import("std");
const Circle = @import("circle.zig").Circle;
const Rectangle = @import("rectangle.zig").Rectangle;

pub fn main() void {
    var circle = Circle{ .radius = 10.0 };
    var rectangle = Rectangle{ .width = 10.0, .height = 20.0 };

    var shape = Circle.create(&circle);
    std.debug.print("Circle area: {}\n", .{shape.area()});

    shape = Rectangle.create(&rectangle);
    std.debug.print("Rectangle area: {}\n", .{shape.area()});
}
