package com.TeaGasSystem.director.builder.hardware.components.microcontroller;

public class ATMega32 implements Microcontroller {
    private String type;
    public ATMega32(String type) {
        this.type=type;
    }

    @Override
    public String getType() {
        return type;
    }
}
