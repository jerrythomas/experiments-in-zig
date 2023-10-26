const std = @import("std");
const Shape = @import("shape.zig").Shape;

pub const Circle = struct {
    radius: f32,

    pub fn area(ctx: *anyopaque) f32 {
        const self: *Circle = @ptrCast(@alignCast(ctx));
        return 3.14159265359 * self.radius * self.radius;
    }
};

test "Circle" {
    var circle = Circle{ .radius = 10.0 };
    const shape = Shape.from(&circle, @TypeOf(circle));
    try std.testing.expect(shape.area() == 314.159265359);
    circle.radius = 20.0;
    try std.testing.expect(shape.area() == 4 * 314.159265359);
}

pub fn main() void {
    var circle = Circle{ .radius = 10.0 };
    const shape = Shape.from(&circle, @TypeOf(circle));

    std.debug.print("Area of circle {}\n", .{shape.area()});
    circle.radius = 20.0;
    std.debug.print("Area of circle {}\n", .{shape.area()});
}
