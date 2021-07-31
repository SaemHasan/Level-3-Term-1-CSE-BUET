package com.company;

import com.company.editor.Editor;
import com.company.environment.EnvironmentControl;

import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        while(true) {
            System.out.println("Enter filename with extension(.c/.cpp/.py)");

            String filename = scanner.nextLine();
            Editor editor = EnvironmentControl.getEditor(filename);
            if (editor != null) {
                editor.SeeDetails();
            } else {
                System.out.println("Enter filename correctly");

            }
        }
	// write your code here
    }

}
