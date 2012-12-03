module ast.sql_subtrees;

import ast.subtree_conf;


SubtreeConf selectConfiguration(in_element text)
{

    foreach( iConf; sql_node_types)
    {
        if( iConf.isStart(text) ) return iConf;
    }
    return SubtreeConf.NONE;

}


enum sql_node_types  = [
     //subtreeConf( ["SELECT"], [","], ["FROM", ")", "UNION", "SELECT" ], End.exclusive )
     SubtreeConf( ["SELECT"], [","], ["FROM", ")", "UNION" ], End.exclusive )
    ,SubtreeConf( ["("], [",", "UNION"], [")"], End.inclusive )
    ,SubtreeConf( ["FROM"], [",", "JOIN"], [")" , "UNION", "SELECT"], End.exclusive )
];
