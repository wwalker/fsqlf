/*

SELECT
FROM
WHERE
GROUP BY
ORDER BY
QUALIFY
- start of section (can end other sections with same paranthesis level)
- contains list of one or more 'members'/'objects' separated by some separators (comma, "JOIN")

UPDATE
INSERT INTO
DELETE FROM
- start of section (can end other sections with same paranthesis level)
- contains only single object

Paranthesis
- can contain
--paranthesis
--comma separated list
--join separated list
--select statement
--nothing

DDL statements
*/

class NonTerminalElement
{
    auto getRange(){ assert 0; }
    void setwParse(in char[] input) { assert(0); }
    void toString(in char[] input) { assert(0); }
}

Interface ChildOfSelect         {}
Interface ChildOfColumn         {}
Interface ChildOfParanthised    {}
Interface ChildOfCase           {}

template(ClassName,Kw[] startingKw, Kw[] endingKw, Kw[] separatingKw ,Parents ...)
{
    class ClassName: map!childOf(Parents)
    {
        childOf(ClassName)[] p_children;
        bool startsAtFront( TokenList tl ) {assert(0);}
        auto consumeChildsFromFront( TokenList tl ) {assert(0);}
    }
}



class Select : ChildOfParanthised
{   
    ChildOfSelect[] p_childs;

    const p_startKw = [ kw["select"] ];
    const p_endKw =
        [
            kw["from"],kw["where"],kw["group by"],kw["gaving"],kw["qualify"]
        ]
    const p_separator = [ kw["comma"] ]
    bool startsAtFront( Token[] tokens )
    {
        return tokens.front == kw["select"]; // TODO compare to configuration item
    }
    auto consumeChildsFromFront(byref Token[] tl)
    {
        if(!isMember(tl.front(),p_startKw))  return;
        p_childs ~= take(tl,1);
        if(isMember(tl.front(),p_endKw))  return;
        
        if(isMember(tl.front(),p_separatorKw))  return;
        {
            p_childs ~= take(tl,1);
        }
        else
        {
            p_child ~= Column(tl);
        }
    }
}

class Column : ChildOfSelect 
{
    ChildOfColumn[] p_childs;
}

class Paranthised : ChildOfColumn
                   ,ChildOfParanthised
                   ,ChildOfCase 
{
    ChildOfParanthised[] p_childs;
}

class Case : ChildOfColumn
            ,ChildOfParanthised
            ,ChildOfCase
{
    ChildOfCase[] p_childs;
}
