package com.company.user;

import java.net.Socket;

public class Main {
    public static void main(String[] argv) throws Exception
    {
        String host="localhost";
        Socket clientSocket = new Socket(host, 2700);
        Client client=new Client(clientSocket);
        client.run();
    }
}
