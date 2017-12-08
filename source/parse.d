module lth.parse;

/* parser combinators for lithp */

import std.range;
import std.algorithm;
import std.typecons;
public import std.typecons : tuple;
public import std.variant;
import std.meta;
import std.string;

alias Either(Left, Right) = Algebraic!(Left, Right);

alias ParseError = string;
alias Parsed(T) = Either!(ParseError, T);

auto parsed(T)(auto ref T t)
{
    return Parsed!T(t);
}

struct ParseResult(T, R) {
    public Parsed!T value;
    public R range;
}

auto parseResult(T, R)(auto ref Parsed!T t, auto ref R r)
{
    return ParseResult!(T, R)(t, r);
}

auto ref and(R, Parsers...)(auto ref R stream)
{
    alias returnTypes = staticMap!(ReturnType, Parsers);
    alias Container = Tuple!returnTypes;
    return Container();
}
