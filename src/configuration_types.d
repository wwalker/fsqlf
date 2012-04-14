module configuration_types;
// define Spacing and Keyword structs

struct Spacing
{
    int newLines=0;
    int tabs=0;
    int spaces=0;
    string tab="    ";

    /* generate string which will be the output of this spacing configuration */
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
    string optionName;
    Spacing spacingBefore,spacingAfter;
    string textShort, textLong;
    bool mandatorySpacing;
    string regexStr;


    /* Set missing values to default value */
    auto initDefaults()
    {
        auto defaultValue = chooseDefaultValue();
        setIfEmpty(optionName, defaultValue);
        setIfEmpty(textShort,  defaultValue);
        setIfEmpty(textLong,   defaultValue);
        setIfEmpty(regexStr,   defaultValue);
        initRegex();
    }
    unittest
    {
        Keyword kw;
        kw.textLong = "SELECT";
        assert(kw.textShort == "");
        kw.initDefaults();
        assert(kw.textShort == "SELECT");
        /*assert(kw.match("SElECT 12345"));
        assert(!kw.match("SElECT12345"));
        assert(!kw.match("xSELECT"));
        */
    }


    /* Match */
    auto match(string txt)
    {
        assert(!this.patern.empty);
        return std.regex.match(txt , this.patern);
    }


 private:
    Regex!char patern;


    /* Set default value (at the moment it is this.textLong) for regex patern */
    auto initRegex()
    {
        if(this.patern.empty)
            if(regexStr != "")
                this.patern = std.regex.regex(`^` ~ regexStr,"i");
            else
                this.patern = std.regex.regex(`^` ~ this.textLong ~ `\b`,"i");
    }
    unittest
    {
        Keyword kw;
        kw.textLong = "SELECT";
        kw.initRegex();
        assert(kw.match("SELECT "));
        assert(kw.match("SElECT 12345"));
        assert(!kw.match("SElECT12345"));
        assert(!kw.match("xSELECT"));
        auto str = "xxSELECT";
        assert(kw.match(str[2..$]));
    }


    /* Choose default value for Keyword members */
    auto chooseDefaultValue()
    {
        assert(this.textShort != "" || this.textLong != "");
        if(this.textShort=="")
            return this.textLong;
        else
            return this.textShort;
    }


    /* Set value if it's not set yet */
    auto setIfEmpty(ref string member, in string value)
    {
        if(member == "") member = value;
    }
}
