module lth.vm.opcode;

enum Opcode : ubyte {
    IBOX = 0,
    ALOAD,
    DUP,
    POP,
    RET,
    CALL,
    MUL,
    SUB,
    DEC,
    INC,
    ADD,
    IF_EQ,
    IF_LT,
    IF_GT,
    IMUL,
    ICONST,
    IDUP,
    PRINT,
    SWAP,
    MAX_CODE
}

struct OpData {
    string mnemonic;
    size_t[] args;
}

static immutable OpData[] opcodes =  [
    /* loading and storing */
    Opcode.IBOX: OpData("ibox", [int.sizeof]),
    Opcode.ALOAD: OpData("aload", [ubyte.sizeof]),
    Opcode.DUP: OpData("dup", []),
    /* Control Flow */
    Opcode.IF_EQ: OpData("if_eq", [ulong.sizeof, ulong.sizeof]),
    Opcode.IF_GT: OpData("if_gt", [ulong.sizeof, ulong.sizeof]),
    Opcode.IF_LT: OpData("if_lt", [ulong.sizeof, ulong.sizeof]),
    Opcode.CALL: OpData("call", [ulong.sizeof]),
    Opcode.RET: OpData("ret", []),
    /* polymorphic */
    Opcode.MUL: OpData("mul", []),
    Opcode.SUB: OpData("sub", []),
    Opcode.ADD: OpData("add", []),
    Opcode.PRINT: OpData("print", []),
    Opcode.SWAP: OpData("swap", []),
    Opcode.POP: OpData("pop", []),
    Opcode.DEC: OpData("dec", []),
    Opcode.INC: OpData("inc", []),
    /* non-polymorphic */
    Opcode.IMUL: OpData("imul", []),
    Opcode.ICONST: OpData("iconst", [int.sizeof]),
    Opcode.IDUP: OpData("idup", []),
];
