module configuration_types;
// define Spacing and Keyword structs

struct Spacing
{
   int newLines=0;
   int tabs=0;
   int spaces=0;

   string tab="    ";
   pure auto outputString()
   {
      string result="";
      for(int i=0 ; i < newLines ; i++) result ~= "\n";
      for(int i=0 ; i < tabs     ; i++) result ~= tab;
      for(int i=0 ; i < spaces   ; i++) result ~= " ";
      return result;
   }

   unittest
   {
      assert(Spacing(2,1,3).outputString() == "\n\n       ");
      assert(Spacing(1,1,1).outputString() == "\n     ");
      assert(Spacing(0,2,1).outputString() == "         ");
      assert(Spacing(0,0,0).outputString() == "");
   }
}



struct Keyword
{
   import std.regex;
   string optionNameShort;
   Spacing spacingBefore,spacingAfter;
   string textShort, textLong;
   bool mandatorySpacing;
   string regexStr;

   auto initRegex(){ this.patern = regex("^" ~ this.textLong,"i"); }
   auto match(string txt){ return std.regex.match(txt , this.patern); }
   private:
   Regex!char patern;
}
