module dbg;
/*
Implement functions for debuging purposes
*/

import std.stdio;





/* Print formatters structures to screen
   Structure has to have toString member function */
void print(T)(T inputRange)
{
    static assert(__traits(hasMember, T, "toString"));
    T copy = inputRange; // copy is made, because while converting to string, original range would get depleted
    import std.stdio;
    import std.traits:fullyQualifiedName;
    writeln(std.traits.fullyQualifiedName!T, ":");
    writeln(copy.toString(),"\n");
}
