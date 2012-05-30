module parser;

import preprocessor;
import higher_types;

struct ParserResult
{
    string[] p_leedingWhitespaces; // spaces,tabs,newlines
    string[] p_leedingComments;
    string p_Text;
    string p_Type;
    size_t p_WordCount;

    this(PreprocResult[] prep, string type="other", size_t wordCount=1)
    {
        import std.algorithm;
        import std.array;
        p_leedingWhitespaces = array(joiner(map!"a.p_leedingWhitespaces"(prep)));
        p_leedingComments    = array(joiner(map!"a.p_leedingComments"(prep)));
        p_Text      = cast(string) array(joiner(map!"a.p_tokenText"(prep)," ")); // FIXME - somehow remove cast. for some reason result of rside is of type dchar[]
        p_Type      = type;
        p_WordCount = wordCount;
    }
}



struct Parser
{
    Preprocessor p_preprocessedTokens;

    this(in Preprocessor prep, )
    {
        p_preprocessedTokens = prep;
    }

    auto front()
    {
        immutable auto MAX_WORDS=5;

        import std.algorithm;
        import std.range;

        alias higher_types.keywordList k;


        auto sqlTokens = array(take(map!"a.p_tokenText"(p_preprocessedTokens),MAX_WORDS));

        // loop to find match something
        foreach(kw ; k.values)
        {
            auto wordCount = kw.matchedWordcount(sqlTokens);
            if(wordCount > 0)
            {
                return ParserResult(array(take(p_preprocessedTokens,wordCount)), kw.kwName, wordCount);
            }
        }

        // if nothing matched then just take front token
        return ParserResult(array(take(p_preprocessedTokens,1)));
    }

    void popFront()
    {
        import std.array;
        auto cached_front = this.front();
        if(cached_front.p_Type != "other")
        {
            for(auto i = split(cached_front.p_Text).length ; i>0 ; --i) // pop for each matched word
            {
                p_preprocessedTokens.popFront();
            }
        }
        else
        {
            p_preprocessedTokens.popFront();
        }
    }

    @property
    bool empty()
    {
        return p_preprocessedTokens.empty();
    }


    string toString()
    {
        import std.algorithm;
        return std.algorithm.reduce!q{a~"("~b.p_Text~")"}("",this);
    }
}