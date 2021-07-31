package com.company.environment;

import com.company.aesthetics.Aesthetics;
import com.company.aesthetics.PythonAesthetics;
import com.company.parser.Parser;
import com.company.parser.PythonParser;

public class PythonEnvironment implements Environment {
    @Override
    public Aesthetics getAesthetics() {
        return new PythonAesthetics();
    }

    @Override
    public Parser getParser() {
        return new PythonParser();
    }
}
