const std = @import("std");

pub const Rectangle = struct {
    width: f32,
    height: f32,

    pub fn area(self: *Rectangle) !f32 {
        if (self.width < 0.0 or self.height < 0.0) {
            return error.InvalidShape;
        }
        return self.width * self.height;
    }
};

test "Rectangle" {
    var shape = Rectangle{ .width = 10.0, .height = 20.0 };
    const area = try shape.area();

    try std.testing.expect(area == 200);

    shape = Rectangle{ .width = -10.0, .height = 20.0 };
    var result = shape.area();
    try std.testing.expectEqual(result, error.InvalidShape);
}

pub fn main() !void {
    var rectangleInstance = Rectangle{ .width = 10, .height = 20 };
    std.debug.print("Area of rectangle {d}\n", .{try rectangleInstance.area()});
}
