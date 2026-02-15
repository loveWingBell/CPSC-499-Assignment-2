package javacc;

import java.io.*;
import java.util.List;

/**
 * Driver for the JavaCC-based Java 1.2 invocation finder.
 */
public class JavaccInvocationFinder {

    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println("Usage: java javacc.JavaccInvocationFinder <file1.java> [file2.java ...]");
            System.exit(1);
        }

        int totalInvocations = 0;
        java.util.List<Java12ParserAnalysis.InvocationInfo> allInvocations =
            new java.util.ArrayList<Java12ParserAnalysis.InvocationInfo>();

        for (String filePath : args) {
            File file = new File(filePath);
            String fileName = file.getName();

            try {
                FileInputStream fis = new FileInputStream(file);
                Java12ParserAnalysis parser = new Java12ParserAnalysis(fis);
                parser.setFileName(fileName);
                parser.CompilationUnit();

                allInvocations.addAll(parser.getInvocations());
            } catch (ParseException e) {
                System.err.println("Parse error in " + fileName + ": " + e.getMessage());
            }
        }

        System.out.println(allInvocations.size()
            + " method/constructor invocation(s) found in the input file(s)");
        System.out.println();
        for (Java12ParserAnalysis.InvocationInfo inv : allInvocations) {
            System.out.println(inv);
        }
    }
}
