package com.company.server;

import com.company.server.observable.Stocks;
import com.company.server.observer.Observer;
import com.company.server.observer.Observers;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

public class Main {

    public static Map<String, Stocks> stocksMap = new HashMap<>();

    public static void main(String[] argv) throws Exception
    {
        int observerThreadCount = 0;
        ServerSocket welcomeSocket = new ServerSocket(2700);
        int id=1;
        String stockDetails="Stocks : ";

        ReadFromCmd readFromcmd = new ReadFromCmd();

        Scanner scanner = new Scanner(new File("input.txt"));
        while (scanner.hasNext()){
            String details = scanner.nextLine();
            String []array = details.split(" ");
            stocksMap.put(array[0], new Stocks(array[0], Integer.parseInt(array[1]), Float.parseFloat(array[2])));
            stockDetails=stockDetails+"\n"+details;
        }

        readFromcmd.start();

        while(true)
        {
            Socket connectionSocket = welcomeSocket.accept();
            Observers wt = new Observers(connectionSocket,id, stockDetails);
            Thread t = new Thread(wt);
            t.start();
            observerThreadCount++;
            System.out.println("Observer [" + id + "] is now connected. No. of observer threads = " + observerThreadCount);
            id++;
        }
    }

    private static class ReadFromCmd extends Thread{
        public ReadFromCmd() {
        }

        @Override
        public void run() {
            while (true) {
                try {
                    BufferedReader inFromUser = new BufferedReader(new InputStreamReader(System.in));
                    //System.out.println("Enter the command(I or D or C type)");

                    String sentence = inFromUser.readLine();
                    String []arr = sentence.split(" ");

                    Stocks obj = stocksMap.get(arr[1]);

                    if(arr[0].equalsIgnoreCase("I")){
                        obj.setPrice(obj.getPrice() + Float.parseFloat(arr[2]));
                        String msg = "Price of stock "+ arr[1] + " has increased by "+arr[2]+ ". New price : "+obj.getPrice();
                        obj.Notify(msg);
                        System.out.println(msg);
                    }

                    else if(arr[0].equalsIgnoreCase("D")){
                        obj.setPrice(obj.getPrice() - Float.parseFloat(arr[2]));
                        String msg = "Price of stock "+ arr[1] + " has decreased by "+arr[2]+ ". New price : "+obj.getPrice();
                        obj.Notify(msg);
                        System.out.println(msg);
                    }

                    else if(arr[0].equalsIgnoreCase("C")){
                        obj.setCount(obj.getCount() + Integer.parseInt(arr[2]));
                        String msg = "Count of stock "+ arr[1] + " has changed. New count : "+obj.getCount();
                        obj.Notify(msg);
                        System.out.println(msg);
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

}



