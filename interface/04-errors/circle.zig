const std = @import("std");
const Shape = @import("shape.zig").Shape;
const Errors = @import("shape.zig").Errors;

pub const Circle = struct {
    radius: f32,

    pub fn area(ctx: *anyopaque) Errors!f32 {
        const self: *Circle = @ptrCast(@alignCast(ctx));
        return 3.14159265359 * self.radius * self.radius;
    }

    pub fn create(radius: f32, allocator: std.mem.Allocator) !Shape {
        const instance = try allocator.create(Circle);
        instance.* = Circle{ .radius = radius };
        return Shape{
            .ptr = instance,
            .impl = &.{ .area = area, .destroy = destroy },
        };
    }

    pub fn destroy(ctx: *anyopaque, allocator: std.mem.Allocator) void {
        const self: *Circle = @ptrCast(@alignCast(ctx));
        allocator.destroy(self);
    }
};

test "Circle" {
    const shape = try Circle.create(10, std.testing.allocator);
    defer shape.destroy(std.testing.allocator);
    const area = try shape.area();

    try std.testing.expect(area == 314.159265359);
}
