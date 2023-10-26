# Exploring Compile-Time Interfaces in Zig

I recently came to know about [Zig](https://ziglang.org/), a general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software. Zig has a very active [community](https://github.com/ziglang/zig/wiki/Community) and they are very helpful and friendly.

While building my experiments, I came across a scenario which required using interfaces. Since there is no interface keyword (yet) this took me some time to figure out.

## What are interfaces?

Interfaces are foundational constructs in object-oriented programming (OOP) that define a contract or a set of abstract methods (functions or procedures) that classes must implement. They act as a blueprint that ensures certain methods are provided by a class, without specifying how these methods are implemented. This allows for a high level of abstraction and flexibility in code design.

Key benefits of interfaces include:

- Abstraction: Interfaces allow for the abstraction of functionalities. By defining only what needs to be done (and not how it's done), developers can change or swap implementations without affecting other parts of the system.
- Polymorphism: Through interfaces, different classes can be treated as instances of the same interface type, allowing for a single interface to be used to represent different types of objects. This makes it easier to write flexible and generic code.
- Decoupling: Interfaces create a separation between the definition of operations and their actual implementation. This ensures that changes in one module or class don't directly impact others, leading to more maintainable and modular code.
- Interoperability: In systems where multiple components need to interact, interfaces ensure that components adhere to specific contracts, making integration smoother.

In essence, interfaces promote a design-by-contract approach, ensuring that classes adhere to certain behaviors while providing the freedom to determine how those behaviors are achieved.

In Zig, compile-time interfaces offer a powerful mechanism to structure and optimize your code. Unlike runtime interfaces in many other languages, which determine method implementations during program execution, compile-time interfaces in Zig are resolved at compile time. This means the compiler determines the appropriate methods or functionalities to be used, resulting in highly efficient and tailored code.

## Interfaces in Zig

Today, we will delve into two unique approaches to harnessing this feature. To simplify our exploration, we'll use the calculation of areas for various shapes as our illustrative example.

### Union of enum

The union of enums approach is like grouping together similar objects but only one of these objects is active at any given time.

#### The Circle

Below is a simple Circle object with a radius property and an area function.

```zig
const std = @import("std");

pub const Circle = struct {
    radius: f32,

    pub fn area(self: *Circle) !f32 {
        return 3.14159265359 * self.radius * self.radius;
    }
};

pub fn main() !void {
    var circleInstance = Circle{ .radius = 10 };
    std.debug.print("Area of circle {}\n", .{try circleInstance.area()});
}
```

#### The Rectangle

An implementation of rectangle, similar to the Circle. Here I have added a check and return error if the check fails.

```zig
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

pub fn main() !void {
    var rectangleInstance = Rectangle{ .width = 10, .height = 20 };
    std.debug.print("Area of rectangle {d}\n", .{try rectangleInstance.area()});
}
```

#### Combining Shapes

This is where we combine the circle & rectangle together into a Shape object. Unlike interfaces, this is actually a union of multiple objects.

```zig
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
};

pub fn main() !void{
    var shape = Shape{ .rectangle = Rectangle{ .width = 10, .height = 20 } };
    std.debug.print("Area of shape {}\n", .{try shape.area()});

    shape = Shape{ .circle = Circle{ .radius = 10} };
    std.debug.print("Area of shape {}\n", .{try shape.area()});
}
```

> [enum union](https://github.com/jerrythomas/experiments-in-zig/interface/01-enum)

Here, `inline else` is a Zig construct that matches all other cases not explicitly listed in the `switch`. It's a powerful way to handle multiple possibilities with one statement.

This approach makes it quite easy to combine multiple objects. However, using this approach means that anytime you wish to add a new object in the Shape, means that the code needs to be modified. It's not suitable for a library where you potentially wan users to extend the interface with custom implementations.

#### Factory

We can also add a factory method that takes an instance and it's type to return a shape instance. In this situation we don't need to worry about setting the Shape instance property explicitly.

```zig
pub fn from(ctx: *anyopaque, comptime T: type) Shape {
    const ref: *T = @ptrCast(@alignCast(ctx));
    switch (T) {
        Circle => return Shape{ .circle = ref.* },
        Rectangle => return Shape{ .rectangle = ref.* },
        else => @compileError("Invalid type provided to Shape.from"),
    }
}
```

Using this the implementation changes to:

```zig
var rect = Rectangle{ .width = 10, .height = 20 };

shape = Shape.from(&rect, Rectangle);
std.debug.print("Area of shape {}\n", .{try shape.area()});

// or
shape = Shape.from(&rect, @TypeOf(rect));
std.debug.print("Area of shape {}\n", .{try shape.area()});
```

### Using Reference Pointers

If you are familiar with zig, then you would know how the `Allocator` works. You can use multiple allocators, and the way it is implemented, developers can write their own Allocators. Based on the code it looks like zig treats modules similar to structs. I have used a struct here to make it easier for me to understand and use.

#### Shape

The shape interface includes the following:

- pointer to the instance of implementation
- pointer to the mapped functions matching the inline interface
- an inline interface definition with function prototypes
- wrappers for the function prototypes called using the pointers

```zig
const Shape = struct {
    ptr: *anyopaque,
    impl: *const Interface,

    pub const Interface = struct {
        area: *const fn (ctx: *anyopaque) f32,
    };

    pub fn area(self: Shape) f32 {
        return self.impl.area(self.ptr);
    }
};
```

The `*anyopaque` is a pointer type in Zig that points to an unknown type. It's useful when defining generic constructs, allowing us to work with different types without knowing their specifics during interface definition.

#### Circle

```zig
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

pub fn main() void {
    var circle = Circle{ .radius = 10.0 };
    const shape = Circle.create(&circle);

    std.debug.print("Area of circle {}\n", .{shape.area()});
}
```

#### Rectangle

```zig
const std = @import("std");
const Shape = @import("Shape.zig").Shape;

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

pub fn main() void {
    var rect = Rectangle{ .width = 10.0, .height = 20.0 };
    const shape = Rectangle.create(&rect);
    const area = shape.area();

    std.debug.print("Area of rectangle {}\n", .{area});
}
```

> [reference pointer](https://github.com/jerrythomas/experiments-in-zig/interface/02-dynamic)

#### Memory Managed

Improving our approach gives us more control over memory and error management, ensuring efficient and safe code execution.

```zig
// ... (Rectangle struct with its area function)

pub fn create(width: f32, height: f32, allocator: std.mem.Allocator) Shape {
    const instance = allocator.create(Rectangle) orelse unreachable;
    instance.* = Rectangle{ .width = width, .height = height };
    return Shape{ .ptr = instance, .impl = &.{ .area = area, .destroy = destroy } };
}

pub fn destroy(ctx: *anyopaque, allocator: std.mem.Allocator) void {
    const self: *Rectangle = @ptrCast(ctx);
    allocator.destroy(self);
}
```

**Usage**:

```zig
const allocator = std.mem.Allocator;
const rectangle = Rectangle.create(10, 20, allocator);
const rectangleAreaWithMemoryMgmt = rectangle.area();
rectangle.destroy(allocator);
```

> [memory managed](https://github.com/jerrythomas/experiments-in-zig/interface/03-managed)

#### Returning errors

By introducing error handling, we can better manage unexpected scenarios, ensuring our program behaves predictably.

```zig
pub fn area(ctx: *anyopaque) !f32 {
    const self: *Rectangle = @ptrCast(ctx);
    if (self.width < 0.0 or self.height < 0.0) {
        return error.InvalidShape;
    }
    return self.width * self.height;
}
```

**Usage**:
After creating a `Rectangle` instance:

```zig
const rectangleAreaWithErrorHandling = try rectangle.area();
```

> [error propagation](https://github.com/jerrythomas/experiments-in-zig/interface/04-errors)

#### Factory

Moving the create function from the implementations to the interface would reduce the code that needs to be written.

```zig
pub fn from(ctx: *anyopaque, comptime T: type) Shape {
    const self: *T = @ptrCast(@alignCast(ctx));
    return Shape{
        .ptr = self,
        .impl = &.{ .area = T.area },
    };
}
```

This function now allows us to convert an implementation into a Shape object and call the functions in shape. We can hence swap instances and still get the areas.

## Summary

### Enum Based Interface

- A straightforward approach.
- Limited flexibility for adding new shapes without modifying the union.
- Works with inferred errors
- Works with runtime return types

### Using Reference Pointers

- Users of a library can create their own implementation and extend the existing functionality.
- Offers greater extensibility, memory management, and error handling.
- Inferred error types cannot be used, so you need to know all possible errors
- Cannot use runtime return types.

You can get the code [here](https://github.com/experiments-in-zig/interface) and try it out yourself.
