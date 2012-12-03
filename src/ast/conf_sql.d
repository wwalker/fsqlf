module ast.conf_sql;


import ast.conf;


enum sql_node_types  = [
     //subtreeConf( ["SELECT"], [","], ["FROM", ")", "UNION", "SELECT" ], End.exclusive )
     SubtreeConf( ["SELECT"], [","], ["FROM", ")", "UNION" ], End.exclusive )
    ,SubtreeConf( ["("], [",", "UNION"], [")"], End.inclusive )
    ,SubtreeConf( ["FROM"], [",", "JOIN"], [")" , "UNION", "SELECT"], End.exclusive )
];
