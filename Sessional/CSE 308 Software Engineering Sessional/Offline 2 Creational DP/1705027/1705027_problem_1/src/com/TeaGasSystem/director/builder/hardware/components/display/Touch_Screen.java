package com.TeaGasSystem.director.builder.hardware.components.display;

public class Touch_Screen implements Display{
    private String type;

    public Touch_Screen(String type) {
        this.type = type;
    }

    @Override
    public String getType() {
        return type;
    }
}