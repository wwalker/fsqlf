/* Decide what configuration should be used */
module ast.conf_select;


import ast.conf;
import ast.conf_sql;


SubtreeConf selectConfiguration(in_element text)
{

    foreach( iConf; sql_node_types)
    {
        if( iConf.isStart(text) ) return iConf;
    }
    return SubtreeConf.NONE;

}


