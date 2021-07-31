package com.company.organizations;

public interface Organization {
    public void service();
    public void request(String type);
    public String getServicetype();
    default public void receiveService(String msg){
        System.out.println(msg);
    }
}
