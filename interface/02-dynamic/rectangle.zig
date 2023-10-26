const std = @import("std");
const Shape = @import("shape.zig").Shape;

pub const Rectangle = struct {
    width: f32,
    height: f32,

    pub fn area(ctx: *anyopaque) f32 {
        const self: *Rectangle = @ptrCast(@alignCast(ctx));
        return self.width * self.height;
    }

    pub fn create(self: *Rectangle) Shape {
        return Shape{
            .ptr = self,
            .impl = &.{ .area = area },
        };
    }
};

test "Rectangle" {
    var rect = Rectangle{ .width = 10.0, .height = 20.0 };
    const shape = Rectangle.create(&rect);
    const area = shape.area();

    try std.testing.expect(area == 200.0);
}

pub fn main() void {
    var rect = Rectangle{ .width = 10.0, .height = 20.0 };
    const shape = rect.create();
    const area = shape.area();

    std.debug.print("Area of rectangle {}", .{area});
}
