package com.TeaGasSystem.director.builder.hardware.components.internet;

public class InternetFactory {
    public Internet getInternet(String type){
        if(type.equalsIgnoreCase("GSM")){
            return new GSM(type);
        }
        else if(type.equalsIgnoreCase("Wifi")){
            return new WiFi(type);
        }
        else {
            return new Ethernet(type);
        }
    }
}
