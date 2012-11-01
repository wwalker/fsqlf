/* Module for recognising multiword keywords (e.g. "LEFT OUTER JOIN") */
module lex.multiword_keywords;



import lex.white_stuff_hider;
import higher_types;





/* Element of MultiwordKeywords - logical keyword (could be made of many words e.g. LEFT JOIN) */
struct Result
{
private:
public:
    string[] p_leedingWhitespaces; // spaces,tabs,newlines
    string[] p_leedingComments;
    string p_Text;
    string p_Type;


public:
    @property
    string Text()
    {
        return p_Text;
    }

    /* Construct from preprocessed content and name of the keyword */
    this(lex.white_stuff_hider.Result[] prep, string kwName="other")
    {
        import std.algorithm;
        import std.array;
        p_leedingWhitespaces = array(joiner(map!"a.leedingWhitespaces"(prep)));
        p_leedingComments    = array(joiner(map!"a.leedingComments"(prep)));
        p_Text      = reduce!q{a~=" "~b}(map!q{a.tokenText}(prep));
        p_Type      = kwName;
    }

    /* Equality test against string */
    pure auto opEquals(string text)
    {
        return p_Text == text;
    }
}





/* InputRange constructed from preprocessed tokens and returning recognized multiword keywords.
   e.g. if constructed from "(LEFT)(JOIN)" returns "(LEFT JOIN)". Also returned structure contains keyword name */
struct MultiwordKeywords
{
private:
    WhiteStuffHider p_preprocessedTokens;
public:
    /* Construct from preprocessed content */
    this(in WhiteStuffHider prep )
    {
        p_preprocessedTokens = prep;
    }

    /* Return multiword keyword found at the front of preprocessed content */
    auto front()
    {
        immutable auto MAX_WORDS=3; // Longest SQL keywords are joins made of 3 words (e.g. "LEFT OUTER JOIN").

        import std.algorithm;
        import std.range;

        alias higher_types.keywordList k;


        auto sqlTokens = array(take(map!"a.tokenText"(p_preprocessedTokens),MAX_WORDS));

        /* Find keyword which matches something from the front of the input */
        foreach(kw ; k.values)
        {
            auto wordCount = kw.matchedWordcount(sqlTokens);
            if(wordCount > 0)
            {
                return Result(array(take(p_preprocessedTokens,wordCount)), kw.kwName);
            }
        }

        // If nothing matched then just take 1 front token
        return Result(array(take(p_preprocessedTokens,1)));
    }


    /* Drop content used for result of front(), so next call to front() would return new multiword keyword */
    void popFront()
    {
        import std.array;
        auto cached_front = this.front();
        if(cached_front.p_Type != "other")
        {
            for(auto i = split(cached_front.Text).length ; i>0 ; --i) // pop for each matched word
            {
                p_preprocessedTokens.popFront();
            }
        }
        else
        {
            p_preprocessedTokens.popFront();
        }
    }


    /* Return TRUE if no more elements can be returned (end of input was reached) */
    @property
    bool empty()
    {
        return p_preprocessedTokens.empty();
    }


    /*  Convert Tokenizer to string. At the moment for debuging purposes */
    string toString()
    {
        import std.algorithm;
        return std.algorithm.reduce!q{a~"("~b.Text~")"}("",this);
    }
}
unittest
{
    import std.range;
    import lex.tokenizer;
    static assert(isInputRange!MultiwordKeywords);
    auto c = WhiteStuffHider(Tokenizer("SELECT /**/ FROM 1 --"));
    assert(c.front() == "SELECT");
    assert(c.front() != "SELECTS");
    c.popFront();
    assert(c.front() == "FROM");
    c.popFront();
    assert(c.front() == "1");
    c.popFront();
    assert(c.front() == "");
    c.popFront();
    assert(c.empty);
}
