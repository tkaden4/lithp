module lth.util;

import std.variant;

auto get(T, Args...)(auto ref Algebraic!Args a)
{
    import std.exception;
    return *enforce(a.peek!T);
}

pragma(inline)
auto bytes(T)(in auto ref T t)
{
    union Bytes {
        const(T) t;
        ubyte[T.sizeof] arr;
    }
    return Bytes(t).arr;
}
