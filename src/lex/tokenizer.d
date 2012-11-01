/* Module goal is to split string into tokens */
module lex.tokenizer;


import types;
import higher_types;




enum TokenType {spacing,comment,other};





/* InputRange contructed from SQL text string and returning tokenized content
   3 types of tokens are recognized: Spacing, Comments, Other.
   e.g. if constructed from "SELECT 1 --xx", it would return tokens: (SELECT)( )(1)( )(--xx) */
struct Tokenizer
{
private:
    string p_sqlText; // input text to be tokenized
    alias Token!TokenType ResultToken; // alias for front() result type
    ResultToken p_cachedFront; // cached value


public:
    /* Tokenizer constructor from sql text stored in string */
    this(string sqlText)
    {
        p_sqlText = sqlText;
    }


    /* Extract token from front of the text string.  Result is cached */
    auto front()
    {
        if(p_cachedFront.empty)
        {
            p_cachedFront = this.getFrontToken();
        }
        return p_cachedFront;
    }


    /* Drop content used for result of front(), so next call to front() would return new token */
    void popFront()
    {
        import std.range;
        if(this.empty) assert(false);
        p_sqlText = std.range.drop(p_sqlText, this.front().length);
        p_cachedFront.clear();
    }


    /* Return TRUE if no more elements can be returned (end of input SQL string was reached) */
    @property
    bool empty()
    {
        return p_sqlText.length == 0;
    }


    /*  Convert Tokenizer to string. At the moment for debuging purposes */
    string toString()
    {
        import std.algorithm;
        return std.algorithm.reduce!q{a~"("~b.text~")"}("",this);
    }


private:
    /* Extract token from front of the string. popFront() only calls this function and its caches the result */
    auto getFrontToken()
    {
        string spcResult = getFront.Spacing(p_sqlText);
        if(spcResult.length>0)
        {
            return ResultToken(TokenType.spacing, spcResult);
        }

        string cmtResult = getFront.Comment(p_sqlText);
        if(cmtResult.length>0)
        {
            return ResultToken(TokenType.comment, cmtResult);
        }

        import std.array;
        auto paterns = std.array.array(toPaternRange(keywordList.values));
        return ResultToken(TokenType.other, getFront.Other(p_sqlText, paterns)); // includes string end
    }
}
unittest
{
    import std.range;
    static assert(isInputRange!Tokenizer);
    auto t = Tokenizer("SELECT /**/ FROM 1");
    assert(!t.empty);
    assert(t.front() == Token!TokenType(TokenType.other,"SELECT"));    t.popFront();
    assert(t.front() == Token!TokenType(TokenType.spacing," ")   );    t.popFront();
    assert(t.front() == Token!TokenType(TokenType.comment,"/**/"));    t.popFront();
    assert(t.front() == Token!TokenType(TokenType.spacing," ")   );    t.popFront();
    assert(!t.empty);
    assert(t.front() == Token!TokenType(TokenType.other,"FROM")  );    t.popFront();
    assert(t.front() == Token!TokenType(TokenType.spacing," ")   );    t.popFront();
    assert(t.front() == Token!TokenType(TokenType.other,"1")     );    t.popFront();
    assert(t.empty);
}





private:





/* Define couple of routines which extract content from the front of input string.
   All functions are static, class has no data-members */
class getFront
{
public:
    /* Extract spacing characters from the front of the string.
       Everything till first non-spacing character is extracted.
       If there are no spacing characters at the front of the input string, return empty string.
       Meaning of "spacing" includes: spaces,tabs,new lines */
    static
    string Spacing(in string input)
    {
        import std.regex;
        auto spMatch = std.regex.match(input,r"^\s+");
        if(spMatch.empty()) // not possible to use `with` statement (result of match is not lvalue compiler says)
            return "";
        else
            return spMatch.captures.hit();
    }
    unittest
    {
        assert(getFront.Spacing(""   )  == ""  ); // 0 spaces
        assert(getFront.Spacing(" "  )  == " " ); // 1 space
        assert(getFront.Spacing("  "  ) == "  "); // 2 spaces
        assert(getFront.Spacing("X " )  == ""  ); // 0 spaces
        assert(getFront.Spacing(" X ")  == " " ); // 1 space
        assert(getFront.Spacing("  X ") == "  "); // 2 spaces
    }


