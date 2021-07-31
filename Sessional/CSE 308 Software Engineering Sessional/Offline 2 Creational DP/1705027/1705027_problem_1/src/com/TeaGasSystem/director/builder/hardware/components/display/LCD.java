package com.TeaGasSystem.director.builder.hardware.components.display;

public class LCD implements Display{
    private String type;

    public LCD(String type) {
        this.type = type;
    }

    @Override
    public String getType() {
        return type;
    }
}
