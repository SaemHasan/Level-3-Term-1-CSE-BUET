package com.TeaGasSystem.director.builder.hardware.components.display;

public class LED implements Display{
    private String type;

    public LED(String type) {
        this.type = type;
    }

    @Override
    public String getType() {
        return type;
    }
}