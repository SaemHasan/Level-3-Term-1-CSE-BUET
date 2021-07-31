package com.TeaGasSystem.factory.webserver;

public class Laravel implements Webserver {
    private String type;
    public Laravel(String type) {
        this.type=type;
    }

    @Override
    public String getType() {
        return type;
    }

    @Override
    public void ReceiveIDcardData(String type) {
        System.out.println("\nReceived "+type+" card data in the webserver developed by "+getType());
        System.out.println("Card Verification Complete\n");
    }

    @Override
    public void ReceiveWeightData(String type) {
        System.out.println("\nReceived Weight data of the load from "+type+" in the webserver developed by "+getType()+"\n");
    }

    @Override
    public void SaveData(String type) {
        System.out.println("\nSaving data in the "+type+"\n");
    }

    @Override
    public void AnalyzeData(String type) {
        System.out.println("\nScanning Data from "+type+" and Analyzing it in the webserver developed by "+getType()+"\n");
    }
}
