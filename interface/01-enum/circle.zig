const std = @import("std");

pub const Circle = struct {
    radius: f32,

    pub fn area(self: *Circle) !f32 {
        return 3.14159265359 * self.radius * self.radius;
    }
};

test "Circle" {
    var shape = Circle{ .radius = 10.0 };
    const area = try shape.area();

    try std.testing.expect(area == 314.159265359);
}

pub fn main() !void {
    var circleInstance = Circle{ .radius = 10 };
    std.debug.print("Area of circle {}\n", .{try circleInstance.area()});
}
