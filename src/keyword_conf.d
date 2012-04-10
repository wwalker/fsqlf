module keyword_conf;

import configuration_types;

Keyword[string] k;
static this()
{
   alias Spacing S;
   alias Keyword K;
   k =
   [ //empty string "" means default value (same as 'name', for comand line spaces will  be converted to underscores)
     //keyword      ||  opt | -----spaces-------| ------text-------|  spacing  | regex
     //name         ||  name| before  | after   | short   | long   |  mandatory| string
       "comma"      : K("",   S(1,0,0), S(0,0,1), ","          , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"select"     : K("",   S(1,0,0), S(1,0,2), "SELECT"     , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"inner join" : K("",   S(1,0,0), S(0,0,1), "JOIN"       , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"left join"  : K("",   S(1,0,0), S(0,0,1), "LEFT JOIN"  , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"right join" : K("",   S(1,0,0), S(0,0,1), "RIGHT JOIN" , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"full join"  : K("",   S(1,0,0), S(0,0,1), "FULL JOIN"  , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"cross join" : K("",   S(1,0,0), S(0,0,1), "CROSS JOIN" , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"from"       : K("",   S(1,0,0), S(0,0,1), "FROM"       , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"on"         : K("",   S(1,0,1), S(0,0,1), "ON"         , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"where"      : K("",   S(1,0,0), S(0,0,1), "WHERE"      , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"and"        : K("",   S(1,0,0), S(0,0,1), "AND"        , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"or"         : K("",   S(1,0,0), S(0,0,1), "OR"         , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"exists"     : K("",   S(0,0,0), S(0,0,1), "exists"     , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"in"         : K("",   S(0,0,0), S(0,0,1), "in"         , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"as"         : K("",   S(0,0,1), S(0,0,1), "as"         , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"union all"  : K("",   S(2,1,0), S(1,0,0), "UNION ALL"  , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"union"      : K("",   S(2,1,0), S(1,0,0), "UNION"      , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"intersect"  : K("",   S(2,1,0), S(1,0,0), "INTERSECT"  , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"except"     : K("",   S(2,1,0), S(1,0,0), "EXCEPT"     , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"groupby"    : K("",   S(1,0,0), S(0,0,0), "GROUP BY"   , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"orderby"    : K("",   S(1,0,0), S(0,0,0), "ORDER BY"   , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"semicolon"  : K("",   S(1,0,0), S(1,0,0), ";"          , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"having"     : K("",   S(1,0,0), S(0,0,0), "HAVING"     , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"qualify"    : K("",   S(1,0,0), S(0,0,0), "QUALIFY"    , "",  true,      "") //NULL,NULL,NULL,NULL,NULL,NULL )
      ,"'('"          : K("",   S(0,0,0), S(0,0,0), "("          , "",  true,      "") //&debug_p,&inc_LEFTP ,NULL    ,NULL      ,NULL,NULL )
      ,"')'"          : K("",   S(0,0,0), S(0,0,0), ")"          , "",  true,      "") //&debug_p,&inc_RIGHTP,NULL    ,NULL      ,NULL,NULL )
      ,"subquery '('" : K("",   S(1,0,0), S(0,0,0), "("          , "",  true,      "") //&debug_p,&inc_LEFTP ,NULL    ,&begin_SUB,NULL,NULL )
      ,"subquery ')'" : K("",   S(1,0,0), S(1,0,0), ")"          , "",  true,      "") //&debug_p,&inc_RIGHTP,&end_SUB,NULL      ,NULL,NULL )
   ];

}



auto matchAll(string input, Keyword[string] kw_collection)
{
   foreach(Keyword k; kw_collection)
   {
      auto result = k.match(input);
      if(result) return result;
   }
   assert(0);
}