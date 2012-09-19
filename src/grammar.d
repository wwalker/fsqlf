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
module grammar;



/*

Section starts (can end other sections)
Group-A - Contains list of one or more items separated by separators:
SELECT
FROM
WHERE
GROUP BY
ORDER BY
QUALIFY

Group-B - Contains single item
UPDATE
INSERT INTO
DELETE FROM
SAMPLE

Paranthesis
- can contain
--paranthesis
--comma separated list
--join separated list
--select statement
--nothing

DDL statements

class NonTerminalElement
{
    auto getRange(){ assert 0; }
    void setwParse(in char[] input) { assert(0); }
    void toString(in char[] input) { assert(0); }
}

class Select : ChildOfParanthised

class Column : ChildOfSelect

class Paranthised : ChildOfColumn
                   ,ChildOfParanthised
                   ,ChildOfCase


class Case : ChildOfColumn
            ,ChildOfParanthised
            ,ChildOfCase
*/


alias string[] in_type;
alias string in_element;
alias string kw_type;
alias string[] t_resultElement;


/* Routines which implement input-range primitives for array
   will be used only temporarily until module is integerated with the rest of the program
 */
in_element front(in_type input){
    return input[0];
}

bool empty(in_type input){
    return input.length == 0;
}

void popFront(ref in_type input){
    import std.range;
    input = drop(input,1);
}

in_element getFrontThenPop(ref in_type input){
    auto cache = front(input);
    popFront(input);
    return cache;
}




struct Configuration
{
    immutable kw_type _start;
    immutable kw_type[] _separator;
    immutable kw_type _end;
    immutable bool include_end;
    
    bool opEquals(Configuration other)
    {
        return this._start == other._start
            && this._end == other._end
            && this._separator == other._separator
            && this.include_end == other.include_end;
    }

    bool isStart(in_element item)
    {
        return  item == _start;
    }

    bool isSeparator(in_element item)
    {
        return  item == _separator[0];
    }

    bool isEnd(in_element item)
    {
        return  item == _end;
    }

    bool isListItemEnd(in_element item)
    {
        return  isEnd( item ) || isSeparator( item );
    }

    enum Element {Start,Separator,End, Other}

    /* Return type of the element, based on current configuration */
    Element elementType(in_element item)
    {
        if(item == _start)
    {
            return Element.Start;
    }
        else if(item == _separator[0])
    {
            return Element.Separator;
    }
        else if(item == _end)
    {
            return Element.End;
    }
        else
    {
            return Element.Other;
    }
    }

    // standart configurations
    enum SELECT = Configuration("SELECT",[","],"FROM",false);
    enum PARANTHESIS = Configuration("(",[","],")",true);
    enum NONE = Configuration(" ",[" "]," ",false);
}




Configuration selectConfiguration(in_element text)
{
    if(Configuration.SELECT.isStart(text))
    {
        return Configuration.SELECT;
    }
    else if(Configuration.PARANTHESIS.isStart(text))
    {
        return Configuration.PARANTHESIS;
    }
    else
    {
        return Configuration.NONE;
    }
}




interface Node
{
    string toString();
    @property bool empty();
    void clear();
}

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
    string toString()
    {
        import std.algorithm;
        alias map!q{"\""~a~"\""} quote;
        alias reduce!q{a~", "~b.text} joinByCommas;
        return joinByCommas( quote(_payload) );
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
}
unittest
{
    auto x = new Leaf;
    x ~= "str1";
    x ~= "str2";
    assert(x.toString() == "\"str1\", \"str2\"");
}


class SubTree : Node
{
private:
    in_type _input;
    in_type* _input_adress;

    Configuration _conf;

    Node _cachedFront;
    bool _inputRangeEnd;

public:
    this(ref in_type input, Configuration conf)
    {
        _input = input;
        _input_adress = &input;

        _conf = conf;
        //conf(startDelim,separator,end,include_end);

        _inputRangeEnd = false;
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
        return  _input.empty || _inputRangeEnd;
    }

    void clear()
    {
        _input.clear();
    }

    override
    string toString()
    {
        import std.algorithm;
        import std.array;

        string b(string txt) { return "{"~txt~"}";}
        string n(string txt) { return "\n"~txt;}

        string result;
        foreach(x;this){
            result ~= n( b( x.toString() ) );
        }
        return "\n\nTree:" ~ result ~ "\n\n";
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
                _inputRangeEnd = true;
                goto case Configuration.Element.Start;
            case Configuration.Element.Start:
            case Configuration.Element.Separator:
                result ~= _input.getFrontThenPop();
                break;

            /* Anything other, will can be:
             * a) start new substree
             * b) just usual element of current node
            */
            case Configuration.Element.Other:
                auto selectedConf = selectConfiguration( _input.front() );
                /* a) start new substree */
                if( selectedConf != Configuration.NONE )
                {
                    return new SubTree(_input, selectedConf);
                }
                /* b) just usual element of current node */
                while ( !_input.empty && !isListItemEnd( _input.front() ) )
                {
                    result ~= _input.getFrontThenPop();
                }
                break;

            default:
                assert(0);
        }

        // if configuration is end-inclusive then do not end list yet even if ending element is found
        if( !_input.empty  &&  _conf.isEnd( _input.front() )  &&  !_conf.include_end )
        {
            _inputRangeEnd = true;
        }

        return result;
    }
}
unittest
{
    import std.stdio;
    import std.array;
    string[] input = array( splitter("SELECT 1 , ( 2 , 3 x ) , 4 FROM") );
    writeln( new SubTree( input, Configuration.SELECT ) );
    writeln("\n\n");
}
