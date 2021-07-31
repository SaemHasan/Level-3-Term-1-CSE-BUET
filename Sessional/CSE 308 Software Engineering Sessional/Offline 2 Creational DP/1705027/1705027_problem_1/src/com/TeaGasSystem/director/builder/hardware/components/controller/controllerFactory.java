package com.TeaGasSystem.director.builder.hardware.components.controller;

public class controllerFactory {
    public Controller getController(String type){
        if(type.equalsIgnoreCase("BUTTON")){
            return new Button(type);
        }
        else{
            return new Touch_Screen(type);
        }
    }
}
