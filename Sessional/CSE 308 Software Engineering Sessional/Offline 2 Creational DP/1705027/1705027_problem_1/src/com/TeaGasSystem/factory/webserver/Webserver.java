package com.TeaGasSystem.factory.webserver;

public interface Webserver {

    public String getType();

    public void ReceiveIDcardData(String type);
    public void ReceiveWeightData(String type);
    public void SaveData(String type);
    public void AnalyzeData(String type);
}