    /* Extract comment from the front of the string.
       If there is no comment at the front of the input string, return empty string.
       Both comment types are recognized: oneline and multiline.
       Unterminated comments are also recognized */
    static
    string Comment(in string input)
    {
        string cmtOneline = getFront.CommentOneline(input);
        if(cmtOneline.length == 0)
        {
            return getFront.CommentMultiline(input); // if there is no oneline comment at the front, then try multiline
        }
        else
        {
            return cmtOneline;
        }
    }
    unittest
    {
        assert(getFront.Comment("/** /**\n/**/*/") == "/** /**\n/**/"); // multiline comment
        assert(getFront.Comment("--/***\n\n") == "--/***\n"); // oneline comment
        assert(getFront.Comment(" /* /**\n/**/*/") == ""); // with leading space
    }


    import std.regex;
    /* Extract any other SQL token from front of the string (other then spacing or comment).
       If input is empty, return empty string.
       Other tokens may be:
       - SQL-string  (e.g. 'abc')
       - SQL-doublequoted-identifier  (e.g. "abc")
       - number
       - puntuation characters and operators (e.g. +*-/,)
       - rezerved SQL words (e.g. LEFT, GROUP, BY, JOIN, OUTER)
       - any word made of non-spacing characters (matched with last priority, i.e. only if none of above were matched)
       This function should be called only after Comment and Spacing functions failed to extract content */
    static
    string Other(in string input, std.regex.Regex!(char)[] paterns)
    {
        if(input == "") return "";

        /* try match paterns */
        foreach(pat; paterns)
        {
            auto regexMatch = std.regex.match(input,pat);
            if(regexMatch)
            {
                //assert(0);
                return regexMatch.captures.hit();
            }
        }

        /* if no patern was matched, match any non-space sequence till word boundry */
        auto fallbackMatch = std.regex.match(input, `[^ \t\r\n]+\b`);
        if(fallbackMatch) return fallbackMatch.captures.hit();
        assert(0);
    }
    unittest
    {
        import std.array;
        auto paterns = std.array.array(toPaternRange(keywordList.values));
        assert(getFront.Other("seLEct ", paterns) == "seLEct");
        assert(getFront.Other("seLEct ", paterns).length == 6);
        assert(getFront.Other("xyz.zyx", paterns) == "xyz.zyx");
        assert(getFront.Other("xyz.zyx", paterns).length == 7);
        assert(getFront.Other("1"      , paterns) == "1");
    }


private:
    /* Extract delimeted substring from front of the string.
       If starting delimiter is not found at the front of the input string, return empty string.
       If ending delimiter is missing, then whole input is returned (given that starting delimiter was found) */
    static
    string DelimitedString(in string input, in string delimStart, in string delimEnd)
    {
        import std.string;
        if(input.length < delimStart.length || input[0..2] != delimStart)
        {
            return "";
        }

        auto endPosition = std.string.indexOf(input, delimEnd);
        if(endPosition >= 0)
        {
            return input[0..endPosition+delimEnd.length];
        }
        else
        {
            return input;   // unterminated comment
        }
    }


    /* Extract oneline comment from the front of the string.
       If there is no comment at the front of the input string, return empty string.
       Oneline comments starts with "--" and ends with new-line or end of the input string */
    static
    string CommentOneline(in string input)
    {
        return getFront.DelimitedString(input, "--", "\n"); // TODO: handle different lineendings
    }


    /* Extract multiline comment from the front of the string.
       If there is no comment at the front of the input string, return empty string.
       Multiline comment starts with "/*" and ends with "* /" or end of the input string */
    static
    string CommentMultiline(in string input)
    {
        return getFront.DelimitedString(input, "/*", "*/");
    }
}





/* Create range of regex paterns fron collection of "Keyword" elements
   Returns range type processed by "map" and "joiner" */
auto toPaternRange(Keyword[] kw_collection)
{
    import std.algorithm;
    alias std.algorithm.map map;
    alias std.algorithm.joiner joiner;

    auto paterns = map!"a.getPaterns()"(kw_collection); // <- range of ranges
    return joiner(paterns);                             // <- range
}
