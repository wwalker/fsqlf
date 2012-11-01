#!/usr/bin/rdmd


static import dbg;
import std.stdio: File, writeln, stdout;


void main()
{

    auto input = "SELECT 1 FROM t1 LEFT JOIN t2";
    writeln( "Input is" );
    writeln( input,"\n" );
    format_sql( input );
}


void format_sql( string input, File output = stdout )
{
    auto input_text  = read_input( input );
    auto keywords = split_into_keywords( input_text );
    dbg.print( keywords );

    auto kw_spaced   = space_insert( keywords.toString );
    auto kw_formed   = space_adjust( kw_spaced ); // adjust spacing by context
    auto text_formed = toString( kw_formed );     // convert inner structure to string
        //write_output(text_formed, output);          // write to the output
}


auto split_into_keywords( string input_text )
{
    import lex.tokenizer;
    import lex.white_stuff_hider;
    import lex.multiword_keywords;

    auto tokens = Tokenizer( input_text );
    auto tokens_nonwhite = WhiteStuffHider( tokens );
    auto keywords = MultiwordKeywords( tokens_nonwhite );
    return keywords;
}


auto read_input(in string input) { return input; }
auto space_insert(in string input) { return input; }
auto space_adjust(in string input) { return input; }
auto toString(in string input) { return input; }
void write_output(in string txt, File output_stream) { output_stream.writefln(txt); }

