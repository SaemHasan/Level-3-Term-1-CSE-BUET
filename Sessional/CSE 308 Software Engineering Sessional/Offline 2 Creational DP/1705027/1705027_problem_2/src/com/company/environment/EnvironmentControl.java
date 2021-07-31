package com.company.environment;

import com.company.editor.Editor;

public class EnvironmentControl {
    public static Editor getEditor(String filename) {
        Environment environment=null;
        String[] parts = filename.split("\\.");

        if (parts[parts.length - 1].equalsIgnoreCase("c")) {
            environment = new C_Environment();
        } else if (parts[parts.length - 1].equalsIgnoreCase("cpp")) {
            environment = new CppEnvironment();
        } else if (parts[parts.length - 1].equalsIgnoreCase("py")) {
            environment = new PythonEnvironment();
        }
        if(environment!=null){
            return Editor.getInstance(environment);
        }
        else{
            return null;
        }
    }
}
