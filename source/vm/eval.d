module lth.vm.eval;

import std.variant;
import std.stdio;
import std.conv;
import std.range;
import std.algorithm;
import std.exception;
import std.string;

import lth.tree;
import lth.vm.opcode;
import lth.vm.box;
import lth.util;

abstract class LithpValue {
    Box!string lithpString();
    Box!int lithpCmp(LithpValue other);
    LithpValue lithpMult(LithpValue other);
    LithpValue lithpAdd(LithpValue other);
    LithpValue lithpSub(LithpValue other);
    LithpValue lithpApply(LithpValue[] arguments...)
    {
        throw new Exception("%s is not applyable".format(typeid(this)));
    }
}

pragma(inline)
auto get(T)(in ubyte[] bytes, size_t loc = 0)
{
    return *cast(T*)&bytes[loc];
}

pragma(inline)
auto get_poly(in ubyte[] bytes, size_t i, size_t which)
{
    return cast(LithpValue)bytes.get!(void *)(i + which * (void *).sizeof);
}

auto fastCast(T, E)(in auto ref E e)
{
    return *cast(T *)&e;
}

struct Stack {
    private Object[] stack;

    this(size_t size)
    {
        this.stack.reserve(size);
    }

    pragma(inline)
    auto push(T)(auto ref T t)
    {
        static if(is(T == class)){
            this.stack ~= t;
        }else{
            this.stack ~= t.box;
        }
    }

    pragma(inline)
    auto pop(T)()
    {
        auto tmp = this.top!T;
        --this.stack.length;
        return tmp;
    }

    pragma(inline)
    auto top(T)()
    {
        return this.at!T(this.size - 1);
    }

    auto size() @property
    {
        return this.stack.length;
    }

    auto at(T)(size_t s)
    {
        static if(is(T == class)){
            return cast(T)this.stack[s];
        }else{
            return cast(Box!T)this.stack[s];
        }
    }
}

struct Call {
    Object[] arguments;
    ulong retAddr;
}

auto eval_mem(in ubyte[] program)
{
    /* setup data stack */
    auto stack = Stack();

    /* setup calling stack */
    Call[] calls;
    calls ~= Call([box(4)], program.length);

    void delegate(ref size_t)[Opcode.MAX_CODE] handlers = [
        Opcode.IBOX: (ref i){
            stack.push(program.get!int(i + 1).box);
            i += Opcode.sizeof + int.sizeof;
        },
        Opcode.CALL: (ref i){
            calls ~= Call([stack.pop!LithpValue], i + Opcode.sizeof + ulong.sizeof);
            i = program.get!ulong(i + 1);
        },
        Opcode.RET: (ref i){
            i = calls.back.retAddr;
            calls.length -= 1;
        },
        Opcode.ALOAD: (ref i){
            auto which = program.get!ubyte(i + 1);
            auto value = calls.back.arguments[which];
            stack.push(value);
            i += Opcode.sizeof + ubyte.sizeof;
        },
        Opcode.IF_EQ: (ref i){
            auto rhs = stack.pop!LithpValue;
            auto lhs = stack.pop!LithpValue;
            const then = program.get!ulong(i + 1);
            const otherwise = program.get!ulong(i + 1 + ulong.sizeof);
            i = lhs.lithpCmp(rhs).value == 0 ? then : otherwise;
        },
        Opcode.IF_LT: (ref i){
            auto rhs = stack.pop!LithpValue;
            auto lhs = stack.pop!LithpValue;
            const then = program.get!ulong(i + 1);
            const otherwise = program.get!ulong(i + 1 + ulong.sizeof);
            i = lhs.lithpCmp(rhs).value < 0 ? then : otherwise;
        },
        Opcode.DUP: (ref i){
            stack.push(stack.top!LithpValue);
            i += Opcode.sizeof;
        },
        Opcode.MUL: (ref i){
            auto rhs = stack.pop!LithpValue;
            auto lhs = stack.pop!LithpValue;
            stack.push(lhs.lithpMult(rhs));
            i += Opcode.sizeof;
        },
        Opcode.SUB: (ref i){
            auto rhs = stack.pop!LithpValue;
            auto lhs = stack.pop!LithpValue;
            stack.push(lhs.lithpSub(rhs));
            i += Opcode.sizeof;
        },
        Opcode.ADD: (ref i){
            auto rhs = stack.pop!LithpValue;
            auto lhs = stack.pop!LithpValue;
            stack.push(lhs.lithpAdd(rhs));
            i += Opcode.sizeof;
        },
        Opcode.ICONST: (ref i){
            stack.push(program.get!int(i + 1));
            i += Opcode.sizeof + int.sizeof;
        },
        Opcode.IMUL: (ref i){
            auto rhs = stack.pop!int;
            auto lhs = stack.pop!int;
            stack.push(rhs * lhs);
            i += Opcode.sizeof;
        },
        Opcode.IDUP: (ref i){
            //stack.push(stack.top!int);
            i += Opcode.sizeof;
        },
        Opcode.POP: (ref i){
            stack.pop!LithpValue;
            i += Opcode.sizeof;
        },
        Opcode.PRINT: (ref i){
            stack.pop!LithpValue.lithpString.value.writeln;
            i += Opcode.sizeof;
        },
        Opcode.SWAP: (ref i){
            auto first = stack.pop!LithpValue;
            auto second = stack.pop!LithpValue;
            stack.push(first);
            stack.push(second);
            i += Opcode.sizeof;
        },
        Opcode.INC: (ref i){
            stack.push(stack.pop!LithpValue.lithpAdd(box(1)));
            i += Opcode.sizeof;
        },
        Opcode.DEC: (ref i){
            stack.push(stack.pop!LithpValue.lithpSub(box(1)));
            i += Opcode.sizeof;
        }
    ];

    for(size_t i = 0; i < program.length;){
        handlers[program[i]](i);
    }
    stack.pop!LithpValue.writeln;
}
