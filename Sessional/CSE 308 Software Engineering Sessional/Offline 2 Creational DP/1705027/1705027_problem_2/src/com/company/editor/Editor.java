package com.company.editor;

import com.company.aesthetics.Aesthetics;
import com.company.environment.Environment;
import com.company.parser.Parser;

public class Editor {

    private static Editor instance;
    private static String className;
    private Aesthetics aesthetics;
    private Parser parser;

    private Editor(Environment environment){
        aesthetics = environment.getAesthetics();
        parser = environment.getParser();
        className="";
    }

    public static Editor getInstance(Environment environment){
        if(instance==null || className!=environment.getClass().getName()){
            className=environment.getClass().getName();
            instance= new Editor(environment);
        }
        return instance;
    }

    public void SeeDetails(){
        System.out.println("\nParser : "+parser.getParserName());
        System.out.println("Font Name : "+ aesthetics.getFont());
        System.out.println("Style : "+aesthetics.getStyle());
        System.out.println("Color : "+aesthetics.getColor()+"\n");
    }

}
