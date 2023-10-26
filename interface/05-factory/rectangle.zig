const std = @import("std");
const Shape = @import("shape.zig").Shape;

pub const Rectangle = struct {
    width: f32,
    height: f32,

    pub fn area(ctx: *anyopaque) f32 {
        const self: *Rectangle = @ptrCast(@alignCast(ctx));
        return self.width * self.height;
    }
};

test "Rectangle" {
    var rect = Rectangle{ .width = 10.0, .height = 20.0 };
    const shape = Shape.from(&rect, Rectangle);

    try std.testing.expect(shape.area() == 200.0);
    rect.height = 30.0;
    try std.testing.expect(shape.area() == 300.0);
}

pub fn main() void {
    var rect = Rectangle{ .width = 10.0, .height = 20.0 };
    const shape = Shape.from(&rect, Rectangle);

    std.debug.print("Area of rectangle {}\n", .{shape.area()});
    rect.height = 30.0;
    std.debug.print("Area of rectangle {}\n", .{shape.area()});
}
