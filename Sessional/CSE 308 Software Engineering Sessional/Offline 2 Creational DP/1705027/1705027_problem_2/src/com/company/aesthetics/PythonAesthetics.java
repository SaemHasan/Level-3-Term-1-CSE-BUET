package com.company.aesthetics;

public class PythonAesthetics implements Aesthetics{
    private String font;
    private String style;
    private String color;

    public PythonAesthetics() {
        font = "Consolas";
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
