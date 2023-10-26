const std = @import("std");
const Shape = @import("shape.zig").Shape;
const Errors = @import("shape.zig").Errors;

pub const Rectangle = struct {
    width: f32,
    height: f32,

    pub fn area(ctx: *anyopaque) Errors!f32 {
        const self: *Rectangle = @ptrCast(@alignCast(ctx));
        if (self.width < 0.0 or self.height < 0.0) {
            return Errors.InvalidShape;
        }
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
    var shape = try Rectangle.create(10, 20, std.testing.allocator);

    var area = try shape.area();
    try std.testing.expect(area == 200.0);
    shape.destroy(std.testing.allocator);

    shape = try Rectangle.create(-10, 20, std.testing.allocator);

    var result = shape.area();
    try std.testing.expectEqual(result, Errors.InvalidShape);
    shape.destroy(std.testing.allocator);
}
