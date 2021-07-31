package com.TeaGasSystem.director.builder.hardware.components.weightmeasure;

public class Weight_Module implements WeightMeasure{
    private String type;

    public Weight_Module(String type) {
        this.type=type;
    }

    @Override
    public String getType() {
        return type;
    }

    @Override
    public void measureweight() {
        System.out.println("Measuring weight with "+getType());
    }
}
