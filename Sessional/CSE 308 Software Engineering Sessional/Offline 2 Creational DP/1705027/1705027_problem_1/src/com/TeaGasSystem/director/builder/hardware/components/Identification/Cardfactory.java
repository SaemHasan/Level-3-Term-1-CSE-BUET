package com.TeaGasSystem.director.builder.hardware.components.Identification;

public class Cardfactory {
    public Card getCard(String type){
        if(type.equalsIgnoreCase("RFID")){
            return new RFID(type);
        }
        else{
            return new NFC(type);
        }
    }
}
