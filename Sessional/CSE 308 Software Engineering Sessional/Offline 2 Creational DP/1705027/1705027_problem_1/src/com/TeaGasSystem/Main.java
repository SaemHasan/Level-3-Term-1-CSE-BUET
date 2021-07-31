package com.TeaGasSystem;

import com.TeaGasSystem.System.Administrator;

import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        String packageChoice = "";
        String connectionChoice = "";
        String framework = "";

        Scanner sc = new Scanner(System.in);
        Scanner sc1 =  new Scanner(System.in);

        boolean loop=true;
        while (loop) {
            System.out.println("Select a package: \n 1: Silver 2: Gold 3: Diamond 4: Platinum");
            int choice = sc.nextInt();

            if (choice == 1) packageChoice = "Silver";
            else if (choice == 2) packageChoice = "Gold";
            else if (choice == 3) packageChoice = "Diamond";
            else if (choice == 4) packageChoice = "Platinum";
            else {
                packageChoice="";
                System.out.println("Enter correct input!");
                continue;
            }

            System.out.println("Select internet connection:\n 1:Wifi 2:GSM 3:Ethernet(only for Diamond & Platinum package)");
            choice = sc.nextInt();
            if (choice == 1) connectionChoice = "WiFi";
            else if (choice == 2) connectionChoice = "GSM";
            else if (choice == 3) connectionChoice = "Ethernet";
            else {
                connectionChoice="";
                System.out.println("Enter correct input!");
                continue;
            }

            System.out.println("Select a framework for web server: \n 1:Django 2:Spring 3:Laravel");
            choice=sc.nextInt();
            if (choice == 1) framework = "Django";
            else if (choice == 2) framework = "Spring";
            else if (choice == 3) framework = "Laravel";
            else {
                framework="";
                System.out.println("Enter correct input!");
                continue;
            }
            loop=false;
        }
        //System.out.println(packageChoice+"\t"+connectionChoice+"\t"+framework);
        Administrator administrator = new Administrator(packageChoice, connectionChoice, framework);

        String name;
        loop = true;
        while(loop){
            System.out.println("Select an option:");
            System.out.println("1: Add collector\t 2: Remove collector\n3: Collect Load from Collector\t 4: Backup Data\n5: Analyze Data\n6: Details about Hardware\t7: Details about web server");
            int choice = sc.nextInt();
            if(choice==1){
                System.out.println("Enter collector name: ");
                name = sc1.nextLine();
                administrator.AddCollector(name);
            }
            else if(choice==2){
                System.out.println("Enter collector name: ");
                name = sc1.nextLine();
                administrator.RemoveCollector(name);
            }
            else if(choice==3){
                System.out.println("Enter collector name: ");
                name = sc1.nextLine();
                if(administrator.SearchCollector(name)){
                    System.out.println("Swipe your ID card");
                    administrator.ScanIDcard();
                    System.out.println("\nPut load on the device");
                    administrator.WeightLoad();
                }
                else{
                    System.out.println(name+" is not a leaf collector");
                }

            }
            else if(choice==4){
                administrator.BackupData();
            }
            else if(choice==5){
                administrator.AnalyzeData();
            }
            else if(choice==6){
                administrator.PrintHardwareInfo();
            }
            else if(choice==7){
                administrator.PrintWebserverInfo();
            }
            else{
                loop=false;
            }
        }
	// write your code here
    }
}
