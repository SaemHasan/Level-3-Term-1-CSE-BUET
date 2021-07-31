package com.TeaGasSystem.director;

import com.TeaGasSystem.director.builder.Builder;

public class DirectorControl {
    private String packageChoice;
    private String connectionType;
    private Director director;

    public DirectorControl(String packageChoice, String connectionType) {
        this.packageChoice = packageChoice;
        this.connectionType = connectionType;
        this.director = new Director();
    }

    public void BuildObject(Builder builder){
        if(packageChoice.equalsIgnoreCase("Silver")){
            if(connectionType.equalsIgnoreCase("WIFI") || connectionType.equalsIgnoreCase("GSM")){
                director.constructSilverPackage(builder,connectionType);
            }
            else{
                System.out.println("Silver package doesn't support Ethernet connection");
            }
        }
        else if(packageChoice.equalsIgnoreCase("Gold")){
            if(connectionType.equalsIgnoreCase("WIFI") || connectionType.equalsIgnoreCase("GSM")){
                director.constructGoldPackage(builder,connectionType);
            }
            else{
                System.out.println("Gold package doesn't support Ethernet connection");
            }
        }
        else if(packageChoice.equalsIgnoreCase("Diamond")){
            director.constructDiamondPackage(builder,connectionType);
        }
        else if(packageChoice.equalsIgnoreCase("Platinum")){
            director.constructPlatinumPackage(builder,connectionType);
        }

    }
}
