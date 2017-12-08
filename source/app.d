import std.stdio;
import std.file;
import std.range;
import std.algorithm;
import std.functional;
import std.string;
import std.conv;
import std.meta;
import std.typecons;
import std.traits;

import lth.tree;
import lth.parse;
import lth.util;
import lth.vm;

auto atomString(in ref Atom atom)
{
    return atom.visit!(
        (String s) => "\"%s\"".format(s.value),
        x => format("%s", x)
    );
}

auto eval(R)(in auto ref R range)
{
    return 1;
}

Atom reduceIf()(auto ref If ifExpr)
{
    if(auto x = ifExpr.ifExpr.peek!Bool){
        return *x ? ifExpr.thenExpr : ifExpr.elseExpr;
    }else{
        return If.atom(ifExpr.ifExpr, ifExpr.thenExpr, ifExpr.elseExpr);
    }
}

void main(string[] args)
{
    auto factorial_ast =
        Def.atom(
            Id("fact"),
            Fn.atom(
                [Id("n")],
                If.atom(
                    list(
                        Id.atom("="),
                        Id.atom("n"),
                        Int.atom(0)
                    ),
                    Int.atom(1),
                    list(
                        Id.atom("*"),
                        list(
                            Id.atom("fact"),
                            list(
                                Id.atom("dec"),
                                Id.atom("n")
                            )
                        ),
                        Id.atom("n")
                    )
                )
            )
        );

    //factorial.eval_mem;
    fibonacci.eval_mem;

    try {
        args
            .drop(1)
            .map!readText
            .map!eval
            .each!writeln;
    } catch(Exception e) {
        stderr.writeln("lithp: ", e.msg);
    }
}
