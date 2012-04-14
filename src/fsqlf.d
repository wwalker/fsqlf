#!/usr/bin/rdmd

import configuration_types;
import keyword_conf;
import std.stdio;


void format_sql(Keyword[string] k, string input, File output=std.stdio.stdout)
{
    string input_text = read_input(input);
    auto tokens_separate = lex(input_text, k); // split text into words, puntation/space chars and comments
    auto keywords = combine(tokens_separate);  // recognise logical keywords like 'LEFT OUTER JOIN'; Also handle such cases as LEFT /*f */ JOIN
    auto kw_spaced = space_insert(keywords);   // insert spaces simply by looking at the keywords
    auto kw_formed = space_adjust(kw_spaced);  // adjust spacing by context
    auto text_formed = toString(kw_formed);    // convert inner structure to string
    write_output(text_formed, output);         // write to the output
}


auto read_input(in string input) { return input; }


auto lex(in string input, Keyword[string] keywordList)
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
        ++resultTokens.length;
        resultTokens[$-1] = r;
        start += resultTokens[$-1].length;
    } while (resultTokens[$-1].name != "EOF");

    import std.algorithm;
    return reduce!("a ~ b.toString")("", resultTokens);
}


auto combine(in string input) { return input; }


auto space_insert(in string input) { return input; }


auto space_adjust(in string input) { return input; }


auto toString(in string input) { return input; }


void write_output(in string txt, File output_stream) { output_stream.writefln(txt); }


void main()
{
    auto input = "SELECT 1 as x FROM gsd";
    writeln(" Input is:\n", input);
    writeln("\n Output is:");
    format_sql(keyword_conf.keywordList, input);
}
