module lth.vm.box;

import std.format;

import lth.vm.eval;

template CmpFun(T: string) {
    import std.string;
    alias CmpFun = cmp;
}

template CmpFun(T) {
    alias CmpFun = (x, y) => (x - y);
}

class Box(T) : LithpValue {
    public T value;
    alias value this;

    this(T t)
    {
        this.value = t;
    }

    override Box!string lithpString()
    {
        return box("%s".format(this.toString));
    }

    override Box!int lithpCmp(LithpValue o)
    {
        import std.stdio;
        if(auto x = cast(typeof(this))o){
            return new Box!int(CmpFun!T(this.value, x.value));
        }
        throw new Exception("unable to compare %s with %s".format(typeid(this), typeid(o)));
    }

    override LithpValue lithpMult(LithpValue other)
    {
        if(auto x = cast(typeof(this))other){
            static if(__traits(compiles, this.value * x.value)){
                return new Box!T(this.value * x.value);
            }
        }
        import std.exception;
        throw new Exception("unable to multiply %s with %s".format(typeid(this), typeid(other)));
    }

    override LithpValue lithpAdd(LithpValue other)
    {
        if(auto x = cast(typeof(this))other){
            static if(__traits(compiles, this.value + x.value)){
                return new Box!T(cast(T)(this.value + x.value));
            }
        }
        import std.exception;
        throw new Exception("unable to add %s to %s".format(typeid(this), typeid(other)));
    }

    override LithpValue lithpSub(LithpValue other)
    {
        if(auto x = cast(typeof(this))other){
            static if(__traits(compiles, this.value - x.value)){
                return new Box!T(cast(T)(this.value - x.value));
            }
        }
        import std.exception;
        throw new Exception("unable to subtract %s from %s".format(typeid(other), typeid(this)));
    }

    override string toString()
    {
        return ("Box(%s)").format(this.value);
    }
}

pragma(inline)
auto box(T)(in auto ref T t)
{
    return new Box!T(t);
}
