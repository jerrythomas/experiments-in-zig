const std = @import("std");
const Circle = @import("circle.zig").Circle;
const Rectangle = @import("rectangle.zig").Rectangle;

const Shape = union(enum) {
    circle: Circle,
    rectangle: Rectangle,

    pub fn area(self: *Shape) !f64 {
        switch (self.*) {
            inline else => |*case| return try case.area(),
        }
    }

    pub fn from(ctx: *anyopaque, comptime T: type) Shape {
        const ref: *T = @ptrCast(@alignCast(ctx));
        switch (T) {
            Circle => return Shape{ .circle = ref.* },
            Rectangle => return Shape{ .rectangle = ref.* },
            else => @compileError("Invalid type provided to Shape.from"),
        }
    }
};

test "Shape" {
    var shape = Shape{ .rectangle = Rectangle{ .width = 10, .height = 20 } };
    var area = try shape.area();
    try std.testing.expect(area == 200);

    shape = Shape{ .circle = Circle{ .radius = 10 } };
    area = try shape.area();
    try std.testing.expect(area == 314.1592712402344);
}

pub fn main() !void {
    var rect = Rectangle{ .width = 10, .height = 20 };
    var shape = Shape{ .rectangle = rect };
    std.debug.print("Area of shape {d}\n", .{try shape.area()});

    shape = Shape{ .circle = Circle{ .radius = 10 } };
    std.debug.print("Area of shape {}\n", .{try shape.area()});

    shape = Shape.from(&rect, Rectangle);
    std.debug.print("Area of shape {d}\n", .{try shape.area()});

    shape = Shape.from(&rect, @TypeOf(rect));
    std.debug.print("Area of shape {d}\n", .{try shape.area()});
}
