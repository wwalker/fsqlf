module ast.node_subtree;


import ast.node;
import ast.node_leaf;

import ast.conf;
import ast.conf_select;


class SubTree : Node
{
private:
    SubTree _parent;
    in_type _input;
    in_type* _input_adress;

    SubtreeConf _conf;

    Node _cachedFront;
    string cachedPreviousLeafsLastItem;

public:
    static SubTree no_parent = null;
    this(SubTree parent, ref in_type input, SubtreeConf conf)
    {
        _parent = parent;
        _input = input;
        _input_adress = &input;
        _conf = conf;

        _cachedFront = new Leaf;
    }


    @property
    bool empty()
    {
        if( _input.empty )
        {
            return true;
        }
        else if( _conf.include_end == End.exclusive
            && _conf.isEndOfNode( _input.front() ) )
        {
            return true;
        }
        else if( _conf.include_end == End.inclusive
            && _conf.isEndOfNode( cachedPreviousLeafsLastItem ) )
        {
            return true;
        }

        return false;
    }


    auto front()
    {
        if( _cachedFront.empty )
        {
            _cachedFront = getItem();
            (*_input_adress) = _input; // modify also variable suplied during creation of SubTree

            cachedPreviousLeafsLastItem = leafsLastItem( _cachedFront );
        }
        return _cachedFront;
    }


    void popFront()
    {
        _cachedFront.clear;
    }


    void clear()
    {
        _input.clear();
    }


    override
    string toStringIndented( int indentation_level )
    {
        import std.algorithm;
        import std.array;
        import std.conv;

        string b(string txt) { return "{"~txt~"}";}
        string n(string txt, int indent_mod = 0) { return "\n" ~ indent(indentation_level+indent_mod) ~ txt; }

        string result;
        foreach( childOfThis ; this ){
            result ~= n(  childOfThis.toStringIndented(indentation_level+1) );
        }
        return n("Subtree",-1) ~ n("{",-1) ~ result ~ n("}",-1);
    }


private:
    Node getItem()
    {
        if( _conf.isRecognised( _input.front() ) )
        {
            return getLeafSingleItem();
        }
        else if( selectConfiguration( _input.front() ) == SubtreeConf.NONE )
        {
            return getLeafMultiItem();
        }
        else
        {
            auto selectedConf = selectConfiguration( _input.front() );
            return new SubTree( this, _input, selectedConf );
        }
    }


    Leaf getLeafMultiItem()
    {
        auto leaf = new Leaf;
        while ( !_input.empty && !_conf.isEndOfLeaf( _input.front() ) )
        {
            leaf ~= _input.getFrontThenPop();
        }
        return leaf;
    }


    Leaf getLeafSingleItem()
    {
        auto leaf = new Leaf;
        leaf ~= _input.getFrontThenPop();
        return leaf;
    }


    static string leafsLastItem( Node front )
    {
        Leaf frontLeaf = cast(Leaf) front;

        if( frontLeaf && !frontLeaf.empty)
        {
            return frontLeaf.lastItem();
        }
        else
        {
            return "";
        }
    }
}
unittest
{
    import std.stdio;
    import std.array;
    string[] input = array( splitter("SELECT 1 , ( 2 , 3 x ) , 4 , 5 FROM ( SELECT 1 t UNION SELECT 2 t ) a") );
    auto st = new SubTree( SubTree.no_parent, input, SubtreeConf.NONE );
    writeln( st );
    writeln("\n\n");
}
