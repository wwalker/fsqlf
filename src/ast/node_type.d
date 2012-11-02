/* Defines node type from abstract syntax tree (e.g. 'select' clause, 'from' clause etc.)  */
module ast.node_type;


alias string[] in_type;
alias string in_element;
alias string kw_type;
alias string[] t_resultElement;


enum End {inclusive, exclusive};



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
    else if(Configuration.FROM.isStart(text))
    {
        return Configuration.FROM;
    }
    else
    {
        return Configuration.NONE;
    }
}



struct Configuration
{
    immutable kw_type _start;
    immutable kw_type[] _separator;
    immutable kw_type _end;
    immutable End include_end;

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

    enum Element {Start, Separator, End, Other}

    /* Return type of the element, based on current configuration */
    Element elementType(in_element item)
    {
        import std.algorithm:canFind;
        if( canFind( _start, item ) )
        {
            return Element.Start;
        }
        else if( canFind( _separator, item ) )
        {
            return Element.Separator;
        }
        else if( canFind( _end, item ) )
        {
            return Element.End;

        }
        else
        {
            return Element.Other;
        }
    }

    // standart configurations
    enum SELECT = Configuration( "SELECT", [","], "FROM", End.exclusive );
    enum PARANTHESIS = Configuration( "(", [","], ")", End.inclusive );
    enum FROM = Configuration( "FROM", [",", "JOIN"], ")", End.inclusive );
    enum NONE = Configuration( " ", [" "], " ", End.inclusive );
}
