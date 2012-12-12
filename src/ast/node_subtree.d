/* Node-Subtree of abstract-syntax-tree */
module ast.node_subtree;


import ast.node;
import ast.node_leaf;

import ast.conf;
import ast.conf_select;

import std.range:ElementType;


class SubTree( KeywordRange, Keyword = ElementType!KeywordRange ) : Node!(KeywordRange)
{
private:
    SubTree!(KeywordRange) _parent;
    KeywordRange* _input_ptr;

    SubtreeConf _conf;

    Node!(KeywordRange) _cachedFront;
    Keyword cachedPreviousLeafsLastItem;

public:
    static SubTree!(KeywordRange) no_parent = null;

    this(SubTree!(KeywordRange) parent, KeywordRange* input_adress, SubtreeConf conf)
    {
        _parent = parent;
        _input_ptr = input_adress;
        _conf = conf;

        _cachedFront = new Leaf!(KeywordRange);
    }


    @property
    bool empty()
    {
        if( (*_input_ptr).empty )
        {
            return true;
        }
        else if( _conf.end_type == End.exclusive
            && _conf.isEndOfNode( (*_input_ptr).front() ) )
        {
            return true;
        }
        else if( _conf.end_type == End.inclusive
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
            _cachedFront = getNextItem( *_input_ptr, _conf );
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
        //_input.clear();
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
    Node!(KeywordRange) getNextItem( ref KeywordRange input, SubtreeConf conf )
    {
        if( conf.isRecognised( input.front() ) )
        {
            return getLeafSingleItem( input, conf );
        }
        else if( selectConfiguration( input.front() ) == SubtreeConf.NONE )
        {
            return getLeafMultiItem( input, conf );
        }
        else
        {
            auto selectedConf = selectConfiguration( input.front() );
            return new SubTree!(KeywordRange)( this, _input_ptr, selectedConf );
        }
    }


    static
    Leaf!(KeywordRange) getLeafMultiItem( ref KeywordRange input, SubtreeConf conf )
    {
        auto leaf = new Leaf!(KeywordRange);
        while ( !input.empty && !conf.isEndOfLeaf( input.front() ) )
        {
            leaf ~= input.getFrontThenPop();
        }
        return leaf;
    }


    static
    Leaf!( KeywordRange ) getLeafSingleItem( ref KeywordRange input, SubtreeConf conf )
    {
        auto leaf = new Leaf!(KeywordRange);
        leaf ~= input.getFrontThenPop();
        return leaf;
    }


    static
    Keyword leafsLastItem( Node!(KeywordRange) front )
    {
        Leaf!(KeywordRange) frontLeaf = cast(Leaf!(KeywordRange)) front;

        if( frontLeaf
            && !frontLeaf.empty)
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
    auto st = new SubTree!(string[])( SubTree!(string[]).no_parent, &input, SubtreeConf.NONE );
    writeln( st );
    writeln("\n\n");
}
