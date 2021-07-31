package com.TeaGasSystem.director.builder.hardware.components.microcontroller;

public class Raspberry_Pi implements Microcontroller {
    private String type;
    public Raspberry_Pi(String type) {
        this.type=type;
    }

    @Override
    public String getType() {
        return type;
    }
}
