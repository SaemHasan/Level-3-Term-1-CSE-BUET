package com.company.aesthetics;

public class CppAesthetics implements Aesthetics{
    private String font;
    private String style;
    private String color;

    public CppAesthetics() {
        font = "Monaco";
        style = "Normal";
        color = "Blue";
    }

    public String getFont() {
        return font;
    }

    public String getStyle() {
        return style;
    }

    public String getColor() {
        return color;
    }
}
