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
    immutable kw_type[] _start;
    immutable kw_type[] _separator;
    immutable kw_type[] _end;
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
        import std.algorithm:canFind;
        return  canFind( _start, item );
    }

    bool isSeparator(in_element item)
    {
        import std.algorithm:canFind;
        return  canFind( _separator, item );
    }

    bool isEnd(in_element item)
    {
        import std.algorithm:canFind;
        return  canFind( _end, item );
    }

    bool isListItemEnd(in_element item)
    {
        import std.algorithm:canFind;
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
    enum SELECT = Configuration( ["SELECT"], [","], ["FROM", ")", "UNION", "SELECT" ], End.exclusive );
    enum PARANTHESIS = Configuration( ["("], [",", "UNION"], [")"], End.inclusive );
    enum FROM = Configuration( ["FROM"], [",", "JOIN"], [")" , "UNION", "SELECT"], End.exclusive );
    enum NONE = Configuration( [" "], [" "], [" "], End.inclusive );
}




/* Routines which implement input-range primitives for array
 * will be used only temporarily until module is integerated with the rest of the program
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

