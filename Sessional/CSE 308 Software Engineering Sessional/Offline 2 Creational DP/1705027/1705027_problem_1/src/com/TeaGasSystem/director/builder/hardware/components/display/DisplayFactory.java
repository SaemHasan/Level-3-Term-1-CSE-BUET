package com.TeaGasSystem.director.builder.hardware.components.display;

public class DisplayFactory {
    public Display getDisplay(String type){
        if(type.equalsIgnoreCase("touch screen")){
            return new Touch_Screen(type);
        }
        else if(type.equalsIgnoreCase("LED")){
            return new LED(type);
        }
        else{
            return new LCD(type);
        }

    }
}
