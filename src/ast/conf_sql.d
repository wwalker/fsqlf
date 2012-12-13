/* SQL-Specific configurations of nodes */
module ast.conf_sql;


import ast.conf;


enum sql_node_types  = [
     //subtreeConf( ["SELECT"], [","], ["FROM", ")", "UNION", "SELECT" ], End.exclusive )
     SubtreeConf!(string)( ["SELECT"], [","], ["FROM", ")", "UNION" ], End.exclusive )
    ,SubtreeConf!(string)( ["("], [",", "UNION"], [")"], End.inclusive )
    ,SubtreeConf!(string)( ["FROM"], [",", "JOIN"], [")" , "UNION", "SELECT"], End.exclusive )
];
