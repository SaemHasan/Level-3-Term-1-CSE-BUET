package com.TeaGasSystem.director.builder.hardware.components.controller;

public class Touch_Screen implements Controller{
    private String type;
    public Touch_Screen(String type) {
        this.type=type;
    }

    @Override
    public String getType() {
        return type;
    }
}