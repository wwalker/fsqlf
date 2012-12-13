/* Structure for configuration of node in abstract-syntax-tree */
module ast.conf;


alias string[] in_type;
alias string in_element;
alias string kw_type;
alias string[] t_resultElement;


enum End {inclusive, exclusive};




struct SubtreeConf( Keyword )
{
    immutable Keyword[] _start;
    immutable Keyword[] _separator;
    immutable Keyword[] _end;
    immutable End end_type;

    bool opEquals(SubtreeConf!(Keyword) other)
    {
        return this._start == other._start
            && this._end == other._end
            && this._separator == other._separator
            && this.end_type == other.end_type;
    }

    bool isStart(Keyword item)
    {
        import std.algorithm:canFind;
        return  canFind( _start, item );
    }

    bool isSeparator(Keyword item)
    {
        import std.algorithm:canFind;
        return  canFind( _separator, item );
    }

    bool isEndOfNode(Keyword item)
    {
        import std.algorithm:canFind;
        return  canFind( _end, item );
    }

    bool isEndOfLeaf(Keyword item)
    {
        return  isEndOfNode( item ) || isSeparator( item );
    }

    bool isRecognised(Keyword item)
    {
        return isStart( item )
            || isSeparator( item )
            || isEndOfNode( item );
    }

    enum Element {Start, Separator, End, Other}

    /* Return type of the element, based on current configuration */
    Element elementType(Keyword item)
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

    enum NONE = SubtreeConf!(Keyword)( [" "], [" "], [" "], End.inclusive );
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
