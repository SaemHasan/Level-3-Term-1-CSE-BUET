package com.TeaGasSystem.director.builder.hardware.components.microcontroller;

public class MicroControllerFactory {
    public Microcontroller getMicroController(String type){
        if(type.equalsIgnoreCase("ATMega32")){
            return new ATMega32(type);
        }
        else if(type.equalsIgnoreCase("Arduino Mega")){
            return new Arduino_Mega(type);
        }
        else if(type.equalsIgnoreCase("Raspberry Pi")){
            return new Raspberry_Pi(type);
        }
        else{
            return null;
        }
    }
}
