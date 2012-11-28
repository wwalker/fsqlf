module ast.sql_subtrees;

import ast.subtree_conf;


subtreeConf selectConfiguration(in_element text)
{

    foreach( iConf; sql_node_types)
    {
        if( iConf.isStart(text) ) return iConf;
    }
    return subtreeConf.NONE;

}


enum sql_node_types  = [
     subtreeConf( ["SELECT"], [","], ["FROM", ")", "UNION", "SELECT" ], End.exclusive )
    ,subtreeConf( ["("], [",", "UNION"], [")"], End.inclusive )
    ,subtreeConf( ["FROM"], [",", "JOIN"], [")" , "UNION", "SELECT"], End.exclusive )
];
