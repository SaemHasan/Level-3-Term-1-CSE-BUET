package com.TeaGasSystem.director.builder;

import com.TeaGasSystem.director.builder.hardware.Hardware;
import com.TeaGasSystem.director.builder.hardware.components.Identification.Card;
import com.TeaGasSystem.director.builder.hardware.components.Identification.Cardfactory;
import com.TeaGasSystem.director.builder.hardware.components.controller.Controller;
import com.TeaGasSystem.director.builder.hardware.components.controller.controllerFactory;
import com.TeaGasSystem.director.builder.hardware.components.display.Display;
import com.TeaGasSystem.director.builder.hardware.components.display.DisplayFactory;
import com.TeaGasSystem.director.builder.hardware.components.internet.Internet;
import com.TeaGasSystem.director.builder.hardware.components.internet.InternetFactory;
import com.TeaGasSystem.director.builder.hardware.components.microcontroller.MicroControllerFactory;
import com.TeaGasSystem.director.builder.hardware.components.microcontroller.Microcontroller;
import com.TeaGasSystem.director.builder.hardware.components.storage.Storage;
import com.TeaGasSystem.director.builder.hardware.components.storage.StorageFactory;
import com.TeaGasSystem.director.builder.hardware.components.weightmeasure.WeightMeasure;
import com.TeaGasSystem.director.builder.hardware.components.weightmeasure.WeightMeasureFactory;



public class HardwareBuilder implements Builder{

    private Hardware hardware;

    public HardwareBuilder() {
        this.hardware = new Hardware();
    }

    @Override
    public void setMicrocontroller(String controller_name) {
        MicroControllerFactory microControllerFactory=new MicroControllerFactory();
        Microcontroller microcontroller=microControllerFactory.getMicroController(controller_name);
        hardware.setMicroController(microcontroller);
    }

    @Override
    public void setWeightMeasure(String weightMeasure_name) {
        WeightMeasureFactory weightMeasureFactory= new WeightMeasureFactory();
        WeightMeasure weightMeasure= weightMeasureFactory.getWeightMeasure(weightMeasure_name);
        hardware.setWeightMeasure(weightMeasure);
    }

    @Override
    public void setIdentification(String card_name) {
        Cardfactory cardfactory=new Cardfactory();
        Card card= cardfactory.getCard(card_name);
        hardware.setCard(card);
    }

    @Override
    public void setStorage(String type) {
        StorageFactory storageFactory= new StorageFactory();
        Storage storage = storageFactory.getStorage(type);
        hardware.setStorage(storage);
    }

    @Override
    public void setdisplay(String display_type) {
        DisplayFactory displayFactory = new DisplayFactory();
        Display display= displayFactory.getDisplay(display_type);
        hardware.setDisplay(display);
    }

    @Override
    public void setInternet_connection(String type) {
        InternetFactory internetFactory = new InternetFactory();
        Internet internet = internetFactory.getInternet(type);
        hardware.setInternet(internet);
    }

    @Override
    public void setController(String type) {
        controllerFactory cf = new controllerFactory();
        Controller controller = cf.getController(type);
        hardware.setController(controller);
    }

    public Hardware getHardwareObject(){
        return hardware;
    }
}
