package com.company.adapter;

import com.company.charactersum.CharSum;
import com.company.integersum.IntegerSum;

import java.io.*;
import java.util.Scanner;

public class SumAdapter extends IntegerSum implements CharSum{


    @Override
    public int calcSum(File f){
        String destination = "ascii_values.txt";
        try{
            FileWriter fw = new FileWriter(destination);
            BufferedWriter out = new BufferedWriter(fw);
            BufferedReader br = new BufferedReader(new FileReader(f));
            int c=0;
            while ((c=br.read()) != -1){
                int ascii_value = c;
                String s = String.valueOf(ascii_value);
//            System.out.println(s);
                if(ascii_value!=32) out.write(s);
                else out.write(" ");
            }
            out.close();
            File file = new File(destination);

            calculate_Sum(file);
        }
        catch (Exception e){
            System.out.println("Enter file name correctly");
        }


        return 0;
    }
}
