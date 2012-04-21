#!/usr/bin/rdmd

import types;
import higher_types;
import std.stdio;


void main()
{
    auto input = "SELECT 1 FROM t1 LEFT JOIN t2";
    writeln(" Input is:\n", input);
    writeln("\n Output is:");
    format_sql(keywordList, input);
}


void format_sql(Keyword[string] k, string input, File output=std.stdio.stdout)
{
    auto input_text  = read_input(input);
    auto tokens      = lex(input_text, k);      // split text into words, puntation/space chars and comments
    auto keywords    = parse(tokens, k);        // recognise logical keywords like 'LEFT OUTER JOIN'; Also handle such cases as LEFT /*f */ JOIN
    auto kw_spaced   = space_insert(keywords);  // insert spaces simply by looking at the keywords
    auto kw_formed   = space_adjust(kw_spaced); // adjust spacing by context
    auto text_formed = toString(kw_formed);     // convert inner structure to string
    write_output(text_formed, output);          // write to the output
}


auto read_input(in string input) { return input; }


ref auto lex(in string input, Keyword[string] keywordList)
{
    auto start = 0;
    Token[] resultTokens;
    do
    {
        auto r = getFrontToken(input[start..$], keywordList);
        debug(lex)
        {
            import std.stdio;
            writeln(r.toString, " - ", input[start..$]);
        }
        resultTokens ~= r;
        start += resultTokens[$-1].length;
    } while (resultTokens[$-1].name != "EOF");

    return resultTokens;
}


auto parse(Token[] input, Keyword[string] keywordList)
{
    Token[] resultKeywords;
    for(auto i=0 ; i < input.length - 1 ; i++) // i<length-1 ; because EOF is not keyword
    {
        import std.stdio;
        //writeln(resultKeywords );
        resultKeywords ~= getFrontKeyword(input[i..$], keywordList);
    }
    import std.algorithm;
    return std.algorithm.reduce!("a ~ b.toString")("", resultKeywords);
    //return input;
}


auto space_insert(in string input) { return input; }


auto space_adjust(in string input) { return input; }


auto toString(in string input) { return input; }


void write_output(in string txt, File output_stream) { output_stream.writefln(txt); }
