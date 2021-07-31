package com.company.parser;

public class CppParser implements Parser{
    String parserName;

    public CppParser() {
        this.parserName = "Cpp parser";
    }

    public String getParserName() {
        return parserName;
    }
}
