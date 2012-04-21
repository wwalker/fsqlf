module higher_types;
//operations on types

import types;

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
    auto opEquals(Token b)
    {
        return this.name == b.name && this.text == b.text && this.length == b.length;
    }
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


auto getFrontKeyword(ref Token[] tokens, Keyword[string] kw_collection)
{
    import std.algorithm;
    if(tokens[0].text == "") return Token("none",tokens[0].text);
    foreach( kwname, kw ; kw_collection)
    {
        auto n = 9;//kw.getLongestWordCount();
        string[] nextNWords;
        auto ix = nIndexesOfFunctionalTokens(tokens, n);
        foreach(ulong i ; ix) // get next 'n' 'keywords' which are not spaces nor comments
        {
            nextNWords ~= tokens[i].text;
        }
import std.stdio;
if(kwname == "left join" && 1==0)
{
    writeln("tokens: ", tokens, "\t\t| n:", n, "\t\t|->|ix: ", ix,"\t\t|->|nextNWords: ", nextNWords);
}
        auto nbrOfMatchedWords = kw.matchKeyword(nextNWords);
        if(nbrOfMatchedWords)
        {
            /* leave first - delete others words from input, because they are allready matched and should not be used by later matches */
            for(auto i = 0 ; i < nbrOfMatchedWords ; i++) 
            {
                tokens[ix[i]].text = " ";
                tokens[ix[i]].name = "space"; // TODO : do better deletion - probably move to linked lists
            }
            return Token(kwname, std_algorithm_joiner(nextNWords[0..nbrOfMatchedWords]));
        }
    }
    return Token("none",tokens[0].text);
}
unittest
{
    Token[] sequence;
    sequence ~= Token("left join","left");
    sequence ~= Token("space"    ," "   );
    sequence ~= Token("left join","join");
    sequence ~= Token("none","x");
    assert(getFrontKeyword(sequence, keywordList) == Token("left join","left join"));
    import std.stdio;
//    writeln(x2);

    Token[] spaces;
    spaces ~= Token("none","  ");
    spaces ~= Token("none","  ");
    auto x2 = getFrontKeyword(spaces, keywordList);
    assert(x2 == Token("space" ,"  "));
    assert(x2 != Token("spaces","  "));
    assert(x2 != Token("space" ," " ));
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


auto nIndexesOfFunctionalTokens(in Token[] tokens, ulong n)
{
    assert(n>0);
    assert(n<10); // can't think of any keyword containing that much
    ulong[] result; // will be returned
    ulong i = 0;
    import std.stdio;
//writeln("tokens:",tokens);
//writeln("n:",n);
    do
    {
        i = closestNonSpaceNorComment(tokens, i);
//writeln("tokens:",tokens);
//writeln("y:",y);
        assert(i<tokens.length);
        result ~= i;
        i++;
        //writeln("tokens:",tokens);
        //writeln("i:" , i,";n:",n,";tokens.length:",tokens.length);
    } while(result.length < n && i < tokens.length-1); // i < tokens.length-1; because EOF is not keyword
//writeln(result," ",n);
    return result;
}
unittest
{
    Token[] testSequence;
    /* testSequence := "left" , " " , "join" */
    testSequence ~= Token("left join","left");
    testSequence ~= Token("space"    ," "   );
    testSequence ~= Token("left join","join");
    testSequence ~= Token("space"    ," "   );
    testSequence ~= Token("space"    ," "   );
    testSequence ~= Token("left join","join");
    assert(nIndexesOfFunctionalTokens(testSequence, 1) == [0]);
    assert(nIndexesOfFunctionalTokens(testSequence, 2) == [0,2]);
    assert(nIndexesOfFunctionalTokens(testSequence, 3) == [0,2,5]);
}



bool isMember(T)(T item, T[] array)
{
    foreach(T arrayItem; array)
        if(item == arrayItem) return true;
    return false;
}


auto closestNonSpaceNorComment(in Token[] tokens,ulong current)
{
    assert(tokens[current].name != "EOF");
    assert(current < tokens.length);
    auto i = current;
    // TODO: add also checking for comment tokens here, when they will be added to this file
    while(i+1 < tokens.length && tokens[i].name == "space") ++i; // if next token is space, skip it
    assert(i < tokens.length);
    return i;
}
unittest
{
    Token[] testSequence;
    /* testSequence := "left" , " " , "join" */
    testSequence ~= Token("left join","left");
    testSequence ~= Token("space"    ," "   );
    testSequence ~= Token("left join","join");

    assert(closestNonSpaceNorComment(testSequence, 0) == 0);
    assert(closestNonSpaceNorComment(testSequence, 1) == 2);
}
