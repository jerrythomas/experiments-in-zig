const std = @import("std");
const Shape = @import("shape.zig").Shape;

pub const Rectangle = struct {
    width: f32,
    height: f32,

    pub fn area(ctx: *anyopaque) f32 {
        const self: *Rectangle = @ptrCast(@alignCast(ctx));
        return self.width * self.height;
    }

    pub fn create(width: f32, height: f32, allocator: std.mem.Allocator) !Shape {
        const instance = try allocator.create(Rectangle);
        instance.* = Rectangle{ .width = width, .height = height };
        return Shape{
            .ptr = instance,
            .impl = &.{ .area = area, .destroy = destroy },
        };
    }

    pub fn destroy(ctx: *anyopaque, allocator: std.mem.Allocator) void {
        const self: *Rectangle = @ptrCast(@alignCast(ctx));
        allocator.destroy(self);
    }
};

test "Rectangle" {
    const shape = try Rectangle.create(10, 20, std.testing.allocator);
    defer shape.destroy(std.testing.allocator);
    const area = shape.area();

    try std.testing.expect(area == 200.0);
}
