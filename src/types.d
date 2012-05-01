module types;
// define Spacing and Keyword structs

struct Spacing
{
    int newLines = 0;
    int tabs = 0;
    int spaces = 0;
    string tab = "    ";

    /* Generate string which will be the output of this spacing configuration */
    pure auto outputString()
    {
        string result="";
        for(int i=0 ; i < newLines ; i++) result ~= "\n";
        for(int i=0 ; i < tabs     ; i++) result ~= tab;
        for(int i=0 ; i < spaces   ; i++) result ~= " ";
        return result;
    }
    unittest
    {
        assert(Spacing(2,1,3).outputString() == "\n\n       ");
        assert(Spacing(1,1,1).outputString() == "\n     ");
        assert(Spacing(0,2,1).outputString() == "         ");
        assert(Spacing(0,0,0).outputString() == "");
    }
}


struct KeywordText
{
    import std.regex;

    string vLong;        // Long version (e.g. "LEFT OUTER JOIN")
    string vShort;       // Short version (e.g. "LEFT JOIN")
    Regex!(char) patern; // some keywords should be recognised using regex

    /* Describes what method to use during the matching */
    enum MatchMethod{ text, patern };
    MatchMethod matchMethod;

    this(string singleTextVersion)
    {
        this.vShort = singleTextVersion;
        this.vLong  = singleTextVersion;
        this.matchMethod = MatchMethod.text;
    }
    this(string textShort,string textLong)
    {
        this.vShort = textShort;
        this.vLong  = textLong;
        this.matchMethod = MatchMethod.text;
    }
    this(Regex!(char) patern, string text="")
    {
        this.patern = patern;
        this.matchMethod = MatchMethod.patern;
        this.vShort = text; // only for printing
        this.vLong  = text; // only for printing
    }

    /* Keywords may contain many words. Objective of the function is to match at least one word - prefferably longer */
    auto matchOneWord(string sqlText)
    {
        import std.algorithm:map;
        import std.array:split;
        auto paterns = std.algorithm.map!(std.regex.regex)(std.array.split(this.vLong));
        paterns     ~= std.algorithm.map!(std.regex.regex)(std.array.split(this.vShort));
    }
    
}

enum KeywordType { simple, composite };


struct Keyword
{
    import std.regex;
    string optionName;
    Spacing spacingBefore,spacingAfter;
    string textShort, textLong;
    bool mandatorySpacing;
    string regexStr;
    KeywordType keywordType;


    /* Set missing values to default value */
    auto initDefaults()
    {
        auto defaultValue = chooseDefaultValue();
        setIfEmpty(this.optionName, defaultValue);
        setIfEmpty(this.textShort,  defaultValue);
        setIfEmpty(this.textLong,   defaultValue);
        initRegex();
        initKeywordType();
    }
    unittest
    {
        Keyword kw;
        kw.textLong = "SELECT";
        kw.initDefaults();
        assert(kw.textShort == "SELECT");
    }


    /* Try recognise keywords tokens in the input text */
    auto matchTokens(string txt)
    {
        assert(this.patern.length != 0);

        std.regex.RegexMatch!string result;
        foreach( p ; this.patern)
        {
            assert(!p.empty);
            result = std.regex.match(txt , p);
            if(result) return result;
        }
        return result; // return no-match;
    }
    unittest
    {
        Keyword kw;
        kw.textLong = "SELECT";
        kw.textShort = "SEL";
        kw.initRegex();
        assert( kw.matchTokens("SElECT * FRO"));
        assert(!kw.matchTokens("SElECTECTOR "));
        assert(!kw.matchTokens("DESElECT"));
    }


    /* get longest possible word count, taking into account short and long versions */
    pure auto getLongestWordCount()
    {
        assert(Keyword.wordCount(this.textShort) <= Keyword.wordCount(this.textLong));
        switch(this.keywordType)
        {
            case KeywordType.simple: return 1;
            default:                 return Keyword.wordCount(this.textLong);
        }
    }


