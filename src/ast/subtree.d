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


import ast.node_type;
import ast.node;
import ast.leaf;


/* Given initial config (e.g. for SELECT statemnt) and input it creates recursive structure, representing */
class SubTree : Node
{
private:
    SubTree _parent;
    in_type _input;
    in_type* _input_adress;

    Configuration _conf;

    Node _cachedFront;
    bool _forceEmpty;

public:
    static SubTree no_parent = null;
    this(SubTree parent, ref in_type input, Configuration conf)
    {
        _parent = parent;
        _input = input;
        _input_adress = &input;
        _conf = conf;
        //conf(startDelim,separator,end,include_end);

        _forceEmpty = false;
        _cachedFront = new Leaf;
    }

    auto front()
    {
        if(_cachedFront.empty)
        {
            _cachedFront = getItem();
            (*_input_adress) = _input; // modify also variable suplied during creation of SubTree
        }
        return _cachedFront;
    }

    void popFront()
    {
        _cachedFront.clear;
    }

    @property
    bool empty()
    {
        return  _input.empty || _forceEmpty;
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
    bool isListItemEnd(in_element item)
    {
        return  _conf.isEnd( item ) || _conf.isSeparator( item );
    }

    Node getItem()
    {
        auto result = new Leaf;

        switch( _conf.elementType( _input.front() )  )
        {
            /* Elements of configuration (start/separator/end) */
            case Configuration.Element.End:         // NOTE: Fall-through "case";
                _forceEmpty = true;
                goto case Configuration.Element.Start;
            case Configuration.Element.Start:
            case Configuration.Element.Separator:
                result ~= _input.getFrontThenPop();
                break;

            /* Anything other, will  be:*/
            case Configuration.Element.Other:
                auto selectedConf = selectConfiguration( _input.front() );
                /* ..a) start of new substree */
                if( selectedConf != Configuration.NONE )
                {
                    return new SubTree( this, _input, selectedConf );
                }
                /* ..b) just usual element of current node */
                while ( !_input.empty && !isListItemEnd( _input.front() ) )
                {
                    result ~= _input.getFrontThenPop();
                }
                break;

            default:
                assert(0);
        }

        // if configuration is end-inclusive then do not end list yet even if ending element is found
        if( !_input.empty
            &&  _conf.isEnd( _input.front() )
            &&  _conf.include_end == End.exclusive
            )
        {
            _forceEmpty = true;
        }

        return result;
    }
}
unittest
{
    import std.stdio;
    import std.array;
    string[] input = array( splitter("SELECT 1 , ( 2 , 3 x ) , 4 , 5 FROM ( SELECT 1 t UNION SELECT 2 t ) a") );
    auto st = new SubTree( SubTree.no_parent, input, Configuration.NONE );
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
