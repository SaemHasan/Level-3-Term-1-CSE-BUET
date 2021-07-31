package com.TeaGasSystem.director.builder;

public interface Builder {
    void setMicrocontroller(String controller_name);
    void setWeightMeasure(String weightMeasure_name);
    void setIdentification(String card_name);
    void setStorage(String type);
    void setdisplay(String display_type);
    void setInternet_connection(String type);
    void setController(String type);
}
