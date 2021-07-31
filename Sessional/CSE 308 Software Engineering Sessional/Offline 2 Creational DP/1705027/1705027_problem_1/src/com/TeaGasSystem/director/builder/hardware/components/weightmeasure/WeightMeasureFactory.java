package com.TeaGasSystem.director.builder.hardware.components.weightmeasure;

public class WeightMeasureFactory {
    public WeightMeasure getWeightMeasure(String type){
        if(type.equalsIgnoreCase("Load sensor")){
            return new Loan_sensor(type);
        }
        else{
            return new Weight_Module(type);
        }
    }
}
