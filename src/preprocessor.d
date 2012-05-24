module preprocessor;

import higher_types;
import tokenizer;


bool isSpacing(Token!TokenType token) { return token.name == TokenType.spacing; }
bool isComment(Token!TokenType token) { return token.name == TokenType.comment; }
bool isOther  (Token!TokenType token) { return token.name == TokenType.other;   }


struct PreprocResult
{
    string[] p_leedingWhitespaces; // spaces,tabs,newlines
    string[] p_leedingComments;
    string p_tokenText;


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


    @property auto length()
    {
         return p_leedingWhitespaces.length + p_leedingComments.length + (p_tokenText.length>0?1:0);
    }


    pure auto opEquals(string text)
    {
        return p_tokenText == text;
    }
}



import std.range;
struct Preprocessor
{
    Token!TokenType[] p_sqlTokens;


    this(Token!TokenType[] sqlTokens)
    {
        p_sqlTokens = sqlTokens;
    }


    PreprocResult front()
    {
        PreprocResult result;
        foreach(token_ix, token ; p_sqlTokens)
        {
            result.addDispatchToken(token);
            if(isOther(token))
            {
                break;
            }
        }
        return result;
    }


    void popFront()
    {
        import std.range;
        if(this.empty) assert(false);
        p_sqlTokens = std.range.drop(p_sqlTokens, this.front().length);
    }


    @property auto empty()
    {
        return p_sqlTokens.length == 0;
    }
}
unittest
{
    import std.range;

    static assert(isInputRange!Preprocessor);
    auto t = tokenizer.Tokenizer("SELECT /**/ FROM 1 --");
    Token!TokenType[] tokens = std.array.array(t);
    auto c = Preprocessor(tokens);

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