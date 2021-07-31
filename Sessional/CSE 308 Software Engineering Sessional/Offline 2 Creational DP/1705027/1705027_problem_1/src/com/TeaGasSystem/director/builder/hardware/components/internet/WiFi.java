package com.TeaGasSystem.director.builder.hardware.components.internet;

public class WiFi implements Internet{
    private String type;

    public WiFi(String type) {
        this.type = type;
    }

    @Override
    public String getType() {
        return type;
    }
}
