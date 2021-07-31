package com.TeaGasSystem.director.builder.hardware.components.controller;

public class Button implements Controller{
    private String type;
    public Button(String type) {
        this.type=type;
    }

    @Override
    public String getType() {
        return type;
    }
}
