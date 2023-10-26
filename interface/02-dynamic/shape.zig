pub const Shape = struct {
    ptr: *anyopaque,
    impl: *const Interface,

    pub const Interface = struct {
        area: *const fn (ctx: *anyopaque) f32,
    };

    pub fn area(self: Shape) f32 {
        return self.impl.area(self.ptr);
    }
};
