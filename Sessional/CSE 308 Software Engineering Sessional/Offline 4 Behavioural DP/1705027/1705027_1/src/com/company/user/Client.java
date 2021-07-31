package com.company.user;

import java.io.*;
import java.net.Socket;

public class Client  {
    private Socket clientSocket;

    private String sentence;
    private BufferedReader inFromUser;
    private BufferedReader inFromServer;

    private Boolean isRunning;

    public Client(Socket c) throws Exception {
        clientSocket = c;
        inFromUser = new BufferedReader(new InputStreamReader(System.in));
        inFromServer = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
        isRunning = true;
    }


    public void run() {
        ListenFromServer ls = new ListenFromServer(clientSocket);
        ls.start();
        ReadFromcmd rc = new ReadFromcmd();
        rc.start();
    }






    class ReadFromcmd extends Thread{
        public ReadFromcmd() {
        }

        @Override
        public void run() {
            while (isRunning) {
                try {

                    PrintWriter outToServer = new PrintWriter(clientSocket.getOutputStream(), true);

                    //System.out.println("Enter the message : (S id or U id)");

                    sentence = inFromUser.readLine();

                    outToServer.println(sentence);

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    class ListenFromServer extends Thread {
        private Socket socket;

        public ListenFromServer(Socket socket) {
            this.socket = socket;
        }

        @Override
        public void run() {
            while (true) {
                try {
                    //Thread.sleep(500);
                    String msg = inFromServer.readLine();
                    System.out.println("message from server :  " +msg);

                } catch (Exception e) {
                    e.printStackTrace();
                    break;
                }
            }

            System.out.println("Observing closed");
        }
    }
}





