module lth.vm.builder;

import lth.util : bytes;
import lth.vm.opcode;

/* TODO improve labels */

auto aload(ubyte n)
{
    return Opcode.ALOAD ~ n.bytes;
}

auto ibox(int n)
{
    return Opcode.IBOX ~ n.bytes;
}

auto if_eq(ulong eqBranch, ulong neBranch)
{
    return Opcode.IF_EQ ~ eqBranch.bytes ~ neBranch.bytes;
}

auto if_lt(ulong ltBranch, ulong elseBranch)
{
    return Opcode.IF_LT ~ ltBranch.bytes ~ elseBranch.bytes;
}

auto call(ulong fn)
{
    return Opcode.CALL ~ fn.bytes;
}

auto iconst(int i)
{
    return Opcode.ICONST ~ i.bytes;
}

auto program(Args...)(Args args)
{
    ubyte[] result;
    result.reserve(args.length);
    foreach(x; args){
        result ~= x;
    }
    return result;
}

enum sub = Opcode.SUB;
enum add = Opcode.ADD;
enum mul = Opcode.MUL;
enum ret = Opcode.RET;
enum dup = Opcode.DUP;
enum swap = Opcode.SWAP;
enum pop = Opcode.POP;
enum inc = Opcode.INC;
enum dec = Opcode.DEC;

enum idup = Opcode.IDUP;
enum imul = Opcode.IMUL;

enum print = Opcode.PRINT;

/* factorial program */
public __gshared ubyte[] factorial;
public __gshared ubyte[] fibonacci;
static this()
{
    factorial = 
        program(
            aload(0),
            ibox(1),
            if_eq(24, 30),
            // eq
            ibox(1),
            ret,
            // ne
            aload(0),
            dec,
            call(0),
            aload(0),
            mul,
            dup,
            print,
            ret
        );

    fibonacci =
        program(
            aload(0),
            ibox(2),
            if_lt(24, 30),
            /* n < 2 */
            ibox(1),
            ret,
            /* n >= 2 */
            aload(0),
            dec,
            call(0),
            aload(0),
            ibox(2),
            sub,
            call(0),
            add,
            ret
        );
}
