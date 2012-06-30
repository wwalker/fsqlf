module higher_types;
//operations on types

import types;

alias uint t_index;

Keyword[string] keywordList, ignoredByParser, allOtherMatches;
static this()
{
    alias Spacing S;
    alias Keyword K;
    keywordList =
    [ //empty string "" means default value (same as 'name', for comand line spaces will  be converted to underscores)
      //keyword      ||  opt | -----spaces-------| ------text-------|  spacing  | regex
      //name         ||  name| before  | after   | short   | long   |  mandatory| string
         "comma"      : K("",   S(1,0,0), S(0,0,1), ","          , "",  true,      "")
        ,"select"     : K("",   S(1,0,0), S(1,0,2), "SELECT"     , "",  true,      "")
        ,"inner join" : K("",   S(1,0,0), S(0,0,1), "JOIN"       , "",  true,      "")
        ,"left join"  : K("",   S(1,0,0), S(0,0,1), "LEFT JOIN"  , "",  true,      "")
        ,"right join" : K("",   S(1,0,0), S(0,0,1), "RIGHT JOIN" , "",  true,      "")
        ,"full join"  : K("",   S(1,0,0), S(0,0,1), "FULL JOIN"  , "",  true,      "")
        ,"cross join" : K("",   S(1,0,0), S(0,0,1), "CROSS JOIN" , "",  true,      "")
        ,"from"       : K("",   S(1,0,0), S(0,0,1), "FROM"       , "",  true,      "")
        ,"on"         : K("",   S(1,0,1), S(0,0,1), "ON"         , "",  true,      "")
        ,"where"      : K("",   S(1,0,0), S(0,0,1), "WHERE"      , "",  true,      "")
        ,"and"        : K("",   S(1,0,0), S(0,0,1), "AND"        , "",  true,      "")
        ,"or"         : K("",   S(1,0,0), S(0,0,1), "OR"         , "",  true,      "")
        ,"exists"     : K("",   S(0,0,0), S(0,0,1), "exists"     , "",  true,      "")
        ,"in"         : K("",   S(0,0,0), S(0,0,1), "in"         , "",  true,      "")
        ,"as"         : K("",   S(0,0,1), S(0,0,1), "as"         , "",  true,      "")
        ,"union all"  : K("",   S(2,1,0), S(1,0,0), "UNION ALL"  , "",  true,      "")
        ,"union"      : K("",   S(2,1,0), S(1,0,0), "UNION"      , "",  true,      "")
        ,"intersect"  : K("",   S(2,1,0), S(1,0,0), "INTERSECT"  , "",  true,      "")
        ,"except"     : K("",   S(2,1,0), S(1,0,0), "EXCEPT"     , "",  true,      "")
        ,"groupby"    : K("",   S(1,0,0), S(0,0,0), "GROUP BY"   , "",  true,      "")
        ,"orderby"    : K("",   S(1,0,0), S(0,0,0), "ORDER BY"   , "",  true,      "")
        ,"semicolon"  : K("",   S(1,0,0), S(1,0,0), ";"          , "",  true,      "")
        ,"having"     : K("",   S(1,0,0), S(0,0,0), "HAVING"     , "",  true,      "")
        ,"qualify"    : K("",   S(1,0,0), S(0,0,0), "QUALIFY"    , "",  true,      "")
        ,"'('"          : K("",   S(0,0,0), S(0,0,0), "("        , "",  true,      `\(`) //&debug_p,&inc_LEFTP ,NULL    ,NULL      ,NULL,NULL )
        ,"')'"          : K("",   S(0,0,0), S(0,0,0), ")"        , "",  true,      `\)`) //&debug_p,&inc_RIGHTP,NULL    ,NULL      ,NULL,NULL )
        ,"subquery '('" : K("",   S(1,0,0), S(0,0,0), "("        , "",  true,      `\(`) //&debug_p,&inc_LEFTP ,NULL    ,&begin_SUB,NULL,NULL )
        ,"subquery ')'" : K("",   S(1,0,0), S(1,0,0), ")"        , "",  true,      `\)`) //&debug_p,&inc_RIGHTP,&end_SUB,NULL      ,NULL,NULL )
        ,"number"     : K("",   S(1,0,0), S(1,0,0), " "          , "",  true, `\d+`)
    ];
    foreach(n,k ; keywordList) k.kwName = n;
/*
    auto numbers = regex(r"^\d+");
    auto word    = regex(r"^[\w\d_#]+"); // leading digits should've been already consumed

    auto cmtOneLine   = regex(r"^--*\n");
    auto cmtMultiLine = regex(r"^/\*+([^*]+|\*+[^/])*\*+/");
    auto singleQuotedString = regex(r"^'([^']|'')+'");
    auto doubleQuotedString = regex("^\"[^\"\\n]+\"");
    auto other   = regex(r"^[^\d\s\w]"); // should be puntuation characters
*/




    foreach(kwname ,ref kw ; keywordList) kw.initDefaults();

}




/* Token Array will be result of lexing */
struct Token(T)
{
    T name;
    string text;
    size_t length;

    pure this(in T name, in string text)
    {
        this.name = name;
        this.text = text;
        this.length = this.text.length;
    }
    pure auto opEquals(Token b)
    {
        return this.name == b.name && this.text == b.text && this.length == b.length;
    }
    pure auto clear()
    {
        this.length = 0;
    }

    @property bool empty()
    {
        return this.length == 0;
    }
}


