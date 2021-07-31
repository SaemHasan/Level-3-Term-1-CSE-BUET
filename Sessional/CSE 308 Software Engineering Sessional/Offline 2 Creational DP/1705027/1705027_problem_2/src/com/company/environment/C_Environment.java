package com.company.environment;

import com.company.aesthetics.Aesthetics;
import com.company.aesthetics.CAesthetics;
import com.company.parser.Cparser;
import com.company.parser.Parser;

public class C_Environment implements Environment {

    @Override
    public Aesthetics getAesthetics() {
        return new CAesthetics();
    }

    @Override
    public Parser getParser() {
        return new Cparser();
    }
}
