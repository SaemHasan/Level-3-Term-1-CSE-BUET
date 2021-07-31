package com.TeaGasSystem.System;

import com.TeaGasSystem.director.DirectorControl;
import com.TeaGasSystem.director.builder.HardwareBuilder;
import com.TeaGasSystem.director.builder.hardware.Hardware;
import com.TeaGasSystem.director.builder.hardware.components.storage.Storage;
import com.TeaGasSystem.factory.Factory;
import com.TeaGasSystem.factory.webserver.Webserver;

import java.util.ArrayList;
import java.util.List;

public class Administrator {
    private Hardware hardware;
    private Webserver webserver;
    private String Packagename;
    private String connectionChoice;
    private String frameWorkName;
    private List<String> collectors = new ArrayList<>();

    public Administrator(String Packagename, String connectionChoice, String frameWorkName) {
        this.Packagename = Packagename;
        this.connectionChoice = connectionChoice;
        this.frameWorkName = frameWorkName;

        DirectorControl directorControl = new DirectorControl(Packagename,connectionChoice);

        HardwareBuilder builder = new HardwareBuilder();

        directorControl.BuildObject(builder);

        hardware = builder.getHardwareObject();

        Factory factory = new Factory();
        webserver = factory.getFrameWork(frameWorkName);
        System.out.println("\n\nHardware created with "+Packagename+" package");
        System.out.println("Webserver is developed using "+frameWorkName+" framework\n\n");
    }

    public void AddCollector(String Name){
        if(collectors.contains(Name)){
            System.out.println("\n"+Name+" already is a leaf collector\n");
        }
        else{
            collectors.add(Name);
            System.out.println("\n"+Name+" added successfully\n");
        }
    }

    public void RemoveCollector(String name){
        if(collectors.contains(name)){
            collectors.remove(name);
            System.out.println("\n"+name+" removed from leaf collector list.\n");
        }
        else{
            System.out.println("\n"+name+" is not in the leaf collector list\n");
        }
    }

    public boolean SearchCollector(String Name){
        if(collectors.contains(Name)) return true;
        else return false;
    }

    public void ScanIDcard(){
        hardware.getCard().Scan();
        webserver.ReceiveIDcardData(hardware.getCard().getType());
    }

    public void WeightLoad(){
        hardware.getWeightMeasure().measureweight();
        webserver.ReceiveWeightData(hardware.getWeightMeasure().getType());
    }

    public void BackupData(){
        String type;
        Storage storage= hardware.getStorage();
        if(storage==null) type= "Default storage";
        else type=storage.getType();

        webserver.SaveData(type);
    }

    public void AnalyzeData(){
        String type;
        Storage storage= hardware.getStorage();
        if(storage==null) type= "Default storage";
        else type=storage.getType();

        webserver.AnalyzeData(type);
    }

    public void PrintHardwareInfo(){
        String type;
        Storage storage= hardware.getStorage();
        if(storage==null) type= "Default storage";
        else type=storage.getType();

        System.out.println("\n\nMicro-controller: "+hardware.getMicroController().getType());
        System.out.println("Weight Measurement: "+hardware.getWeightMeasure().getType());
        System.out.println("Identification card: "+hardware.getCard().getType());
        System.out.println("Storage: "+type);
        System.out.println("Display: "+hardware.getDisplay().getType());
        System.out.println("Internet Connection: "+hardware.getInternet().getType());
        System.out.println("Controller : "+hardware.getController().getType()+"\n\n");

    }

    public void PrintWebserverInfo(){
        System.out.println("\nWebserver is developed using "+webserver.getType()+" framework\n");
    }




}
