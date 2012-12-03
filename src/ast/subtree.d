/*
To apply context-sensitive formatting, it is needed to recognize SQL constructs
(Example of context-sensitive formatting would be putting new line before left paranthesis only when it contains subquery)
This module parses sequence of keywords/tokens and recognizes structure of some SQL calauses/constructs

How this will be done:
    SQL is interpreted as sequence of lists
    List is made of: list-items, start-keyword(s), separator-keyword(s), optional end-keyword
    List-item can it self be a list, so it becomes a tree structure
    (e.g. in select clause instead of simple column name, there can be complex case stament )

Examples of list manifestations in SQL:
    SELECT keyword is followed by a list of columns separated by commas
    FROM keyword is followed by list of objects (tables/views/subqueries with ON conditions) separated by JOIN keywords or commas
*/
module ast.subtree;

import ast.node;
import ast.leaf;

import ast.subtree_conf;
import ast.sql_subtrees;


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





/*
Section starts (can end other sections)

Group-A - Contains list of one or more items separated by separators:
 SELECT, FROM, WHERE, GROUP BY, ORDER BY, QUALIFY

Group-B - Contains single item:
 UPDATE, INSERT INTO, DELETE FROM, SAMPLE

Paranthesis can contain
 paranthesis, comma separated list, join separated list, select statement, nothing

class Select : ChildOfParanthised
class Column : ChildOfSelect
class Paranthised : ChildOfColumn, ChildOfParanthised, ChildOfCase
class Case : ChildOfColumn, ChildOfParanthised, ChildOfCase
*/
