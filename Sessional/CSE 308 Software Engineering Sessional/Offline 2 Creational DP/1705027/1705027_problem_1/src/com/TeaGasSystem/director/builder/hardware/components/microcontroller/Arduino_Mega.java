package com.TeaGasSystem.director.builder.hardware.components.microcontroller;

public class Arduino_Mega implements Microcontroller {
    private String type;

    public Arduino_Mega(String type) {
        this.type = type;
    }

    @Override
    public String getType() {
        return type;
    }
}
