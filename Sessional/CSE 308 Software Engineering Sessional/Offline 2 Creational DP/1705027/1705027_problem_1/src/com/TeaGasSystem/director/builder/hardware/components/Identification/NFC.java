package com.TeaGasSystem.director.builder.hardware.components.Identification;

public class NFC implements Card{
    private String type;
    public NFC(String type) {
        this.type=type;
    }

    @Override
    public String getType() {
        return type;
    }

    @Override
    public void Scan() {
        System.out.println("Scaning "+getType()+" card");
    }
}
