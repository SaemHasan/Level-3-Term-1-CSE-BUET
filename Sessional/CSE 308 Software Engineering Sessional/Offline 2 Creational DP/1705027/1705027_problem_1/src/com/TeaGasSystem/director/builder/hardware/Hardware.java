package com.TeaGasSystem.director.builder.hardware;

import com.TeaGasSystem.director.builder.hardware.components.Identification.Card;
import com.TeaGasSystem.director.builder.hardware.components.controller.Controller;
import com.TeaGasSystem.director.builder.hardware.components.display.Display;
import com.TeaGasSystem.director.builder.hardware.components.internet.Internet;
import com.TeaGasSystem.director.builder.hardware.components.microcontroller.Microcontroller;
import com.TeaGasSystem.director.builder.hardware.components.storage.Storage;
import com.TeaGasSystem.director.builder.hardware.components.weightmeasure.WeightMeasure;

public class Hardware {
    private Microcontroller microController;
    private WeightMeasure weightMeasure;
    private Card card;
    private Storage storage;
    private Display display;
    private Internet internet;
    private Controller controller;



    public Hardware() {
    }

    public Microcontroller getMicroController() {
        return microController;
    }

    public void setMicroController(Microcontroller microController) {
        this.microController = microController;
    }

    public WeightMeasure getWeightMeasure() {
        return weightMeasure;
    }

    public void setWeightMeasure(WeightMeasure weightMeasure) {
        this.weightMeasure = weightMeasure;
    }

    public Card getCard() {
        return card;
    }

    public void setCard(Card card) {
        this.card = card;
    }

    public Storage getStorage() {
        return storage;
    }

    public void setStorage(Storage storage) {
        this.storage = storage;
    }

    public Display getDisplay() {
        return display;
    }

    public void setDisplay(Display display) {
        this.display = display;
    }

    public Internet getInternet() {
        return internet;
    }

    public void setInternet(Internet internet) {
        this.internet = internet;
    }

    public Controller getController() {
        return controller;
    }

    public void setController(Controller controller) {
        this.controller = controller;
    }
}
