package com.TeaGasSystem.director.builder.hardware.components.storage;

public class StorageFactory {
    public Storage getStorage(String type){
        if(type.equalsIgnoreCase("SD CARD")){
            return new SD_Card(type);
        }
        else{
            return null;
        }
    }
}
