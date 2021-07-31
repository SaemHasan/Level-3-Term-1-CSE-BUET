package com.company.mediator;

import com.company.organizations.*;

import java.util.LinkedList;
import java.util.Queue;

public class JCC implements Mediator{

    private JWSA jwsa;
    private JPDC jpdc;
    private JRTA jrta;
    private JTRC jtrc;

    private Queue<Organization> Qjwsa, Qjpdc, Qjrta, Qjtrc;

    public JCC(JWSA jwsa, JPDC jpdc, JRTA jrta, JTRC jtrc) {
        this.jwsa = jwsa;
        this.jpdc = jpdc;
        this.jrta = jrta;
        this.jtrc = jtrc;
        Qjwsa = new LinkedList<>();
        Qjpdc = new LinkedList<>();
        Qjrta = new LinkedList<>();
        Qjtrc = new LinkedList<>();
    }

    public JCC() {
        Qjwsa = new LinkedList<>();
        Qjpdc = new LinkedList<>();
        Qjrta = new LinkedList<>();
        Qjtrc = new LinkedList<>();
    }

    public void setJwsa(JWSA jwsa) {
        this.jwsa = jwsa;
    }

    public void setJpdc(JPDC jpdc) {
        this.jpdc = jpdc;
    }

    public void setJrta(JRTA jrta) {
        this.jrta = jrta;
    }

    public void setJtrc(JTRC jtrc) {
        this.jtrc = jtrc;
    }

    @Override
    public void acceptRequest(Organization org, String type) {
        System.out.println(org.getClass().getSimpleName()+" requests for "+type.toUpperCase()+" service");
        if(type.equalsIgnoreCase(jwsa.getServicetype())){
            Qjwsa.add(org);
        }
        else if(type.equalsIgnoreCase(jpdc.getServicetype())){
            Qjpdc.add(org);
        }
        else if(type.equalsIgnoreCase(jrta.getServicetype())){
            Qjrta.add(org);
        }
        else if(type.equalsIgnoreCase(jtrc.getServicetype())){
            Qjtrc.add(org);
        }
    }

    @Override
    public void provideService(String org) {
        Organization receiver;
        if(org.equals("JWSA")){
            if(!Qjwsa.isEmpty()) {
                receiver = Qjwsa.peek();
                Qjwsa.remove();
                System.out.println("JWSA serves the request of "+receiver.getClass().getSimpleName());
                receiver.receiveService(jwsa.getServicetype() +" service received in "+ receiver.getClass().getSimpleName());
            }
            else System.out.println("No request in the queue");
        }
        else if(org.equals("JPDC")){
            if(!Qjpdc.isEmpty()) {
                receiver = Qjpdc.peek();
                Qjpdc.remove();
                System.out.println("JPDC serves the request of "+receiver.getClass().getSimpleName());
                receiver.receiveService(jpdc.getServicetype() +" service received in "+ receiver.getClass().getSimpleName());
            }
            else System.out.println("No request in the queue");
        }
        else if(org.equals("JRTA")){
            if(!Qjrta.isEmpty()) {
                receiver = Qjrta.peek();
                Qjrta.remove();
                System.out.println("JRTA serves the request of "+receiver.getClass().getSimpleName());
                receiver.receiveService(jrta.getServicetype() +" service received in "+ receiver.getClass().getSimpleName());
            }
            else System.out.println("No request in the queue");
        }
        else if(org.equals("JTRC")){
            if(!Qjtrc.isEmpty()) {
                receiver = Qjtrc.peek();
                Qjtrc.remove();
                System.out.println("JTRC serves the request of "+receiver.getClass().getSimpleName());
                receiver.receiveService(jtrc.getServicetype() +" service received in "+ receiver.getClass().getSimpleName());
            }
            else System.out.println("No request in the queue");
        }
    }

}
