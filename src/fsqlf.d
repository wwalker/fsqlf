#!/usr/bin/rdmd

import types;
import higher_types;

import tokenizer;
import preprocessor;
import parser;

import dbg;
import std.stdio;


void main()
{
    auto input = "SELECT 1 FROM t1 LEFT JOIN t2";
    writeln("Input is");
    writeln(input,"\n");
    format_sql(keywordList, ignoredByParser, input);
}


version = not_old;


void format_sql(Keyword[string] k, Keyword[string] i, string input, File output=std.stdio.stdout)
{
    auto input_text  = read_input(input);

    auto tokenLazyRange = tokenizer.Tokenizer(input_text);
    dbg.print(tokenLazyRange);
    auto combTokens     = preprocessor.Preprocessor( tokenLazyRange );
    dbg.print(combTokens);
    auto keywords       = parser.Parser(combTokens);        // recognise logical keywords like 'LEFT OUTER JOIN'; Also handle such cases as LEFT /*f */ JOIN
    dbg.print(keywords);
    auto kw_spaced   = space_insert(keywords.toString);
    auto kw_formed   = space_adjust(kw_spaced); // adjust spacing by context
    auto text_formed = toString(kw_formed);     // convert inner structure to string
        //write_output(text_formed, output);          // write to the output

}


auto read_input(in string input) { return input; }
auto space_insert(in string input) { return input; }
auto space_adjust(in string input) { return input; }
auto toString(in string input) { return input; }
void write_output(in string txt, File output_stream) { output_stream.writefln(txt); }

