/* Interface of abstract-syntax-tree node */
module ast.node;


interface Node( KeywordRange )
{
    string toStringIndented( int indentation_level );
    @property bool empty();
    void clear();

    final string toString()
    {
        return this.toStringIndented( 1 );
    }
}


string indent( int indentation_level )
{
    string result_indentation = "";
    immutable string tab = "  ";
    while( result_indentation.length < indentation_level * tab.length )
    {
        result_indentation ~= tab;
    }
    return result_indentation;
}

/*
Section starts (can end other sections)

Group-A - Contains list of one or more items separated by separators:
 SELECT, FROM, WHERE, GROUP BY, ORDER BY, QUALIFY

Group-B - Contains single item:
 UPDATE, INSERT INTO, DELETE FROM, SAMPLE

Paranthesis can contain
 paranthesis, comma separated list, join separated list, select statement, nothing

class Select : ChildOfParanthised
class Column : ChildOfSelect
class Paranthised : ChildOfColumn, ChildOfParanthised, ChildOfCase
class Case : ChildOfColumn, ChildOfParanthised, ChildOfCase
*/
