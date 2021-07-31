package com.TeaGasSystem.factory;

import com.TeaGasSystem.factory.webserver.Django;
import com.TeaGasSystem.factory.webserver.Webserver;
import com.TeaGasSystem.factory.webserver.Laravel;
import com.TeaGasSystem.factory.webserver.Spring;

public class Factory {
    public Webserver getFrameWork(String FrameworkName){
        if(FrameworkName.equalsIgnoreCase("Django")){
            return new Django(FrameworkName);
        }
        else if(FrameworkName.equalsIgnoreCase("Spring")){
            return new Spring(FrameworkName);
        }
        else if(FrameworkName.equalsIgnoreCase("Laravel")){
            return new Laravel(FrameworkName);
        }
        else{
            return null;
        }
    }
}
