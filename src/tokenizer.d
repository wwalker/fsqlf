module tokenizer;


import types;
import higher_types;



enum TokenType {spacing,comment,other};


/* Input range wich breaks up SQL text into tokens
   e.g.
   if constructed from "SELECT 1 --xx",
   it would return tokens (SELECT)( )(1)( )(--xx)
   each token has a type
*/
struct Tokenizer
{
private:
    string p_sqlText;
    alias Token!TokenType ResultToken;
    ResultToken p_cachedFront;
    //string 

public:
    this(string sqlText)
    {
        p_sqlText = sqlText;
    }


    /* Get front token, which can be one of types {spacing,comment,other}*/
    auto front()
    {
        if(p_cachedFront.empty)
        {
            p_cachedFront = this.getFrontToken();
        }
        return p_cachedFront;
    }


    void popFront()
    {
        import std.range;
        if(this.empty) assert(false);
        p_sqlText = std.range.drop(p_sqlText, this.front().length);
        p_cachedFront.clear();
    }


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

        version(none)
        {
            return ResultToken(TokenType.other, getFrontToken(p_sqlText, keywordList)); // includes string end
        }
        else
        {
            import std.array;
            auto paterns = std.array.array(toPaternRange(keywordList.values));
            return ResultToken(TokenType.other, getFront.Other(p_sqlText, paterns)); // includes string end
        }
    }


    @property auto empty()
    {
        return p_sqlText.length == 0;
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





/* Define couple of routines which extract specific content from the front of the string */
class getFront
{
    static string Spacing(in string input)
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


    static string Comment(in string input)
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
    static string Other(in string input, std.regex.Regex!(char)[] paterns)
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

        /* if no patern was matched, fallback solution - match any non-space sequence till word boundry */
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


    static string DelimitedString(in string input, in string delimStart, in string delimEnd)
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


    static string CommentOneline(in string input)
    {
        return getFront.DelimitedString(input, "--", "\n"); // TODO: handle different lineendings
    }


    static string CommentMultiline(in string input)
    {
        return getFront.DelimitedString(input, "/*", "*/");
    }
}



auto toPaternRange(Keyword[] kw_collection)
{
    import std.algorithm;
    alias std.algorithm.map map;
    alias std.algorithm.joiner joiner;

    auto paterns = map!"a.getPaterns()"(kw_collection); // <- range of ranges
    return joiner(paterns);                             // <- range
}
//std.algorithm.reduce!("a ~ b.text")("", resultTokens)




