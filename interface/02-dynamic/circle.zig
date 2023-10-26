const std = @import("std");
const Shape = @import("shape.zig").Shape;

pub const Circle = struct {
    radius: f32,

    pub fn area(ctx: *anyopaque) f32 {
        const self: *Circle = @ptrCast(@alignCast(ctx));
        return 3.14159265359 * self.radius * self.radius;
    }

    pub fn create(self: *Circle) Shape {
        return Shape{
            .ptr = self,
            .impl = &.{ .area = area },
        };
    }
};

test "Circle" {
    var circle = Circle{ .radius = 10.0 };
    const shape = circle.create();

    try std.testing.expect(shape.area() == 314.159265359);
}

pub fn main() void {
    var circle = Circle{ .radius = 10.0 };
    const shape = circle.create();

    std.debug.print("Area of circle {}\n", .{shape.area()});
}
