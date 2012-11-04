module ast.node;



interface Node
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