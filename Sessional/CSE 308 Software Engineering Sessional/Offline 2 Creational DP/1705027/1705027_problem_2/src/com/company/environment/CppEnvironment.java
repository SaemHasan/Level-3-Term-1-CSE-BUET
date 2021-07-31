package com.company.environment;

import com.company.aesthetics.Aesthetics;
import com.company.aesthetics.CppAesthetics;
import com.company.parser.CppParser;
import com.company.parser.Parser;

public class CppEnvironment implements Environment {
    @Override
    public Aesthetics getAesthetics() {
        return new CppAesthetics();
    }

    @Override
    public Parser getParser() {
        return new CppParser();
    }
}
