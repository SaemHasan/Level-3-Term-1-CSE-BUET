package com.company.aesthetics;

public class CAesthetics implements Aesthetics{
    private String font;
    private String style;
    private String color;

    public CAesthetics() {
        font = "Courier New";
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
