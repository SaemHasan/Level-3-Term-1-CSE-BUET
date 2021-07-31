package com.company.organizations;

import com.company.mediator.Mediator;

import java.util.Queue;

public class JRTA implements Organization{

    private Mediator mediator;
    private String servicetype;

    public JRTA(Mediator mediator) {
        this.mediator = mediator;
        servicetype = "TRANSPORT";
    }

    public JRTA(Mediator mediator, String servicetype) {
        this.mediator = mediator;
        this.servicetype = servicetype;
    }

    public String getServicetype() {
        return servicetype;
    }

    @Override
    public void service() {
        mediator.provideService(this.getClass().getSimpleName());
    }

    @Override
    public void request(String type) {
        mediator.acceptRequest(this, type);
    }
}
