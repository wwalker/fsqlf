#!/usr/bin/rdmd

import types;
import higher_types;
import tokenizer;
import preprocessor;
import std.stdio;


void main()
{
    auto input = "SELECT 1 FROM t1 LEFT JOIN t2";
    writeln(" Input is:\n", input);
    writeln("\n Output is:");
    format_sql(keywordList, ignoredByParser, input);
}


void format_sql(Keyword[string] k, Keyword[string] i, string input, File output=std.stdio.stdout)
{
    auto input_text  = read_input(input);
    version(none)
    {
        auto tokens      = preprocess(input_text, k, i);   // split text into words, puntation/space chars and comments
        auto keywords    = parse(tokens, k);        // recognise logical keywords like 'LEFT OUTER JOIN'; Also handle such cases as LEFT /*f */ JOIN
    }
    else
    {
        auto tokenLazyRange = tokenizer.Tokenizer(input_text);
        auto combTokens = preprocessor.Preprocessor( std.array.array(tokenLazyRange) );
        auto combTokensString = std.algorithm.reduce!("a ~ \"(\" ~ b.p_tokenText ~ \")\"")("", combTokens);
        auto keywords    = parse(combTokensString, k);        // recognise logical keywords like 'LEFT OUTER JOIN'; Also handle such cases as LEFT /*f */ JOIN
    }
    auto kw_spaced   = space_insert(keywords);  // insert spaces simply by looking at the keywords
    auto kw_formed   = space_adjust(kw_spaced); // adjust spacing by context
    auto text_formed = toString(kw_formed);     // convert inner structure to string
    write_output(text_formed, output);          // write to the output
}


auto read_input(in string input) { return input; }


version(none)
{
    ref auto preprocess(in string input, Keyword[string] keywordList, Keyword[string] ignoredByParser)
    {
        auto start = 0;
        Token!string[] resultTokens;
        do
        {
            auto r = getFrontToken(input[start..$], keywordList, ignoredByParser);
            debug(lex)
            {
                import std.stdio;
                writeln(r.toString, " - ", input[start..$]);
            }
            resultTokens ~= r;
            start += resultTokens[$-1].length;
        } while (resultTokens[$-1].name != "EOF");

        debug(lex)
        {
            import std.stdio:writeln;
            import std.algorithm:reduce;
            writeln("- debug lex start");
            writeln( std.algorithm.reduce!("a ~ b.text")("", resultTokens) );
            writeln("- debug lex end");
        }

        return resultTokens;
    }


    auto parse(Token!string[] input, Keyword[string] keywordList)
    {
        Token!string[] resultKeywords;
        for(auto i=0 ; i < input.length - 1 ; i++) // i<length-1 ; because EOF is not keyword
        {
            import std.stdio;
            //writeln(resultKeywords );
            resultKeywords ~= getFrontKeyword(input[i..$], keywordList);
        }
        import std.algorithm;
        return std.algorithm.reduce!("a ~ \"(\" ~ b.text ~ \")\"")("", resultKeywords);
        //return input;
    }
}
else
{
    auto parse(string input, Keyword[string] keywordList)
    {   return input;    }
}


auto space_insert(in string input) { return input; }


auto space_adjust(in string input) { return input; }


auto toString(in string input) { return input; }


void write_output(in string txt, File output_stream) { output_stream.writefln(txt); }
