package com.TeaGasSystem.director.builder.hardware.components.weightmeasure;

public class Loan_sensor implements WeightMeasure{
    private String type;

    public Loan_sensor(String type) {
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
