package com.TeaGasSystem.director;

import com.TeaGasSystem.director.builder.Builder;

public class Director {
    public void constructSilverPackage(Builder builder,String connectionType){
        builder.setMicrocontroller("ATMega32");
        builder.setWeightMeasure("load sensor");
        builder.setIdentification("RFID");
        builder.setStorage("SD card");
        builder.setdisplay("LCD");
        builder.setInternet_connection(connectionType);
        builder.setController("Button");

    }

    public void constructGoldPackage(Builder builder, String connectionType){
        builder.setMicrocontroller("Arduino Mega");
        builder.setWeightMeasure("weight module");
        builder.setIdentification("RFID");
        builder.setStorage("SD card");
        builder.setdisplay("LED");
        builder.setInternet_connection(connectionType);
        builder.setController("Button");
    }

    public void constructDiamondPackage(Builder builder, String connectionType){
        builder.setMicrocontroller("Raspberry Pi");
        builder.setWeightMeasure("load sensor");
        builder.setIdentification("NFC");
        builder.setStorage("Built in storage");
        builder.setdisplay("Touch screen");
        builder.setInternet_connection(connectionType);
        builder.setController("Touch Screen");
    }

    public void constructPlatinumPackage(Builder builder, String connectionType){
        builder.setMicrocontroller("Raspberry Pi");
        builder.setWeightMeasure("weight module");
        builder.setIdentification("NFC");
        builder.setStorage("Built in storage");
        builder.setdisplay("Touch screen");
        builder.setInternet_connection(connectionType);
        builder.setController("Touch Screen");
    }
}
