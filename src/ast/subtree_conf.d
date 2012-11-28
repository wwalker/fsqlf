/* Defines node type from abstract syntax tree (e.g. 'select' clause, 'from' clause etc.)  */
module ast.subtree_conf;


alias string[] in_type;
alias string in_element;
alias string kw_type;
alias string[] t_resultElement;


enum End {inclusive, exclusive};




struct subtreeConf
{
    immutable kw_type[] _start;
    immutable kw_type[] _separator;
    immutable kw_type[] _end;
    immutable End include_end;

    bool opEquals(subtreeConf other)
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

    enum NONE = subtreeConf( [" "], [" "], [" "], End.inclusive );
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

