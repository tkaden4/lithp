module lth.tree;

public import std.variant;
import std.typecons;
import std.meta;
import std.traits;
import std.string;

alias Atom =
    Algebraic!(
        /* Primitives */
        Keyword,
        Id,
        String,
        Int,
        Bool,
        List!This,
        /* Special forms */
        Def*,
        Fn*,
        If*);

alias List(T) = T[];
struct String   { mixin atom!string; }
struct Id       { mixin atom!string; }
struct Keyword  { mixin atom!string; }
struct Bool     { mixin atom!bool;   }
struct Int      { mixin atom!int;    }

struct Def {
    Id binding;
    Atom value;

    auto asList()
    {
        return list(Id.atom(binding.value), value);
    }

    public static auto atom(Id binding, Atom value)
    {
        return Atom(new Def(binding, value));
    }
}

struct Fn {
    List!Id parameters;
    Atom bodyExpr;

    auto asList()
    {
        import std.algorithm;
        import std.range;
        return list(Id.atom("fn"), list(parameters.map!(x => Atom(x)).array), bodyExpr);
    }

    public static auto atom(List!Id params, Atom bodyExpr)
    {
        return Atom(new Fn(params, bodyExpr));
    }
}

struct If {
    Atom ifExpr;
    Atom thenExpr;
    Atom elseExpr;

    auto asList()
    {
        return list(ifExpr, thenExpr, elseExpr);
    }

    public static auto atom(Atom ifE, Atom thenE, Atom elseE)
    {
        return Atom(new If(ifE, thenE, elseE));
    }
}

pragma(inline)
auto list(Atom[] args...)
{
    return Atom(args);
}

mixin template atom(T)
{
    public T value;
    alias value this;
    public static auto atom(T v)
    {
        return Atom(typeof(this)(v));
    }
}
