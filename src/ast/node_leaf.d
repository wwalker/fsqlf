/* Node-Leaf of abstract-syntax-tree */
module ast.node_leaf;


import ast.node;

import std.range:ElementType;


class Leaf( KeywordRange, Keyword = ElementType!KeywordRange ) : Node!( KeywordRange )
{
    Keyword[] _payload;
    this(){}

    this(Keyword content)
    {
        _payload ~= content;
    }

    Leaf!( KeywordRange ) opCatAssign(Keyword anOther)
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
    auto x = new Leaf!(string[]);
    x ~= "str1";
    x ~= "str2";
    assert(x.toStringIndented(0) == "<\"str1\", \"str2\">");
}
