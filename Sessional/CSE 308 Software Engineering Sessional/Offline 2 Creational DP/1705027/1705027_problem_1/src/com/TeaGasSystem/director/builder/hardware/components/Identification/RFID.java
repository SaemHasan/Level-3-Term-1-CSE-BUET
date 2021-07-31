package com.TeaGasSystem.director.builder.hardware.components.Identification;

public class RFID implements Card{
    private String type;

    public RFID(String type) {
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
