package com.company;

import com.company.adapter.SumAdapter;
import com.company.charactersum.CharSum;
import com.company.integersum.IntegerSum;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Scanner;

public class Main {

    public static void main(String[] args) throws IOException {
        String filename;
        int choice;

        Scanner scanner = new Scanner(System.in);
        Scanner scanner1 = new Scanner(System.in);

        IntegerSum intsum = new IntegerSum();
        CharSum charSum = new SumAdapter();


        while (true){
            System.out.println("\n1: integer number sum\t2: character ascii value sum\n");
            choice = scanner.nextInt();
            if(choice==1){
                System.out.println("Enter file name: ");
                filename = scanner1.nextLine();

                File file = new File(filename);
                intsum.calculate_Sum(file);
            }
            else if(choice==2){
                System.out.println("Enter file name: ");
                filename = scanner1.nextLine();
                charSum.calcSum(new File(filename));
            }
            else{
                break;
            }
        }
    }
}
