package com.company;

import com.company.mediator.JCC;
import com.company.mediator.Mediator;
import com.company.organizations.JPDC;
import com.company.organizations.JRTA;
import com.company.organizations.JTRC;
import com.company.organizations.JWSA;

import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        String command;
        Boolean initialized=false;

        JCC mediator;
        JWSA jwsa = null;
        JPDC jpdc = null;
        JTRC jtrc = null;
        JRTA jrta = null;

        while (true){
            command = scanner.nextLine();
            if(command.equalsIgnoreCase("INIT")){
                initialized=true;
                mediator = new JCC();

                jwsa = new JWSA(mediator);
                jpdc = new JPDC(mediator);
                jrta = new JRTA(mediator);
                jtrc = new JTRC(mediator);

                mediator.setJwsa(jwsa);
                mediator.setJpdc(jpdc);
                mediator.setJrta(jrta);
                mediator.setJtrc(jtrc);

                System.out.println("\nAll four services are initiated\n");
            }
            else if(initialized){
                String []parts = command.split(" ");
                if(parts.length==2) {
                    if (parts[0].equalsIgnoreCase("JWSA")) {
                        if (parts[1].equalsIgnoreCase("SERVE")) {
                            jwsa.service();
                        } else jwsa.request(parts[1]);
                    } else if (parts[0].equalsIgnoreCase("JPDC")) {
                        if (parts[1].equalsIgnoreCase("SERVE")) {
                            jpdc.service();
                        } else jpdc.request(parts[1]);
                    } else if (parts[0].equalsIgnoreCase("JRTA")) {
                        if (parts[1].equalsIgnoreCase("SERVE")) {
                            jrta.service();
                        } else jrta.request(parts[1]);
                    } else if (parts[0].equalsIgnoreCase("JTRC")) {
                        if (parts[1].equalsIgnoreCase("SERVE")) {
                            jtrc.service();
                        } else jtrc.request(parts[1]);
                    }
                }
                else System.out.println("\nEnter Command Correctly\n");
            }
            else{
                System.out.println("\ninitialize first!\n");
            }
        }

    }
}
