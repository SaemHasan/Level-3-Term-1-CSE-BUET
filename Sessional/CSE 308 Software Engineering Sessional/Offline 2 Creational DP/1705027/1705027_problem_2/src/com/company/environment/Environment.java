package com.company.environment;

import com.company.aesthetics.Aesthetics;
import com.company.parser.Parser;

public interface Environment {
    Aesthetics getAesthetics();
    Parser getParser();
}
