/* Module Goal is to separate:
 *  - white-stuff tokens (comments and spacing)
 *  - graphical tokens (words, special characters)
 */
module lex.white_stuff_hider;


import higher_types;
import lex.tokenizer;





/* Element of WhiteStuffHider.  White-Stuff (comments&whitespaces) is attached to "real" tokens */
struct Result
{
private:
    string[] p_leedingWhitespaces; // spaces,tabs,newlines
    string[] p_leedingComments;
    string p_tokenText;


public:
    /* Getter for leeding whitespaces */
    @property
    auto leedingWhitespaces() {return p_leedingWhitespaces;}


    /* Getter for leeding comments */
    @property
    auto leedingComments()    {return p_leedingComments;}


    /* Getter for token text */
    @property
    auto tokenText()          {return p_tokenText;}


    /* Setter for tokens.  It recognizes token type and puts its text into appropriate member */
    void addDispatchToken(Token!TokenType token)
    {
        import std.stdio;
        switch(token.name)
        {
            case TokenType.spacing:
                p_leedingWhitespaces ~= token.text;
                break;
            case TokenType.comment:
                p_leedingComments ~= token.text;
                break;
            case TokenType.other:
                p_tokenText = token.text;
                break;
            default: assert(0);
        }
    }


    /* Return lenght of the element mesured in number of Tokens used to create it */
    @property auto length()
    {
         return p_leedingWhitespaces.length + p_leedingComments.length + (p_tokenText.length>0?1:0);
    }


    /* Equality test against string */
    pure auto opEquals(string text)
    {
        return p_tokenText == text;
    }
}





/* InputRange contructed from tokens and returning organized/grouped tokens, where spacing and comments are attached to "functional" tokens.
   Spacing, Comments are called "non-functional" part of SQL as they don't influence result of the query
   e.g. if constructed from tokens "(SELECT)( )(1)( )(--xx)", it will return "(SELECT)(1)()", where
   "(1)" will contain its leeding space, and "()" will contain its leeding space and comment */
struct WhiteStuffHider
{
import std.range;
private:
    Tokenizer p_sqlTokens;


public:
    /* Constructor from range of Tokens */
    this(Tokenizer sqlTokens)
    {
        p_sqlTokens = sqlTokens;
    }


    /* Get organized/grouped tokens, consisting of  leeding spacing&comments  and  "functional" text */
    Result front()
    {
        Result result;
        foreach(token ; p_sqlTokens)
        {
            result.addDispatchToken(token);
            if(isFunctional(token))
            {
                break;
            }
        }
        return result;
    }


    /* Drop content used for result of front(), so next call to front() would return next organized group of tokens */
    void popFront()
    {
        import std.range;
        if(this.empty) assert(false);
        p_sqlTokens = std.range.drop(p_sqlTokens, this.front().length);
    }


    /* Return TRUE if no more elements can be returned (end of input was reached) */
    @property auto empty()
    {
        return p_sqlTokens.empty;
    }


    /* Convert range to string. At the moment for debuging purposes */
    string toString()
    {
        import std.algorithm;
        return std.algorithm.reduce!q{a~"("~b.tokenText~")"}("",this);
    }
}
unittest
{
    import std.range;

    static assert(isInputRange!WhiteStuffHider);
    auto c = WhiteStuffHider(Tokenizer("SELECT /**/ FROM 1 --"));
    assert(c.front() == "SELECT");
    c.popFront();
    assert(c.front() == "FROM");
    c.popFront();
    assert(c.front() == "1");
    c.popFront();
    assert(c.front() == "");
    c.popFront();
    assert(c.empty);
}





private:
/* Return TRUE if token is "functional" - neither spacing nor comment */
bool isFunctional (Token!TokenType token)
{
    return token.name == TokenType.other;
}
