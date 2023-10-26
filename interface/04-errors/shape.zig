const std = @import("std");

pub const Errors = error{
    InvalidShape,
};

pub const Shape = struct {
    ptr: *anyopaque,
    impl: *const Interface,

    pub const Interface = struct {
        area: *const fn (ctx: *anyopaque) Errors!f32,
        destroy: *const fn (ctx: *anyopaque, allocator: std.mem.Allocator) void,
    };

    pub fn area(self: Shape) !f32 {
        return try self.impl.area(self.ptr);
    }

    pub fn destroy(self: Shape, allocator: std.mem.Allocator) void {
        self.impl.destroy(self.ptr, allocator);
    }
};
