package com.company.parser;

public class PythonParser implements Parser{
    String parserName;

    public PythonParser() {
        this.parserName = "Python Parser";
    }

    public String getParserName() {
        return parserName;
    }
}
