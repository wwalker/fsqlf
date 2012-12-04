module ast.node_leaf;


import ast.conf;
import ast.node;


class Leaf : Node
{
    in_type _payload;
    this(){}

    this(in_element content)
    {
        _payload ~= content;
    }

    Leaf opCatAssign(in_element anOther)
    {
        _payload ~= anOther;
        return this;
    }

    override
    string toStringIndented( int indentation_level  )
    {
        import std.algorithm;
        alias map!q{"\""~a~"\""} quote;
        alias reduce!q{a~", "~b.text} joinByCommas;
        return "<" ~ joinByCommas( quote(_payload) ) ~ ">";
    }

    @property
    bool empty()
    {
        return  _payload.length == 0;
    }

    void clear()
    {
        _payload = [];
    }
    
    auto lastItem()
    {
        return _payload[_payload.length-1];
    }
}
unittest
{
    auto x = new Leaf;
    x ~= "str1";
    x ~= "str2";
    assert(x.toStringIndented(0) == "<\"str1\", \"str2\">");
}