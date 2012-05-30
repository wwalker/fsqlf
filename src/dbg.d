module dbg;

import std.stdio;

void print(T)(T inputRange)
{
    static assert(__traits(hasMember, T, "toString"));
    T copy = inputRange;
    import std.stdio;
    import std.traits:fullyQualifiedName;
    writeln(std.traits.fullyQualifiedName!T, ":");
    writeln(copy.toString(),"\n");
}

