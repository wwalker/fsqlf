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
/*
    auto numbers = regex(r"^\d+");
    auto word    = regex(r"^[\w\d_#]+"); // leading digits should've been already consumed

    auto cmtOneLine   = regex(r"^--*\n");
    auto cmtMultiLine = regex(r"^/\*+([^*]+|\*+[^/])*\*+/");
    auto singleQuotedString = regex(r"^'([^']|'')+'");
    auto doubleQuotedString = regex("^\"[^\"\\n]+\"");
    auto other   = regex(r"^[^\d\s\w]"); // should be puntuation characters
*/
    ignoredByParser =
    [
        "space": K("",   S(1,0,0), S(1,0,0), " "          , "",  true, `( |\n|\t)+`)
        //TODO: add comments
    ];

    //allOtherMatches TODO: define this

    foreach(kwname ,ref kw ; keywordList) kw.initDefaults();
    foreach(kwname ,ref kw ; ignoredByParser) kw.initDefaults();
}




/* Token Array will be result of lexing */
struct Token(T)
{
    T name;
    string text;
    ulong length;

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


/* Extract token from the front of the string */
Token!string getFrontToken(in string input, Keyword[string] kw_collection, Keyword[string] ignoredByParser)
{
    if(input == "") return Token!string("EOF", "");
    /* first try to match spaces and comments */
    foreach(string kwName, Keyword kw; ignoredByParser)
    {
        auto m = kw.matchTokens(input);
        if(m) return Token!string("space", m.captures.hit());
    }

    /* then try keywords*/
    foreach(string kwName, Keyword kw; kw_collection)
    {
        auto m = kw.matchTokens(input);
        if(m) return Token!string("keyword", m.captures.hit());
    }

    /* otherwise match anything else */
    import std.regex;
    return Token!string("none", std.regex.match(input, regex(`[^ \t\r\n]+`)).captures.hit() );
}




auto getFrontToken(in string input, Keyword[string] kw_collection)
{
    if(input == "") return "";

    /* then try keywords*/
    foreach(string kwName, Keyword kw; kw_collection)
    {
        auto m = kw.matchTokens(input);
        if(m) return m.captures.hit();
    }

    /* otherwise match anything else */
    import std.regex;
    return std.regex.match(input, `[^ \t\r\n]+\b`).captures.hit();
}
unittest
{
    assert(getFrontToken("seLEct", keywordList, ignoredByParser).text == "seLEct");
    assert(getFrontToken("seLEct", keywordList, ignoredByParser).length == 6);
    assert(getFrontToken("xyz.zyx", keywordList, ignoredByParser).text == "xyz.zyx");
    assert(getFrontToken("xyz.zyx", keywordList, ignoredByParser).length == 7);
}



/* Get Keyword from the front of token[] container */
auto getFrontKeyword(ref Token!string[] tokens, Keyword[string] keywordCollection)
{
    import std.algorithm;
    if(tokens[0].text == "") return Token!string("EOF",tokens[0].text);
    foreach( kwname, kw ; keywordCollection)
    {
        auto n = 9; // longest keyword seems to be 3 words. 9 will surely enough //kw.getLongestWordCount(); - use this to optimise if needed later
        t_index[] keywordIndexes = nTokenIndexesByName(tokens, n, "keyword");
        string[] nextNWords = extractTokenTextsByIndexes(tokens, keywordIndexes);

        auto nbrOfMatchedWords = kw.matchedWordcount(nextNWords);
        if(nbrOfMatchedWords > 0)
        {
            /* leave first - delete others words from input, because they are allready matched and should not be used by later matches */
            for(auto i = 0 ; i < nbrOfMatchedWords ; i++) 
            {
                tokens[keywordIndexes[i]].text = " ";
                tokens[keywordIndexes[i]].name = "space"; // TODO : do better deletion - probably move to linked lists
            }
            return Token!string(kwname, std_algorithm_joiner(nextNWords[0..nbrOfMatchedWords]));
        }
    }
    return Token!string("none",tokens[0].text);
}
unittest
{
    Token!string[] sequence;
    sequence ~= Token!string("keyword","left");
    sequence ~= Token!string("space"    ," "   );
    sequence ~= Token!string("keyword","join");
    sequence ~= Token!string("none","x");
    assert(getFrontKeyword(sequence, keywordList) == Token!string("left join","left join"));

    Token!string[] spaces;
    spaces ~= Token!string("none","  ");
    spaces ~= Token!string("none","  ");
    auto x2 = getFrontKeyword(spaces, keywordList);
    assert(x2 == Token!string("none" ,"  ") || x2 == Token!string("space" ,"  ")); // TODO : fix this
    assert(x2 != Token!string("spaces","  "));
    assert(x2 != Token!string("space" ," " ));
}



pure ref auto extractTokenTextsByIndexes(in Token!string[] tokens, in t_index[] indexes)
{
    assert(indexes.length >= 0);
    assert(indexes.length <= tokens.length);
    string[] extractedTokens;
    foreach(t_index i ; indexes) // get next 'n' 'keywords' which are not spaces nor comments
    {
        extractedTokens ~= tokens[i].text;
    }
    return extractedTokens;
}


/*  std_algorithm_joiner(<..>) is a workaround for std.algorithm.joiner error:  higher_types.d(<..>): Error: cannot implicitly convert expression (joiner(tmpWords," ")) of type Result to string */
auto std_algorithm_joiner(string[] x, string separator = " ")
{
    auto result=x[0];
    if(x.length<=1)return result;
    for(auto i=1 ; i<x.length ; i++)
        result ~= separator ~ x[i];
    return result;
}


//nIndexesOfFunctionalTokens
pure auto nTokenIndexesByName(in Token!string[] tokens, t_index n, string tokenName)
{
    assert(n>0);
    assert(n<10); // can't think of any keyword containing that much
    t_index[] result; // will be returned
    t_index i = 0;
    import std.stdio;

    do
    {
        i = closestTokenByName(tokens, i, tokenName);
        assert(i<tokens.length);
        result ~= i;
        i++;
    } while(result.length < n && i < tokens.length-1); // i < tokens.length-1; because EOF is not keyword
    return result;
}
unittest
{
    Token!string[] testSequence;
    /* testSequence := "left" , " " , "join" */
    testSequence ~= Token!string("keyword","left");
    testSequence ~= Token!string("space"  ," "   );
    testSequence ~= Token!string("keyword","join");
    testSequence ~= Token!string("space"  ," "   );
    testSequence ~= Token!string("space"  ," "   );
    testSequence ~= Token!string("keyword","join");

    assert(nTokenIndexesByName(testSequence, 1, "keyword") == [0]);
    assert(nTokenIndexesByName(testSequence, 2, "keyword") == [0,2]);
    assert(nTokenIndexesByName(testSequence, 3, "keyword") == [0,2,5]);
}



bool isMember(T)(T item, T[] array)
{
    foreach(T arrayItem; array)
        if(item == arrayItem) return true;
    return false;
}


pure auto closestTokenByName(in Token!string[] tokens, in t_index currentIndex, in string tokenName)
{
    assert(tokens[currentIndex].name != "EOF");
    assert(currentIndex < tokens.length);
    t_index resultIndex = currentIndex;

    while(resultIndex+1 < tokens.length && tokens[resultIndex].name != tokenName) ++resultIndex;

    assert(resultIndex < tokens.length);
    return resultIndex;
}
unittest
{
    Token!string[] testSequence;
    /* testSequence := "left" , " " , "join" */
    testSequence ~= Token!string("keyword","left");
    testSequence ~= Token!string("space"  ," "   );
    testSequence ~= Token!string("keyword","join");
    testSequence ~= Token!string("space"  ," "   );
    assert(closestTokenByName(testSequence, 0, "keyword") == 0);
    assert(closestTokenByName(testSequence, 1, "keyword") == 2);
}
