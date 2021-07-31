package com.company.integersum;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class IntegerSum {

    public int calculate_Sum(File f) {
        try{
            Scanner scanner = new Scanner(f);
            int sum =0;
            while (scanner.hasNext()){
                //System.out.println(scanner.nextInt());
                sum+=scanner.nextInt();
            }
            System.out.println("Total Sum : "+sum);
        }
        catch (Exception e){
            System.out.println("Enter file name correctly");
        }

        return 0;
    }
}