    auto matchedWordcount(string[] txt)
    {
//import std.stdio;
//writeln("in matchKeyword: this.keywordType=", this.keywordType);
        switch(this.keywordType)
        {
            case KeywordType.simple:
                return this.matchAgainstRegex(txt);
                break;
            case KeywordType.composite:
                return this.matchAgainstText(txt);
                break;
            default: assert(0);
        }
    }


private:
    Regex!(char)[] patern;


    /* Set default value (at the moment it is this.textLong) for regex patern */
    auto initRegex()
    {
        import std.array;
        if(this.patern.length == 0)
        {
            if(this.regexStr != "")
            {
                this.patern ~= std.regex.regex(`^` ~ this.regexStr,"i");
            }
            else
            {
                foreach( string word ; std.array.split(this.textLong))
                    this.patern ~= std.regex.regex(`^` ~ word ~ `\b`,"i");
                foreach( string word ; std.array.split(this.textShort))
                    this.patern ~= std.regex.regex(`^` ~ word ~ `\b`,"i");
            }
        }
    }


    auto initKeywordType()
    {
        assert(this.patern.length != 0);
        if(this.textShort == " " || this.textLong == " ") this.keywordType = KeywordType.simple;
        this.keywordType = this.patern.length == 1 ? KeywordType.simple : KeywordType.composite;
    }


    /* Choose default value for Keyword members */
    pure auto chooseDefaultValue()
    {
        assert(this.textShort != "" || this.textLong != "");
        if(this.textShort=="")
            return this.textLong;
        else
            return this.textShort;
    }


    /* Set value if it's not set yet */
    auto setIfEmpty(ref string member, in string value)
    {
        if(member == "") member = value;
    }


    /* Match token against predefined Keywrod's regex */
    auto matchAgainstRegex(string[] inputWord)
    {
        assert(this.keywordType == KeywordType.simple);
        assert(inputWord.length>0);
        return this.matchTokens(inputWord[0]) ? 1 : 0;
    }


    /* Match tokens against Keywrod's text */
    auto matchAgainstText(string[] inputWords)
    {
        assert(this.keywordType == KeywordType.composite);
import std.stdio;
//if(this.textShort == "LEFT JOIN") writeln(inputWords);

        import std.array;
        if(inputWords.length < Keyword.wordCount(this.textLong)
            && inputWords.length < Keyword.wordCount(this.textShort)) return 0;
        if(     matchAgainstKeywordText(inputWords, this.textLong )) return Keyword.wordCount(this.textLong);
        else if(matchAgainstKeywordText(inputWords, this.textShort)) return Keyword.wordCount(this.textShort);
        else return 0;
    }
    unittest
    {
        Keyword kw;
        kw.textLong  = "LEFT OUTER JOIN";
        kw.textShort = "LEFT JOIN";
        kw.initDefaults();
        assert( kw.matchAgainstText(["LeFT", "outer", "JOIN"]) );
        assert( kw.matchAgainstText(["LeFT", "JOIN", "table"]) );
        assert(!kw.matchAgainstText(["LeFT", "inner", "JOIN"]));
    }


    static auto matchAgainstKeywordText(string[] inputWords, string keywordText)
    {
        import std.array;

        if(inputWords.length < std.array.split(keywordText).length) return false;

        foreach(i, kwWord ; std.array.split(keywordText))
        {
            auto re = std.regex.regex("^" ~ kwWord ~ "$","i");
            auto matchResult = std.regex.match(inputWords[i], re);
            if(!matchResult) return false;
        }
        return true; // all words matched
    }
    unittest
    {
        assert( Keyword.matchAgainstKeywordText(["a","B","a"],"a b a"));
        assert( Keyword.matchAgainstKeywordText(["a","B","a"],"a b"));
        assert(!Keyword.matchAgainstKeywordText(["a","b"]    ,"a b a"));
        assert(!Keyword.matchAgainstKeywordText(["a","z","a"],"a b a"));
    }


    pure static auto wordCount(in string text)
    {
        import std.array;
        return std.array.split(text).length;
    }

}
