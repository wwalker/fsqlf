module keyword_conf;

import configuration_types;

Keyword[string] keywordList;
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

        ,"space"      : K("",   S(1,0,0), S(1,0,0), " "          , "",  true, `( |\n|\t)+`)
        ,"number"     : K("",   S(1,0,0), S(1,0,0), " "          , "",  true, `\d+`)
    ];

    foreach(kwname ,ref kw ; keywordList) kw.initDefaults();
}


/* Token Array will be result of lexing */
struct Token
{
    string name;
    string text;
    ulong length;

    auto toString()
    {
        return "(" ~ this.name ~ " : " ~ this.text ~ ")";
    }
    unittest
    {
        assert(Token("select","SElECT").toString == "(select : SElECT)");
    }


    this(in string name, in string text)
    {
        this.name = name;
        this.text = text;
        this.length = this.text.length;
    }
}


auto nextNonSpaceNorComment(in Token[] tokens,long current)
{
    assert(tokens[current].name != "EOF");
    auto i = current + 1; // next
    // TODO: add also comment token here, when thei will be added to this file
    while(tokens[i].name == "space") ++i; // if next token was space, skip it and take the one after it

    return i;
}


/* Extract token from the front of the string */
auto getFrontToken(in string input, Keyword[string] kw_collection)
{
    if(input == "") return Token("EOF", "");
    foreach(string kwName, Keyword kw; kw_collection)
    {
        auto m = kw.matchTokens(input);
        if(m) return Token(kwName, m.captures.hit());
    }
    import std.regex;
    return Token("none", std.regex.match(input, regex(`[^ \t\r\n]+`)).captures.hit() );
}
unittest
{
    assert(getFrontToken("seLEct", keywordList).toString == "(select : seLEct)");
    assert(getFrontToken("seLEct", keywordList).length == 6);
    assert(getFrontToken("xyz.zyx", keywordList).toString == "(none : xyz.zyx)");
    assert(getFrontToken("xyz.zyx", keywordList).length == 7);
}


auto getFrontKeyword(Token[] tokens, Keyword[string] kw_collection)
{
    
    return tokens;
}