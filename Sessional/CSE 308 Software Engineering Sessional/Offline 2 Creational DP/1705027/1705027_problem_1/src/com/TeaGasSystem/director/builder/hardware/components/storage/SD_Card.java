package com.TeaGasSystem.director.builder.hardware.components.storage;

public class SD_Card implements Storage{
    private String type;
    public SD_Card(String type) {
        this.type=type;
    }

    @Override
    public String getType() {
        return type;
    }
}
