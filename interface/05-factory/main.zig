const std = @import("std");
const Shape = @import("shape.zig").Shape;
const Circle = @import("circle.zig").Circle;
const Rectangle = @import("rectangle.zig").Rectangle;

pub fn main() void {
    var circle = Circle{ .radius = 10.0 };
    var rectangle = Rectangle{ .width = 10.0, .height = 20.0 };

    var shape = Shape.from(&circle, @TypeOf(circle));
    std.debug.print("Circle area: {}\n", .{shape.area()});

    shape = Shape.from(&rectangle, @TypeOf(rectangle));
    std.debug.print("Rectangle area: {}\n", .{shape.area()});
}

test {
    _ = Shape;
    _ = Circle;
    _ = Rectangle;
}
