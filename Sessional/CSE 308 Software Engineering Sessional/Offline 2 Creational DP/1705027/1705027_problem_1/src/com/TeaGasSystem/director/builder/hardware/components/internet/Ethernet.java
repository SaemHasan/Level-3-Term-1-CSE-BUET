package com.TeaGasSystem.director.builder.hardware.components.internet;

public class Ethernet implements Internet{
    private String type;

    public Ethernet(String type) {
        this.type = type;
    }

    @Override
    public String getType() {
        return type;
    }
}
