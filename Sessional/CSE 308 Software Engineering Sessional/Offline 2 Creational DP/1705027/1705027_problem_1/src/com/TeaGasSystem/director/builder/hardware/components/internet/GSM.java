package com.TeaGasSystem.director.builder.hardware.components.internet;

public class GSM implements Internet{
    private String type;

    public GSM(String type) {
        this.type = type;
    }

    @Override
    public String getType() {
        return type;
    }
}
