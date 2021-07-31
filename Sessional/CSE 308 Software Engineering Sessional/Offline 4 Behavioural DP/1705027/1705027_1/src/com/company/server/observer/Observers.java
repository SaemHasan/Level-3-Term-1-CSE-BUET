package com.company.server.observer;

import com.company.server.Main;


import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class Observers implements Runnable, Observer
{
    private String command=null;
    private Socket connectionSocket;
    private int id;
    private String details;
    private PrintWriter outToClient;

    public Observers(Socket s, int id, String details) throws IOException {
        this.connectionSocket = s;
        this.id = id;
        this.details = details;
        outToClient = new PrintWriter(connectionSocket.getOutputStream(),true);
    }

    public void run()
    {
        outToClient.println(details);
        while(connectionSocket.isConnected())
        {
            try
            {
                BufferedReader inFromClient = new BufferedReader(new InputStreamReader(connectionSocket.getInputStream()));

                command = inFromClient.readLine();
                String []arr = command.split(" ");

                if(arr[0].equalsIgnoreCase("S")) {
                    String stockid = arr[1];
                    Main.stocksMap.get(stockid).add(this);
                    outToClient.println("Subscribed to "+stockid);
                    System.out.println("Observer "+this.id+" has subscribed to "+stockid);
                }

                else if(arr[0].equalsIgnoreCase("U")){
                    String stockid = arr[1];
                    Main.stocksMap.get(stockid).remove(this);
                    outToClient.println("Unsubscribed from "+stockid);
                    System.out.println("Observer "+this.id+" has unsubscribed to "+stockid);
                }

            }

            catch(Exception e)
            {

            }
        }
    }


    @Override
    public void Update(String msg) {
        try{
            //PrintWriter outToClient = new PrintWriter(connectionSocket.getOutputStream(),true);
            outToClient.println(msg);
        }
        catch (Exception e){}
    }
}
